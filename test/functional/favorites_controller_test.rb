require File.dirname(__FILE__) + '/../test_helper'
require 'favorites_controller'

# Re-raise errors caught by the controller.
class FavoritesController; def rescue_action(e) raise e end; end

class FavoritesControllerTest < Test::Unit::TestCase
  fixtures :favorites

  def setup
    @controller = FavoritesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:favorites)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_favorite
    old_count = Favorite.count
    post :create, :favorite => { }
    assert_equal old_count+1, Favorite.count
    
    assert_redirected_to favorite_path(assigns(:favorite))
  end

  def test_should_show_favorite
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_favorite
    put :update, :id => 1, :favorite => { }
    assert_redirected_to favorite_path(assigns(:favorite))
  end
  
  def test_should_destroy_favorite
    old_count = Favorite.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Favorite.count
    
    assert_redirected_to favorites_path
  end
end
