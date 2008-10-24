require File.dirname(__FILE__) + '/../test_helper'

class RoutingTest < Test::Unit::TestCase
  
  def test_generates
    assert_generates("/comics", {:controller => 'comics'})
    assert_generates("/comics/progressions", {:controller => 'comics', :action => 'show', :id => 'progressions'})
  end
  
  def test_comments
    assert true
  end
  
  def test_recognizes
    assert_recognizes({:controller => 'comics', :action => 'index'}, "/comics")
  end
  
end
