class User < ApplicationRecord
  VALID_EMAIL_REGEX = Settings.validations.user.email.REGEX
  PERMITTED_ATTR = %i(email password name password_confirmation).freeze
  PERMITTED_PWD_RESET_ATTR = %i(password password_confirmation).freeze

  attr_accessor :remember_token, :activation_token, :reset_token

  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name: :Relationship,
    foreign_key: :follower_id, dependent: :destroy
  has_many :passive_relationships, class_name: :Relationship,
    foreign_key: :followed_id, dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  validates :email, presence: true,
              length: {maximum: Settings.validations.user.email.max_length},
              format: {with: VALID_EMAIL_REGEX},
              uniqueness: true
  validates :name, presence: true,
              length: {maximum: Settings.validations.user.name.max_length}

  validates :password, presence: true, allow_nil: true,
              length: {minimum: Settings.validations.user.password.min_length}

  has_secure_password

  before_create :create_activation_digest
  before_save :downcase_email

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost: cost
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def follow other_user
    following << other_user
  end

  def unfollow other_user
    following.delete other_user
  end

  def following? other_user
    following.include? other_user
  end

  def remember
    self.remember_token = User.new_token
    update remember_digest: User.digest(remember_token)
  end

  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false unless digest

    BCrypt::Password.new(digest).is_password? token
  end

  def forget
    update remember_digest: nil
  end

  def activate
    update activated: true, activated_at: Time.zone.now
  end

  def activated?
    activated
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < Settings.pwd_expired.seconds.ago
  end

  def feed
    Micropost.by_created_at.by_user id
  end

  private

  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest activation_token
  end
end
