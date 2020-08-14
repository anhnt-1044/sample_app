class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by email: params[:email]
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      login user
      flash[:success] = t "users.account.activate.success"
      redirect_to user
    else
      flash[:danger] = t "users.account.activate.danger"
      redirect_to root_url
    end
  end
end
