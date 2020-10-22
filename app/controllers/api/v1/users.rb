module API
  module V1
    class Users < Grape::API
      include API::V1::Defaults

      before do
        authenticate_user!
      end

      prefix "api"
      version "v1", using: :path
      format :json

      resource :users do
        desc "Return all users"
        get "", root: :users do
          users = User.includes :microposts
          formatted_users = Entities::User.represent users
          response = success_format users: formatted_users
          present response
        end

        desc "Return a user"
        params do
          requires :id, type: String, desc: "ID of the user"
        end
        get ":id", root: "user" do
          user = User.find params[:id]
          format_user = Entities::User.represent user,
                                                 only: %i(name email microposts)
          response = success_format user: format_user
          present response
        end
      end
    end
  end
end
