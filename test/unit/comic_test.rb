require File.dirname(__FILE__) + '/../test_helper'

class ComicTest < Test::Unit::TestCase
  fixtures :comics, :users, :pages, :views

  def setup
    @prog = comics(:progressions)
    @jeff = users(:jeff)
  end

  def test_values
    assert_equal "Progressions", @prog.name
    assert_equal "progressions", @prog.alias
    assert_equal 10, @prog.pages.length
    assert_equal 5, @prog.live_pages.length
    
    @comic = Comic.find_by_alias_or_id("progressions")
    assert_equal @prog, @comic
  end
  
  def test_find_by_alias
    Comic.find(:all).each do |comic|
      new_comic = Comic.find_by_alias_or_id(comic.alias)
      assert_equal new_comic, comic
    end
  end
  
  def test_new_pages
    assert_equal @prog.live_pages.length, @prog.new_pages.length
    assert_equal 2, @prog.new_pages(:since => 10.days.ago).length
    assert_equal 3, @prog.new_pages(:since => 20.days.ago).length
    assert_equal 5, @prog.new_pages(:since => 1.month.ago).length
    
    assert_equal 2, @prog.new_pages(:since => 1.month.ago, :limit => 2).length
    assert_equal 3, @prog.new_pages(:since => 1.month.ago, :limit => 3).length
  end
  
  
  # this test shows that changing both the "live" value to true, and
  # the "published_on" to a date in the past will cause the comic to
  # appear in the user's "live_comics" array
  # 
  def test_live_with_date_and_boolean
    assert_equal 3, @jeff.comics.length
    assert_equal 3, @jeff.live_comics.length
    @chastity = comics(:chastity_towers)
    @chastity.live = true
    @chastity.published_on = 1.day.ago.to_s(:db)
    assert @chastity.save
    @jeff.reload
    assert_equal 3, @jeff.live_comics.length
  end
  
  # with only the date set to the past, the comic doesn't become "live"
  def test_live_with_date
    assert_equal 3, @jeff.comics.length
    assert_equal 3, @jeff.live_comics.length
    @chastity = comics(:chastity_towers)
    @chastity.live = false
    @chastity.published_on = 1.day.ago.to_s(:db)
    assert @chastity.save
    @jeff.reload
    assert_equal 2, @jeff.live_comics.length
  end
  
  # with only the boolean set to true, the comic doesn't become "live"
  def test_live_with_boolean
    assert_equal 3, @jeff.comics.length
    assert_equal 3, @jeff.live_comics.length
    @chastity = comics(:chastity_towers)
    @chastity.live = true
    @chastity.published_on = 1.day.from_now.to_s(:db)
    assert @chastity.save
    @jeff.reload
    assert_equal 2, @jeff.live_comics.length
  end
  
  # use the comic.locate method to find a given page's
  # page number.
  # 
  def should_locate page
    assert page.is_live?
    assert page.comic.is_live?
    assert_equal page, page.comic.locate(:page => page.locate)
  end
  
  # use the comic.locate method to find a given chapter's
  # page number.
  # 
  def should_locate page
    assert page.is_live?
    assert page.comic.is_live?
    assert_equal page, page.comic.locate(:page => page.locate)
  end
  
  # the locate method returns the page at that page number
  # in the comic's live pages.
  # 
  def test_locate
    Page.live_pages.each do |page|
      should_locate page
    end
    Comic.live_comics.each do |comic|
      comic.live_pages.each do |page|
        should_locate page
      end
    end
  end
  
  # check to make sure the set of Comic.live_comics is
  # the same as the set of comics which answer true to
  # is_live?
  # 
  def test_live
    @comics = Comic.find(:all)
    @live_comics = @comics.map { |comic| comic if comic.is_live? }.compact
    assert_equal @live_comics.length, Comic.live_comics.length
  end
  
  def test_update    
    assert_equal "progressions", @prog.alias
    @prog.alias = "jeff"
    assert @prog.save, @prog.errors.full_messages.join("; ")
    @prog.reload
    assert_equal "jeff", @prog.alias
  end
  
  def test_destroy_comic
    @page = @prog.pages.first
    @prog.destroy
    assert_raise(ActiveRecord::RecordNotFound) { Comic.find(@prog.id) }
    assert_raise(ActiveRecord::RecordNotFound) { Page.find(@page.id) }
  end
  
  def test_destroy_user
    assert_equal @jeff, @prog.created_by
    @page = @prog.pages.first
    @jeff.username = "not_jeff"
    assert @jeff.save, @jeff.errors.full_messages.join("; ")
    assert @jeff.destroy
    assert_raise(ActiveRecord::RecordNotFound) { Comic.find(@prog.id) }
    assert_raise(ActiveRecord::RecordNotFound) { Page.find(@page.id) }    
  end
  
  def test_validate_alias
    @prog.alias = ""
    assert !@prog.save
    assert_equal 2, @prog.errors.count
    assert_equal ["can't be blank", "should be letters, nums, dash, underscore only"], @prog.errors.on(:alias)
    @prog.alias = comics(:chastity_towers).alias
    assert !@prog.save 
    assert_equal 1, @prog.errors.count
    assert_equal "has already been taken", @prog.errors.on(:alias)
  end
  
  def test_validate_name
    @prog.name = ""
    assert !@prog.save
    assert_equal 1, @prog.errors.count
    assert_equal "can't be blank", @prog.errors.on(:name)
  end
  
end
