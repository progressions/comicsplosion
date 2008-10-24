require File.dirname(__FILE__) + '/../test_helper'
require 'tags_controller'

# Re-raise errors caught by the controller.
class TagsController; def rescue_action(e) raise e end; end

class TagsControllerTest < Test::Unit::TestCase
  # fixtures :tags

  def fsetup
    @controller = TagsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_truth
    assert true
  end
  
  def ftest_should_get_index
    get :index
    assert_response :success
    assert assigns(:tags)
  end

  def ftest_should_get_new
    get :new
    assert_response :success
  end
  
  def ftest_should_create_tags
    old_count = Tags.count
    post :create, :tags => { }
    assert_equal old_count+1, Tags.count
    
    assert_redirected_to tags_path(assigns(:tags))
  end

  def ftest_should_show_tags
    get :show, :id => 1
    assert_response :success
  end

  def ftest_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def ftest_should_update_tags
    put :update, :id => 1, :tags => { }
    assert_redirected_to tags_path(assigns(:tags))
  end
  
  def ftest_should_destroy_tags
    old_count = Tags.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Tags.count
    
    assert_redirected_to tags_path
  end
  
end
