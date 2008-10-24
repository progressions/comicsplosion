require File.dirname(__FILE__) + '/../test_helper'
require 'pages_controller'

# get us an object that represents an uploaded file
def uploaded_file(path, content_type="application/octet-stream", filename=nil)
  filename ||= File.basename(path)
  t = Tempfile.new(filename)
  FileUtils.copy_file(path, t.path)
  (class << t; self; end;).class_eval do
    alias local_path path
    define_method(:original_filename) { filename }
    define_method(:content_type) { content_type }
  end
  return t
end

# a JPEG helper
def uploaded_jpeg(path, filename=nil)
  uploaded_file(path, 'image/jpeg', filename)
end

# a GIF helper
def uploaded_png(path, filename=nil)
  uploaded_file(path, 'image/png', filename)
end

# Re-raise errors caught by the controller.
class PagesController; def rescue_action(e) raise e end; end

class PagesControllerTest < Test::Unit::TestCase
  fixtures :pages
  fixtures :comics
  fixtures :users

  def setup
    @controller = PagesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @prog_one = pages(:progressions_1)
    @prog = comics(:progressions)
    @jeff = users(:jeff)
  end

  def login user
    @request.session[:user] = user.id
  end

  def test_should_get_new
    login @jeff
    get :new, :comic_id => @prog.alias
    assert_response :success
    assert_template 'new'
  end
  
  def test_should_get_favorites
    get :favorites, :comic_id => @prog.alias, :id => @prog_one 
    
    assert_response :success
    assert_template 'favorites'
    
    @favorites = assigns(:favorites)
    
    assert_select 'title', :count => 1, :text => /Favorites/
    assert_select 'div.image', :count => 1
    assert_select 'div.favorites', :count => 1 do
      assert_select 'div.favorite', :count => @favorites.length
    end
  end
  
  def test_should_create_page
    login @jeff
    old_count = Page.count
    old_prog_count = @prog.pages.length
    
    post :create, :comic_id => @prog.alias, :page => { 
      :id => 1,
      :name => "page 1",
      :image => fixture_file_upload("files/001.jpg", 'image/jpg'),
      :description => "This is the description.",
      :published_on => 1.week.from_now,
      :live => true
    }
    assert_redirected_to edit_page_path(:comic_id => @prog.alias, :id => assigns(:page))
    
    assert_equal old_count+1, Page.count
    @prog.reload
    assert_equal old_prog_count+1, @prog.pages.length
    
    assert_redirected_to edit_page_path(:comic_id => @prog.alias, :id => assigns(:page))
  end
  
  def test_should_not_create_page_no_image
    login @jeff
    old_count = Page.count
    old_prog_count = @prog.pages.length
    
    post :create, :comic_id => @prog.alias, :page => { 
      :id => 1,
      :name => "page 1",
      # :image => fixture_file_upload("files/001.jpg", 'image/jpg'),
      :description => "This is the description.",
      :published_on => 1.week.from_now,
      :live => true
    }
    assert_equal old_count, Page.count
    assert_equal old_prog_count, @prog.pages.length
    
    assert_response :success
    assert_template 'new'
    
    assert_select "title", /Add pages/, :count => 1
    assert_select "h1", "Upload a page to #{@prog.name}"
    assert_select "div#errorExplanation", :count => 1 do 
      assert_select "h2", "1 error prohibited this page from being saved"
      assert_select 'li', "Image can't be blank"
    end
  end
  
  def test_should_not_create_page
    old_count = Page.count
    post :create, :comic_id => @prog.alias, :page => { 
      :id => 1,
      :name => "page 1",
      :image => fixture_file_upload("files/001.jpg", 'image/jpg'),
      :description => "This is the description.",
      :published_on => 1.week.from_now,
      :live => true
    }
    assert_equal old_count, Page.count
    
    assert_redirected_to signin_path
  end

  def show_page page
    get :show, :comic_id => page.comic.alias, :id => page
    assert_redirected_to comic_path(:id => page.comic.alias, :page => page.locate)
  end
  
  def test_show_all_pages
    Page.find(:all).each do |page|
      show_page page if page.is_live?
    end
  end
  
  def test_should_not_show_page
    get :show, :comic_id => @prog.alias, :id => 0
    assert_redirected_to home_path
    assert_equal "The page you are looking for could not be found.", flash[:notice]
    get :show, :comic_id => @prog.alias, :id => pages(:progressions_6)
    assert_redirected_to home_path
    assert_equal "The page you are looking for could not be found.", flash[:notice]
  end
  
  def dont_show_page page
    get :show, :comic_id => page.comic.alias, :id => page.id
    assert_redirected_to home_path
    assert_equal "The page you are looking for could not be found.", flash[:notice]
  end
  
  def test_dont_show_pages
    Page.find(:all).each do |page|
      dont_show_page page if !page.is_live?
    end
  end
  
  def test_add_favorite_no_login
    assert_equal 2, @jeff.favorites.length
    post :favorite, :comic_id => @prog.alias, :id => @prog_one
    
    assert_redirected_to :signin_path
    @jeff.reload
    assert_equal 2, @jeff.favorites.length
  end
  
  def test_add_favorite
    login @jeff
    assert_equal 2, @jeff.favorites.length
    post :favorite, :comic_id => @prog.alias, :id => pages(:progressions_4)
    
    assert_response :success
    @jeff.reload
    assert_equal 3, @jeff.favorites.length
  end
  
  def add_favorite user, page
    login user
    show_page page
    
    # make sure it's not already a favorite
    # page.remove_favorite_of user if page.is_favorite_of user
    page.remove_favorite if page.favorite?
    
    user.reload
    page.reload
    
    old_count = user.favorites.length
    old_page_count = page.favorites.length
    old_faves_count = Favorite.count
    
    post :favorite, :comic_id => page.comic.alias, :id => page
    
    assert user, User.current_user
    user.reload
    page.reload
    
    assert_equal old_count+1, user.favorites.length
    assert_equal old_page_count+1, page.favorites.length
    assert_equal old_faves_count+1, Favorite.count
  end
  
  def test_add_faves_to_all
    Page.find(:all).each do |page|
      add_favorite(@jeff, page) if page.is_live?
    end
  end      

  def test_should_get_edit
    login @jeff
    get :edit, :comic_id => @prog.alias, :id => 1
    assert_response :success
  end
  
  def test_should_not_get_edit
    get :edit, :comic_id => @prog.alias, :id => 1
    assert_redirected_to signin_path
  end
  
  def test_should_update_page
    login @jeff
    put :update, :comic_id => @prog_one.comic.alias, :id => @prog_one, :page => { :name => "It's a page" }
    assert_redirected_to pages_path(:comic_id => assigns(:page).comic.alias)
    # assert_template 'edit'
  end
  
  def test_should_update_page_image
    login @jeff
    put :update, :comic_id => @prog_one.comic.alias, :id => @prog_one, :page => { :name => "It's a page",
      :image => fixture_file_upload("files/002.jpg", 'image/jpg') }
    @page_one = Page.find(@prog_one.id)
    assert_equal "It's a page", @page_one.name      
    
    assert_redirected_to pages_path(:comic_id => assigns(:page).comic.alias)
    assert_equal "Page was successfully updated.", flash[:notice]
  end
  
  def test_should_not_update_page
    put :update, :comic_id => @prog.alias, :id => 1, :page => { :name => "It's a page" }
    assert_redirected_to signin_path
  end  
  
  def test_should_destroy_page
    login @jeff
    old_count = Page.count
    delete :destroy, :comic_id => @prog.alias, :id => 1
    assert_equal old_count-1, Page.count
    
    assert_redirected_to :controller => 'comics', :action => 'list_pages', :id => @prog
  end
  
  def test_should_not_destroy_page
    old_count = Page.count
    delete :destroy, :comic_id => @prog.alias, :id => 1
    assert_equal old_count, Page.count
    assert_redirected_to signin_path
  end
end
