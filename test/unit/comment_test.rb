require File.dirname(__FILE__) + '/../test_helper'

class CommentTest < Test::Unit::TestCase
  fixtures :users, :comics, :pages, :comments
  
  def setup
    @jeff = users(:jeff)
    @prog = comics(:progressions)
    @prog_one = comments(:progressions_one)
  end

  def test_basic
    assert_equal @jeff, @prog_one.created_by
    assert_equal @prog, @prog_one.comic
    assert_equal 4, @prog.comments.length
    assert_equal 2, @prog.new_comments.length
  end
  
  def test_create
    @page = @prog.live_pages.first
    assert @comment = Comment.new(:content => "This is a comment about Progressions!", :page_id => @page, :comic_id => @prog, :created_by => @jeff, :updated_by => @jeff)
    assert @comment.save, @comment.errors.full_messages.join("; ")
    assert_equal @prog, @comment.comic
    assert_equal 5, @prog.comments.length
    assert_equal 3, @prog.new_comments.length
  end
  
  def test_delete
    @prog_one.destroy
    assert_raise(ActiveRecord::RecordNotFound) { Comment.find(@prog_one.id) }  
    assert_equal 3, @prog.comments.length
    assert_equal 2, @prog.new_comments.length
  end
  
  def test_delete_newer
    @prog_four = comments(:progressions_four)
    @prog_four.destroy
    assert_raise(ActiveRecord::RecordNotFound) { Comment.find(@prog_four.id) }  
    assert_equal 3, @prog.comments.length
    assert_equal 1, @prog.new_comments.length
  end
  
  def test_validate
    @prog_one.content = ""
    assert !@prog_one.save, @prog_one.errors.full_messages.join("; ")
    assert_equal 1, @prog_one.errors.count
    assert_equal "can't be blank", @prog_one.errors.on(:content)
  end
end
