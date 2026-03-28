class Users::RegistrationsController < Devise::RegistrationsController
  def new
    @step = :email
    self.resource = resource_class.new
  end

  def create
    if params[:otp_code].present?
      verify_otp_and_complete
    else
      initiate_registration
    end
  end

  private

  def initiate_registration
    email = params.dig(:user, :email)&.downcase&.strip

    if User.exists?(email: email)
      @step = :email
      self.resource = resource_class.new
      flash.now[:alert] = "An account with that email already exists. Please sign in."
      render :new, status: :unprocessable_entity
      return
    end

    user = User.new(email: email, password: SecureRandom.hex(32))
    if user.save
      user.generate_otp!
      OtpMailer.send_otp(user).deliver_later
      @email = email
      @step = :otp
      self.resource = user
      render :new, status: :unprocessable_entity
    else
      @step = :email
      self.resource = user
      render :new, status: :unprocessable_entity
    end
  end

  def verify_otp_and_complete
    email = params[:email]&.downcase&.strip
    user = User.find_by(email: email)

    if user&.verify_otp(params[:otp_code])
      sign_in(user)
      user.remember_me = true
      user.remember_me!
      redirect_to after_sign_in_path_for(user), notice: "Welcome to Andakshari!"
    else
      @email = email
      @step = :otp
      self.resource = user || resource_class.new
      flash.now[:alert] = "Invalid or expired code. Please try again."
      render :new, status: :unprocessable_entity
    end
  end
end
