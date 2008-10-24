require File.dirname(__FILE__) + '/../test_helper'

class FavoriteTest < Test::Unit::TestCase
  fixtures :favorites, :users, :comics, :pages
  
  def setup
    @jeff = users(:jeff)
    @page_one = pages(:progressions_1)
    @fave_one = favorites(:one)
  end

  def test_basics
    assert @page_one.is_favorite_of(@jeff)
    fave = @jeff.favorites.find_by_page_id(@page_one)
    assert fave
  end
  
  def test_favorites
    @jeff = users(:jeff)
    old_jeff_count = @jeff.favorites.length   
    old_page_count = @page_one.favorites.length
    
    User.current_user = @jeff
    @new_fave = @page_one.favorites.new()
    
    assert @new_fave.save, @new_fave.errors.full_messages.join("; ")
    @jeff.reload
    @page_one.reload
    assert_equal old_jeff_count+1, @jeff.favorites.length
    assert_equal old_page_count+1, @page_one.favorites.length
  end
  
  def toggle_favorite user, page    
    User.current_user = user
    fave = page.is_favorite?
    page.toggle_favorite
    page.reload
    assert_equal !fave, !(!page.is_favorite?)
  end
  
  def test_toggle
    Page.find(:all).each do |page|
      toggle_favorite @jeff, page if page.is_live?
    end
  end
end
