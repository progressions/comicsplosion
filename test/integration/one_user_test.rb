require "#{File.dirname(__FILE__)}/../test_helper"

class OneUserTest < ActionController::IntegrationTest
  fixtures :users, :comics, :pages, :comments, :views

  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  def setup
    @jeff = users(:jeff)
    @prog = comics(:progressions)
  end
  
  # a user goes to the homepage, clicks on 'progressions' and 
  # views its default page
  def test_viewing_progressions
    get "/"
    assert_response :success
    assert_template 'comics/index'
    @comics = assigns(:comics)
    assert_select "div.comics", :count => 1 do
      assert_select "div.comic", :count => @comics.length
      assert_select "h3.name", :text => /Progressions/ do
        assert_select "a[href$=/comics/progressions]", :count => 1
      end
    end
    
    get "/comics/progressions"
    assert_response :success
    assert_template 'comics/show'
    @page = assigns(:page)
    assert_select "title", :text => /Progressions/
    assert_select "div.info", :count => 1
    assert_select "div.page", :count => 1 do
      assert_select 'a[href$=/comics/progressions?page=2]', :count => 1 do
        assert_select 'img#comic_page', :count => 1
      end
      assert_select "div.comments", :count => 1
    end
    assert_select "div.sidebar"
  end
end
