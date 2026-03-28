class Users::SessionsController < Devise::SessionsController
  def new
    @step = :email
    self.resource = resource_class.new
  end

  def create
    if params[:otp_code].present?
      verify_otp
    else
      send_otp
    end
  end

  private

  def send_otp
    email = params.dig(:user, :email)&.downcase&.strip
    user = User.find_by(email: email)

    if user
      user.generate_otp!
      OtpMailer.send_otp(user).deliver_later
      @email = email
      @step = :otp
      self.resource = user
      render :new, status: :unprocessable_entity
    else
      self.resource = resource_class.new
      @step = :email
      flash.now[:alert] = "No account found with that email. Please register first."
      render :new, status: :unprocessable_entity
    end
  end

  def verify_otp
    email = params[:email]&.downcase&.strip
    user = User.find_by(email: email)

    if user&.verify_otp(params[:otp_code])
      sign_in(user)
      user.remember_me = true
      user.remember_me!
      redirect_to after_sign_in_path_for(user), notice: "Signed in successfully."
    else
      @email = email
      @step = :otp
      self.resource = user || resource_class.new
      flash.now[:alert] = "Invalid or expired code. Please try again."
      render :new, status: :unprocessable_entity
    end
  end
end
