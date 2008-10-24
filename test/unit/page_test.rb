require File.dirname(__FILE__) + '/../test_helper'

class PageTest < Test::Unit::TestCase
  fixtures :comics, :users, :pages, :views, :favorites

  def setup
    @jeff = users(:jeff)
    @prog = comics(:progressions)
    @prog_one = pages(:progressions_1)
  end
  
  def test_basics
    assert_equal "page 1", @prog_one.name
    assert @prog_one.live?
    assert @prog_one.is_live?
  end
  
  def test_create
    old_count = Page.count
    old_prog_count = @prog.pages.length
    @page = Page.create(
      :name => "page ZERO",
      :uploaded_data => fixture_file_upload("files/001.jpg", 'image/jpg'),
      :description => "This is the description.",
      :published_on => 1.week.from_now,
      :live => true,
      :comic_id => @prog,
      :created_by => @jeff,
      :updated_by => @jeff
    )
    assert @page.save
    assert_equal old_count+1, Page.count
    @prog.reload
    assert_equal old_prog_count+1, @prog.pages.length
  end
  
  def test_create_no_image
    old_count = Page.count
    old_prog_count = @prog.pages.length
    @page = Page.create(
      :name => "page ZERO",
      # :image => fixture_file_upload("files/001.jpg", 'image/jpg'),
      :description => "This is the description.",
      :published_on => 1.week.from_now,
      :live => true,
      :comic_id => @prog,
      :created_by => @jeff,
      :updated_by => @jeff
    )
    assert !@page.save, @page.errors.full_messages.join("; ")
    assert_equal 5, @page.errors.count
    # assert_equal "can't be blank", @page.errors.on(:image)
    
    assert_equal old_count, Page.count
    assert_equal old_prog_count, @prog.pages.length
  end
  
  def test_favorites
    faves = Favorite.find(:all, :conditions => ["page_id = ?", @prog_one])
    assert_equal faves.length, @prog_one.favorites.length
    assert_equal faves, @prog_one.favorites
  end
  
  def test_is_live
    @prog_eight = pages(:progressions_8)
    assert @prog_eight.live?
    assert @prog_eight.published_on > Time.now
    assert !@prog_eight.is_live?
  end
  
  # check to make sure the set of Comic.live_comics is
  # the same as the set of comics which answer true to
  # is_live?
  # 
  def test_live
    @pages = Page.find(:all)
    @live_pages = @pages.map { |p| p if p.is_live? }.compact
    assert_equal @live_pages.length, Page.live_pages.length
  end
  
  # exhaustively test the page's locate and
  # navigation utility methods
  # 
  def locate page
    assert page.is_live?
    
    @comic = page.comic
    @live_pages = @comic.live_pages
    
    @page_num = @live_pages.index(page)+1
    assert_equal @page_num, page.locate
    
    if @page_num == 1
      assert page.first?
      assert !page.last?
      assert_equal @page_num+1, page.next
      assert_equal nil, page.previous
    elsif @page_num == @live_pages.length
      assert !page.first?
      assert page.last?
      assert_equal nil, page.next
      assert_equal @page_num-1, page.previous    
    else
      assert !page.first?
      assert !page.last?
      assert_equal @page_num+1, page.next
      assert_equal @page_num-1, page.previous      
    end
  end
  
  # test every live page to make sure its
  # basic locate and navigation utility 
  # methods are working properly.
  # 
  def test_locate_pages
    Page.live_pages.each do |page|
      locate page
    end
  end
  
  def test_locate
    assert_equal 1, @prog_one.locate
    assert_equal 5, pages(:progressions_5).locate
    
    assert_equal false, pages(:progressions_6).locate
  end
  
  def test_update
    @prog_three = pages(:progressions_3)
    @prog_three.live = false
    assert @prog_three.save
  end
  
  def test_update_live_locate
    test_update
    assert_equal 1, @prog_one.locate
    assert_equal 4, pages(:progressions_5).locate
  end
  
  def test_update_date_locate
    @prog_three = pages(:progressions_3)
    @prog_three.published_on = 2.weeks.from_now
    assert @prog_three.save
  end
  
  def test_destroy
    old_count = Page.count
    assert @prog_one.destroy
    assert_equal old_count-1, Page.count
  end
end
