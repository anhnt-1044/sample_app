module API
  module V1
    module Defaults
      extend ActiveSupport::Concern

      included do
        prefix "api"
        version "v1", using: :path
        default_format :json
        format :json

        helpers do
          def authenticate_user!
            token = request.headers["Jwt-Token"]
            user_id = Authentication.decode(token)["user_id"] if token
            @current_user = User.find_by id: user_id
            return if @current_user

            api_error!("You need to log in to use the app", "failure", 401, {})
          end

          def api_error! message, error_code, status, header
            error!({message: message, code: error_code}, status, header)
          end

          def success_format data
            {status: "success", data: data.as_json}
          end
        end

        rescue_from ActiveRecord::RecordNotFound do |e|
          error_response(message: e.message, status: 404)
        end

        rescue_from ActiveRecord::RecordInvalid do |e|
          error_response(message: e.message, status: 422)
        end
      end
    end
  end
end
