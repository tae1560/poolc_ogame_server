class ApplicationController < ActionController::Base
  protect_from_forgery

  protected
  def authenticate_user
    unless session[:last_seen]
      session[:last_seen] = Time.now
    end

    if session[:user_id] == nil or session[:last_seen] < Time.now - 2.hours
      session[:last_seen] = Time.now
      session[:user_id] = nil
      redirect_to users_path
      return false
    else
      # set current user object to @current_user object variable
      @current_user = User.find session[:user_id]
      session[:last_seen] = Time.now
      return true
    end
  end

  def save_login_state
    if session[:user_id]
      #redirect_to(:controller => 'planets', :action => 'index')
      redirect_to edit_user_url(session[:user_id])
      return false
    else
      return true
    end
  end
end
