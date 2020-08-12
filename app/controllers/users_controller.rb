class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def show
    @user = User.find_by id: params[:id]
    return if @user

    redirect_to root_path
  end

  def create
    @user = User.new user_params
    if @user.save
      login @user
      flash[:success] = t ".new.welcome"
      redirect_to @user
    else
      flash.now[:danger] = t ".new.fail"
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit User::PERMITTED_ATTR
  end
end
