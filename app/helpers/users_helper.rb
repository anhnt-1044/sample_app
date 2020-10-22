module UsersHelper
  def gravatar_for user, options: {size: Settings.helper.users.img_size}
    gravatar_id = Digest::MD5.hexdigest user.email.downcase
    gravatar_url = "https://secure.gravatar.com/avatar/" \
    "#{gravatar_id}?s=#{options[:size]}"
    image_tag gravatar_url, alt: user.name, class: "gravatar"
  end

  def display_err errors, field
    return if errors.blank?

    err = errors.full_messages_for(field)[0] if errors.include? field
    content_tag(:div, err, class: "invalid-feedback") if err.present?
  end

  def remove_relationship
    current_user.active_relationships.find_by followed_id: user.id
  end
end
