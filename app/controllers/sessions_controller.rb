class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user.status == "approval"
      if user && user.authenticate(params[:session][:password])
        log_in user
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        if user.admin?
          redirect_to users_path
        else
          if store_location == nil
          redirect_to user_path(user)
          else
          redirect_back_or user
          end
        end
      else
        flash.now[:danger] = '認証に失敗しました'
        render :new
      end
    else
      flash.now[:danger] = 'ユーザーが未登録か承認されていないため、ログインできません'
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    flash[:success] = 'ログアウトしました'
    redirect_to root_url
  end
end

