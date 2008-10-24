require File.dirname(__FILE__) + '/../test_helper'
require 'comments_controller'

# Re-raise errors caught by the controller.
class CommentsController; def rescue_action(e) raise e end; end

class CommentsControllerTest < Test::Unit::TestCase
  fixtures :comments, :comics, :users, :pages

  def setup
    @controller = CommentsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @prog = comics(:progressions)
    @jeff = users(:jeff)
    @prog_one = pages(:progressions_1)
  end

  def login user
    @request.session[:user] = user.id
  end
  

  def test_should_get_index
    get :index, :comic_id => @prog.alias
    
    assert_response :success
    assert assigns(:comments)
  end
  
  def test_should_create_comment
    login @jeff
    old_count = Comment.count
    old_prog_count = @prog.comments.count
    old_jeff_count = @jeff.comments.count
    xhr :post, :create, :comic_id => @prog.alias, :page => @prog_one, :comment => { :content => "This is an awesome comment!" }
    assert_equal old_count+1, Comment.count
    assert_equal old_prog_count+1, @prog.comments.count
    assert_equal old_jeff_count+1, @jeff.comments.count
    
    assert_redirected_to comic_path(:id => @prog.alias, :page => @prog_one.locate)
  end
  
  def test_should_not_create_comment
    old_count = Comment.count
    old_prog_count = @prog.comments.count
    post :create, :comic_id => @prog.alias, :page => @prog_one, :comment => { :content => "This is an awesome comment!" }
    assert_redirected_to signin_path
    assert_equal old_count, Comment.count
    assert_equal old_prog_count, @prog.comments.count
  end

  def ftest_should_show_comment
    get :show, :id => 1
    assert_response :success
  end

  def ftest_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def ftest_should_update_comment
    put :update, :id => 1, :comment => { }
    assert_redirected_to comment_path(assigns(:comment))
  end
  
  def test_should_destroy_comment
    old_count = Comment.count
    @comment = comments(:progressions_one)
    login @comment.created_by
    delete :destroy, :comic_id => @comment.comic, :id => @comment
    assert_equal old_count-1, Comment.count
    
    assert_redirected_to comic_path(:id => @comment.comic.alias, :page => @comment.page)
  end
  
  # user logged in is not the creator of the comic OR the comment
  # so they can't delete it
  def test_should_not_destroy_comment
    old_count = Comment.count
    @comment = comments(:progressions_one)
    login users(:cindy)
    delete :destroy, :comic_id => @comment.comic, :id => @comment
    assert_equal old_count, Comment.count
    
    assert_equal "You can't do that.", flash[:notice]
    assert_redirected_to comic_path(:id => @comment.comic.alias, :page => @comment.page)
  end
end
