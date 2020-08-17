class PasswordResetsController < ApplicationController  
  before_action :find_user, only: %i(create edit update)
  before_action :valid_user, :check_expiration, only: %i(edit update)

  def new; end

  def create
    @user.create_reset_digest
    @user.send_password_reset_email
    flash[:info] = t "flash.pwd_reset.info"
    redirect_to root_url
  end

  def edit; end

  def update
    if user_params[:password].blank?
      @user.errors.add :password, t("flash.pwd_reset.danger.cant_blank")
      render :edit
    elsif @user.update user_params
      login @user
      flash[:success] = t "flash.pwd_reset.success"
      redirect_to @user
    else
      flash.now[:danger] = t "flash.pwd_reset.danger.failed_update"
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit User::PERMITTED_PWD_RESET_ATTR
  end

  def find_user
    email_par = request.post? ? params[:password_reset][:email] : params[:email]
    @user = User.find_by email: email_par
    return if @user

    flash.now[:danger] = t "flash.pwd_reset.danger.not_found"
    redirect_to root_url
  end

  def valid_user
    return if @user.activated? && @user.authenticated?(:reset, params[:id])

    flash.now[:danger] = t "flash.pwd_reset.danger.not_valid_user"
    redirect_to root_url
  end

  def check_expiration
    return unless @user.password_reset_expired?

    flash.now[:danger] = t "flash.pwd_reset.danger.expired"
    redirect_to new_password_reset_url
  end
end
