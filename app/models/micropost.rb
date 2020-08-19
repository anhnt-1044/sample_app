class Micropost < ApplicationRecord
  PERMITTED_PARAM = %i(content picture).freeze

  belongs_to :user
  has_one_attached :picture

  delegate :name, prefix: true, to: :user

  validates :user_id, presence: true
  validates :content, presence: true,
    length: {maximum: Settings.micropost.model.content_max_length}
  validates :picture, content_type: {
    in: Settings.micropost.model.content_type,
    message: I18n.t("microposts.model.image.type")
  }, size: {
    less_than: Settings.micropost.model.image_size_mb.megabytes,
    message: I18n.t("microposts.model.image.size")
  }

  scope :by_created_at, ->{order(created_at: :desc)}
  scope :by_user, ->(ids){where user_id: ids}

  def display_image
    picture.variant resize_to_limit:
      [Settings.micropost.model.display_img.height,
        Settings.micropost.model.display_img.width]
  end
end
