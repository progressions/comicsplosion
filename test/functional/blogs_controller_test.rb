require File.dirname(__FILE__) + '/../test_helper'
require 'blogs_controller'

# Re-raise errors caught by the controller.
class BlogsController; def rescue_action(e) raise e end; end

class BlogsControllerTest < Test::Unit::TestCase
  # fixtures :blogs

  def fsetup
    @controller = BlogsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_truth
    assert true
  end

  def ftest_should_get_index
    get :index
    assert_response :success
    assert assigns(:blogs)
  end

  def ftest_should_get_new
    get :new
    assert_response :success
  end
  
  def ftest_should_create_blog
    old_count = Blog.count
    post :create, :blog => { }
    assert_equal old_count+1, Blog.count
    
    assert_redirected_to blog_path(assigns(:blog))
  end

  def ftest_should_show_blog
    get :show, :id => 1
    assert_response :success
  end

  def ftest_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def ftest_should_update_blog
    put :update, :id => 1, :blog => { }
    assert_redirected_to blog_path(assigns(:blog))
  end
  
  def ftest_should_destroy_blog
    old_count = Blog.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Blog.count
    
    assert_redirected_to blogs_path
  end
end
