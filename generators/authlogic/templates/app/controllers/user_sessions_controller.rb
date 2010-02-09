class UserSessionsController < ApplicationController

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = I18n.t(:'flashes.user_sessions.create.notice', :default => "Login successful!")
      redirect_back_or_default account_url
    else
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = I18n.t(:'flashes.user_sessions.destroy.notice', :default => "Logout successful!")
    redirect_back_or_default login_url
  end
end
