class MicropostsController < ApplicationController
  before_action :logged_in_user, only: %i(create destroy)
  before_action :correct_user, only: :destroy
  before_action :new_micropost, only: :create

  def create
    @micropost.picture.attach micropost_params[:picture]
    if @micropost.save
      flash[:success] = t "flash.micropost.create.success"
      redirect_to root_url
    else
      @feed_items = current_user.feed.page params[:page]
      flash.now[:danger] = t "flash.micropost.create.fail"
      render "static_pages/home"
    end
  end

  def destroy
    if @micropost.destroy
      flash[:success] = t "flash.micropost.destroy.success"
      redirect_to request.referer || root_url
    else
      flash[:danger] = t "flash.micropost.destroy.fail"
      redirect_to root_url
    end
  end

  private

  def micropost_params
    params.require(:micropost).permit Micropost::PERMITTED_PARAM
  end

  def new_micropost
    @micropost = current_user.microposts.build micropost_params
  end

  def correct_user
    @micropost = current_user.microposts.find_by id: params[:id]
    redirect_to root_url unless @micropost

    flash.now[:danger] = t "flash.micropost.error"
    redirect_to root_url
  end
end
