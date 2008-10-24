# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require 'paginator'

class ApplicationController < ActionController::Base

  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_comics_session_id', :secret => "get_funky"
  
  before_filter do |c|
    unless c.session[:user].nil?
      User.current_user = User.find(c.session[:user], :include => [:roles, :permissions])
    end
  end
  
  def check_authentication
    unless session[:user]
      session[:intended_action] = params
      redirect_to signin_path
    end
  end
end
