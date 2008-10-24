require File.dirname(__FILE__) + '/../test_helper'
require 'comics_controller'

# Re-raise errors caught by the controller.
class ComicsController; def rescue_action(e) raise e end; end

class ComicsControllerTest < Test::Unit::TestCase
  fixtures :comics, :pages, :users, :views

  def setup
    @controller = ComicsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @prog = comics(:progressions)
    @jeff = users(:jeff)
    @prog_one = pages(:progressions_1)
  end

  def login user
    @request.session[:user] = user.id
  end
  
  def must_login options={}
    options[:as] ||= @jeff
    options[:template] ||= 'index'
      
    yield
    assert_redirected_to :signin_path
    
    login options[:as]
    yield    
    assert_response :success
    assert_template options[:template]
    assert_equal options[:as], User.current_user
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:comics)
    assert_template 'index'
  end

  def get_page options={}
    get :show, options
    assert_response :success
    assert_template 'show'
    assert_select "div.page", :count => 1 do
      assert_select "img.page", :count => 1
    end
    assert_select "div.sidebar", :count => 1 do
      assert_select "div.nav", :count => 1
      assert_select "img.user_image", :count => 1
    end
  end
  
  def test_should_show_comic
    get_page :id => @prog.alias
  end
  
  def show_all_pages comic
    get_page :id => comic.alias
    comic.live_pages.each do |page|
      get_page :id => comic.alias, :page => page.locate
    end
  end
  
  def test_show_all_comics_pages
    comics = Comic.find(:all)
    comics.each do |comic|
      show_all_pages comic if comic.is_live?
    end
  end
  
  
  def test_should_show_comic_and_comments
    get_page :id=> @prog.alias, :page => 1    
    @comments = assigns(:comments)
    assert_select "div.page", :count => 1 do
      assert_select "div.comments", :count => 1 do
        assert_select "div.comment", :count => @comments.length
        assert_select "img.user_image", :count => @comments.length
        assert_select "div.new_comment", :count => 1 do
          assert_select "a", :text => "Sign in", :count => 1
        end
      end
    end
  end
  
  def show_comments_with_login user
    login user
    get_page :id=> @prog.alias, :page => 1    
    assert_equal user, User.current_user    
    @comments = assigns(:comments)
    
    assert_select "div.page", :count => 1 do
      assert_select "div.comments", :count => 1 do
        assert_select "div.comment", :count => @comments.length
        assert_select "img.user_image", :count => @comments.length
        assert_select "div.new_comment", :count => 1 do
          assert_select "textarea", :count => 1
        end
      end
    end
  end
  
  def test_show_comments_with_login
    User.find(:all).each do |user|
      show_comments_with_login user
    end
  end
  
  def invalid_page comic, page
    assert comic.is_live?
    assert page.to_i < 1 || page.to_i > comic.live_pages.length
    get :show, :id => comic.alias, :page => page
    assert_redirected_to comic_path(comic.alias)
    assert_equal "The page you are looking for could not be found.", flash[:notice]
  end
  
  def test_should_not_show_page
    invalid_page @prog, "frog"
    invalid_page @prog, -5
    invalid_page @prog, 0
    invalid_page @prog, @prog.live_pages.length + 1
    invalid_page @prog, @prog.live_pages.length + 10
    invalid_page @prog, @prog.live_pages.length + 100
  end
  
  def invalid_comic comic_alias
    get :show, :id => comic_alias, :page => 1
    assert_redirected_to home_path
    assert_equal "The comic you are looking for could not be found.", flash[:notice]
  end
  
  def test_could_not_show_comic
    invalid_comic "FRED"
    invalid_comic comics(:freds_funtime).alias  # this comic is not live
    invalid_comic "THISISNOTACOMICNAME"
    @prog.live = false
    assert @prog.save
    invalid_comic @prog.alias
  end
  
  def test_should_get_new
    must_login :as => users(:fred), :template => 'new' do
      get :new
    end
  end
  
  def test_should_create_comic
    login @jeff
    old_count = Comic.count
    post :create, :comic => {      
      :name => "Brand New Comics!",
      :alias => "brandnew",
      :description => "It's a comic about brand newness!",
      :byline => "by Arthur Artist and William Writer",
      :schedule => "monthly",
      :copyright => "Copyright 2007 by A&W",
      :published_on => 1.week.from_now,
      :live => true,
      :show_blog => false,
      :show_comments => false }
    assert_equal old_count+1, Comic.count
    
    assert_redirected_to new_page_path(:comic_id => assigns(:comic).alias)
  end
  
  def test_should_not_create_comic
    login @jeff
    old_count = Comic.count
    post :create, :comic => {      
      :name => "Brand New Comics!",
      :alias => @prog.alias,
      :description => "It's a comic about brand newness!",
      :byline => "by Arthur Artist and William Writer",
      :schedule => "monthly",
      :copyright => "Copyright 2007 by A&W",
      :published_on => 1.week.from_now,
      :live => true,
      :show_blog => false,
      :show_comments => false }
    assert_equal old_count, Comic.count
    
    assert_response :success
    assert_template 'new'
    
    assert_select "title", /New comic/, :count => 1
    assert_select "h1", "Enter basic information about your comic"
    assert_select "div#errorExplanation", :count => 1 do 
      assert_select "h2", "1 error prohibited this comic from being saved"
      assert_select 'li', "Alias has already been taken"
    end
  end
  
  def test_increment_view_count
    old_count = @prog.view_count
    get :show, :id => @prog.alias, :page => 1
    assert_response :success
    assert_template 'show'
    @prog.reload
    assert_equal old_count+1, @prog.view_count
    assert @request.session["page_#{@prog_one.id}"]
    get :show, :id => @prog.alias, :page => 1
    @prog.reload
    assert_equal old_count+1, @prog.view_count
  end
  
  def test_increment_view
    @view_one = views(:view_one)
    old_count = @view_one.views
    
    login @jeff
    get :show, :id => @prog.alias, :page => 1
    
    assert_response :success
    assert_template 'show'
    
    @view_one.reload
    assert_equal old_count+1, @view_one.views
  end
  
  def test_create_view
    @view_one = views(:view_one)
    @view_one.destroy    
    assert_raise(ActiveRecord::RecordNotFound) { View.find(@view_one.id) }
    
    login @jeff
    get :show, :id => @prog.alias
    assert_response :success
    
    @view_one = @prog_one.views.find(:first, :conditions => {:created_by => @jeff})
    assert_equal 1, @view_one.views
    
    get :show, :id => @prog.alias    
    assert_response :success
    
    @view_one.reload
    assert_equal 2, @view_one.views
  end
  
  def test_create_view_different_user
    # if cindy has viewed page @prog_one, find the view and delete it
    @cindy = users(:cindy)    
    @view_one = @cindy.page_view(@prog_one)  
    @view_one.destroy if @view_one
    assert_raise(ActiveRecord::RecordNotFound) { View.find(@view_one.id) } if @view_one
    
    # cindy signs in, views page @prog_one
    login @cindy
    get :show, :id => @prog.alias
    assert_response :success
    
    # get the view of @prog_one by cindy
    @view_one = @prog_one.views.find(:first, :conditions => {:created_by => @cindy})
    assert_not_nil @view_one
    assert_equal 1, @view_one.views
    
    old_cindy_count = @cindy.views.length
    old_count = View.count
    
    # she views @prog_one again
    get :show, :id => @prog.alias    
    assert_response :success
    
    # the view has incremented.  new view hasn't been added
    @view_one.reload
    assert_equal 2, @view_one.views
    assert_equal old_cindy_count, @cindy.views.length
    assert_equal old_count, View.count
  end
  
  def test_big_page_number
    big_num = @prog.live_pages.length + 1
    get :show, :id => 'progressions', :page => big_num
    assert_redirected_to comic_path(@prog.alias)
  end
  
  def test_show_other_comics
    get :show, :id => @prog.alias
    assert_response :success
    @other_comics = assigns(:other_comics)
    assert_equal 2, @other_comics.length
    
    # assert_select "div.other_comics", :count => 1     
    
    @chastity = comics(:chastity_towers)
    @chastity.live = false
    assert @chastity.save
    
    get :show, :id => @prog.alias
    assert_response :success
    assert_template 'show'
    @other_comics = assigns(:other_comics)
    assert_equal 1, @other_comics.length
    
    assert_select "div.sidebar", :count => 1 do
      assert_select "div.other_comics", :count => 1 do
        assert_select "div", :count => @other_comics.length
      end
    end
  end
  
  def test_should_get_manage
    must_login :template => 'manage' do
      get :manage, :id => @jeff.alias
    end
  end
  
  def test_should_get_edit
    must_login :template => 'edit' do
      get :edit, :id => 1
    end
  end
    
  def test_should_update_comic
    login @jeff
    put :update, :id => 1, :comic => { :alias => "newalias" }
    assert_redirected_to home_path
  end
  
  def test_should_destroy_comic
    login @jeff
    old_count = Comic.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Comic.count
    
    assert_redirected_to comics_path
  end
end
