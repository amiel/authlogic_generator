module AuthenticationHandling
  
  def self.included(base)
    base.send(:filter_parameter_logging, :password, :password_confirmation)
    base.send(:helper_method, :current_user_session, :current_user)
  end
  
private

  def current_user_session
    @current_user_session ||= UserSession.find
  end

  def current_user
    @current_user ||= current_user_session && current_user_session.user
  end

  def require_user
    unless current_user
      store_location
      flash[:notice] = I18n.t(:'flashes.users.must_be_logged_in', :default => "You must be logged in to access this page")
      redirect_to login_url
      return false
    end
  end

  def require_no_user
    if current_user
      store_location
      flash[:notice] = I18n.t(:'flashes.users.must_be_logged_out', :default => "You must be logged out to access this page")
      redirect_to account_url
      return false
    end
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
    
end