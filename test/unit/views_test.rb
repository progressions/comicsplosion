require File.dirname(__FILE__) + '/../test_helper'

class ViewsTest < Test::Unit::TestCase
  fixtures :users
  fixtures :pages
  fixtures :comics
  fixtures :views
  
  def setup
    @view_one = views(:view_one)
  end

  def test_basics
    assert_equal views(:view_one).rating, @view_one.rating
    assert_equal views(:view_one).created_on, @view_one.created_on
  end
  
  def test_update
    old_count = @view_one.views
    assert_equal views(:view_one).views, @view_one.views
    @view_one.views += 1
    assert @view_one.save, @view_one.errors.full_messages.join("; ")
    assert_equal old_count+1, @view_one.views
  end
  
  def test_create
    old_count = View.count
    @cindy = users(:cindy)
    @prog = comics(:progressions)
    @page_one = pages(:progressions_3)
    
    old_views_for_page = @page_one.views.length
    old_views_for_jeff = @cindy.views.length
    
    @view_two = View.create(:created_by => @cindy, :views => 1, :rating => 4, :resource => @page_one)
    
    assert @view_two.save, @view_two.errors.full_messages.join("; ")
    assert_equal old_count+1, View.count   
    
    @page_one.reload
    @cindy.reload
    
    assert_equal old_views_for_page+1, @page_one.views.length
    assert_equal old_views_for_jeff+1, @cindy.views.length
  end
  
  def test_find_or_create_page
    @cindy = users(:cindy)
    @prog = comics(:progressions)
    @page_one = pages(:progressions_1)
    
    view = View.find_or_create_page(:user => @cindy, :page => @page_one)
    assert view.save, view.errors.full_messages.join("; ")
    old_count = view.views
    
    view_two = View.find_or_create_page(:user => @cindy, :page => @page_one)
    assert_equal view, view_two
    assert_equal old_count+1, view_two.views
  end
  
  def test_page_view
    @jeff = users(:jeff)
    @prog_one = pages(:progressions_1)
    @view_one = views(:view_one)
    assert_equal @view_one, @jeff.page_view(@prog_one)
  end
  
  def test_validate_view
    @page_one = pages(:progressions_1)
    @view = View.create(:created_by => @view_one.created_by, :views => 1, :rating => 4, :resource => @page_one)
    assert !@view.save, @view.errors.full_messages.join("; ")
    assert_equal "View must be unique", @view.errors.on_base
  end
  
  def test_destroy
    old_count = View.count
    @view_one.destroy
    assert_raise(ActiveRecord::RecordNotFound) { View.find(@view_one.id) }
    assert old_count-1, View.count
  end
end
