module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      # Devise stores users under the :user scope in Warden
      user = request.env["warden"]&.user(:user)
      user || reject_unauthorized_connection
    end
  end
end
