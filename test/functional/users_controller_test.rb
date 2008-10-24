require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < Test::Unit::TestCase
  fixtures :users, :comics, :pages, :views

  def setup
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @jeff = users(:jeff)
  end
  
  def signin
    post :signin_path, :user => { :username => @jeff.username, :password => @jeff.password }
  end
  
  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:users)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_user
    old_count = User.count
    post :create, :user => { :username => 'newguy', :alias => 'newguy', :password => 'password', :password_confirmation => 'password', :email => 'dude@email.com' }
    assert_equal old_count+1, User.count
    
    assert_redirected_to user_path(assigns(:user))
  end
  
  def test_should_NOT_create_user
    old_count = User.count
    post :create, :user => { :username => 'newguy', :alias => 'newguy', :password => 'password', :password_confirmation => 'NOT password' }
    assert_equal old_count, User.count
    
    assert_response :success   
  end
  
  def test_should_show_user
    get :show, :id => 1
    assert_response :success
  end
  
  def test_show_favorites
    get :favorites, :id => @jeff.alias
    # assert_response :success
    
    @favorites = assigns(:favorites)
    assert_equal 2, @favorites.length
  end

  def test_get_edit_without_signin
    get :edit, :id => 1
    assert_redirected_to signin_path
  end
  
  def test_update_user_with_signin
    @request.session[:user] = users(:jeff).id 
    put :update, {:id => @jeff.id, :user => { :alias => "funky" }}
    assert_redirected_to user_path(@jeff)
  end
  
  def test_update_user_without_signin
    put :update, :id => 1, :user => { :alias => "funky" }
    assert_redirected_to signin_path
  end
  
  def test_destroy_user_without_signin
    old_count = User.count
    delete :destroy, :id => 2
    assert_equal old_count, User.count
    
    assert_redirected_to signin_path
  end
  
  def test_should_destroy_user_with_signin
    old_count = User.count
    @request.session[:user] = users(:jeff).id
    delete :destroy, :id => 2
    assert_equal old_count-1, User.count
    
    assert_redirected_to users_path
  end
end
