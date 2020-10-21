module API
  module Entities
    class Micropost < Grape::Entity
      expose :id
      expose :content
    end
  end
end
