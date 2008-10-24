require File.dirname(__FILE__) + '/../test_helper'
require 'admin_controller'

# Re-raise errors caught by the controller.
class AdminController; def rescue_action(e) raise e end; end

class AdminControllerTest < Test::Unit::TestCase
  fixtures :users

  def setup
    @controller = AdminController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @jeff = users(:jeff)
  end

  # Replace this with your real tests.
  def test_signin_with_invalid_user
    post :signin, :user => {:username => "wrong", :password => "wrong" }
    assert_response :success
    assert_equal "Your username or password was invalid. Please try again.", flash[:notice]
  end
  
  def test_signin_with_invalid_password
    post :signin, :user => {:username => @jeff.username, :password => "wrong" }
    assert_response :success
    assert_equal "Your username or password was invalid. Please try again.", flash[:notice]
  end
  
  def test_login_with_valid_user
    post :signin, :user => {:username => @jeff.username, :password => 'secret' }
    assert_redirected_to home_path
    assert_equal nil, flash[:notice]
    assert_not_nil session[:user]
    user = User.find(session[:user])
    assert_equal @jeff.username, user.username
  end
  
  def test_signout_with_valid_user
    @request.session[:user] = users(:jeff).id 
    get :signout
    assert_redirected_to home_path
    assert_equal nil, @request.session[:user]
  end
  
end
