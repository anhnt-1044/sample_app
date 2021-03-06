class UsersController < ApplicationController
  before_action :find_user, except: %i(index new create)
  before_action :logged_in_user, except: %i(new show create)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def index
    @users = User.page(params[:page]).per Settings.pagination.per_page
  end

  def new
    @user = User.new
  end

  def show
    @microposts =
      @user.microposts.page(params[:page]).per Settings.pagination.per_page
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = t ".account.activate.warning"
      redirect_to @user
    else
      flash.now[:danger] = t ".new.fail"
      render :new
    end
  end

  def edit; end

  def update
    if @user.update user_params
      flash[:success] = t ".success"
      redirect_to @user
    else
      flash[:danger] = t ".fail"
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t ".delete.del_success"
      redirect_to users_url
    else
      flash.now[:danger] = t "inform_error"
    end
    redirect_to users_url
  end

  private

  def user_params
    params.require(:user).permit User::PERMITTED_ATTR
  end

  def correct_user
    redirect_to root_url unless current_user? @user
  end

  def admin_user
    redirect_to root_url unless current_user.admin?
  end
end
