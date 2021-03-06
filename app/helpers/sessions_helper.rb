module SessionsHelper
  def login user
    session[:user_id] = user.id
  end

  def logged_in?
    current_user.present?
  end

  def log_out
    forget current_user
    session.delete :user_id
  end

  def remember user
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  def remember_process user, session
    session[:remember_me] == "1" ? remember(user) : forget(user)
  end

  def activate_process user, session
    login user
    remember_process user, session
    redirect_back_or user
  end

  def not_activate_process
    message = t "users.account.activate.warning"
    flash[:warning] = message
    redirect_to root_url
  end

  def current_user
    if user_id = session[:user_id]
      current_user ||= User.find_by id: user_id
    elsif user_id = cookies.signed[:user_id]
      user = User.find_by id: user_id
      if user&.authenticated? :remember, cookies[:remember_token]
        login user
        current_user = user
      end
    end
    current_user
  end

  def forget user
    user.forget
    cookies.delete :user_id
    cookies.delete :remember_token
  end

  def current_user? user
    user && user == current_user
  end

  def redirect_back_or default
    redirect_to session[:forwarding_url] || default
    session.delete :forwarding_url
  end

  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
