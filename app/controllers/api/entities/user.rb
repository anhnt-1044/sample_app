module API
  module Entities
    class User < Grape::Entity
      expose :id
      expose :name
      expose :email
      expose :created_at do |user|
        user.created_at.to_date
      end
      expose :micropost_count do |user|
        user.microposts.size
      end
      expose :microposts do |user|
        Entities::Micropost.represent user.microposts
      end
    end
  end
end
