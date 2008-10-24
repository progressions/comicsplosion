require File.dirname(__FILE__) + '/../test_helper'
require 'chapters_controller'

# Re-raise errors caught by the controller.
class ChaptersController; def rescue_action(e) raise e end; end

class ChaptersControllerTest < Test::Unit::TestCase
  fixtures :users, :comics, :chapters, :pages

  def setup
    @controller = ChaptersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:chapters)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_chapter
    old_count = Chapter.count
    post :create, :chapter => {:name => "Chapter 3"}
    assert_equal old_count+1, Chapter.count
    
    assert_redirected_to chapter_path(assigns(:chapter))
  end

  def test_should_show_chapter
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_chapter
    put :update, :id => 1, :chapter => {:name => "Chapter One" }
    assert_redirected_to chapter_path(assigns(:chapter))
  end
  
  def test_should_destroy_chapter
    old_count = Chapter.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Chapter.count
    
    assert_redirected_to chapters_path
  end
end
