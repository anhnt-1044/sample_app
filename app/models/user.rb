class User < ApplicationRecord
  VALID_EMAIL_REGEX = Settings.validations.user.email.REGEX
  PERMITTED_ATTR = %i(email password name password_confirmation).freeze

  attr_accessor :remember_token

  validates :email, presence: true,
              length: {maximum: Settings.validations.user.email.max_length},
              format: {with: VALID_EMAIL_REGEX},
              uniqueness: true
  validates :name, presence: true,
              length: {maximum: Settings.validations.user.name.max_length}

  validates :password, presence: true, allow_nil: true,
              length: {minimum: Settings.validations.user.password.min_length}

  has_secure_password

  before_save :downcase_email

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create(string, cost: cost)
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update remember_digest: User.digest(remember_token)
  end

  def authenticated? remember_token
    return false unless remember_digest

    BCrypt::Password.new(remember_digest).is_password? remember_token
  end

  def forget
    update remember_digest: nil
  end

  private

  def downcase_email
    email.downcase!
  end
end
