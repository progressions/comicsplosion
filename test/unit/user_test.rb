require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  fixtures :users, :views, :pages, :comics
  
  def setup
    @jeff = users(:jeff)
    @fred = users(:fred)
    @susan = users(:susan)
    @cindy = users(:cindy)
  end
  
  def verify_password(test_password, password_hash, salt=SALT)
    User.encrypt(test_password, salt) == password_hash
  end

  def test_values
    assert verify_password('secret', @jeff.password_hash)
    assert "funky" != @jeff.password
    assert_equal users(:jeff).alias, @jeff.alias
    assert_equal users(:jeff).bio, @jeff.bio
  end
  
  def test_create_susan
    assert_equal "susan", @susan.username
    assert verify_password('secret', @susan.password_hash)
    @susan.password = "password"
    assert @susan.save, @susan.errors.full_messages.join("; ")
    assert_equal "password", @susan.password
    @susan.reload
    assert verify_password('password', @susan.password_hash, @susan.password_salt)
  end
  
  def test_update
    assert_equal "progressions", @jeff.alias
    @jeff.alias = "jeff"
    assert @jeff.save, @jeff.errors.full_messages.join("; ")
    @jeff.reload
    assert_equal "jeff", @jeff.alias
  end
  
  def test_alias
    assert_equal "progressions", @jeff.alias
    assert_equal "jeff", @jeff.username
    @jeff.alias = nil
    assert_equal "jeff", @jeff.alias
  end
  
  def test_fullname
    assert_equal "Jeff Coleman", @jeff.fullname
    @jeff.firstname = "Isaac"
    assert_equal "Isaac Coleman", @jeff.fullname
    @jeff.lastname = "Priestley"
    assert_equal "Isaac Priestley", @jeff.fullname
    @jeff.firstname = nil
    assert_equal "Priestley", @jeff.fullname
    @jeff.lastname = nil
    assert_equal "jeff", @jeff.fullname
  end
  
  def test_remove_image
    assert_equal "progressions", @jeff.alias
    @jeff.image = nil
    assert @jeff.save, @jeff.errors.full_messages.join("; ")
    @jeff.reload
    assert_equal nil, @jeff.image
  end
  
  def test_destroy
    assert_raise(RuntimeError) { @jeff.destroy }
    @fred.destroy
    assert_raise(ActiveRecord::RecordNotFound) { User.find(@fred.id) }
  end
  
  def test_validate_password_length
    assert verify_password('secret', @jeff.password_hash)
    @jeff.password = "lol"
    assert !@jeff.save, @jeff.errors.full_messages.join("; ")
    assert_equal 1, @jeff.errors.count
    assert_equal "is too short (minimum is 6 characters)", @jeff.errors.on(:password)
    @jeff.password ="waytoolongpassword"
    assert !@jeff.save, @jeff.errors.full_messages.join("; ")
    assert_equal 1, @jeff.errors.count
    assert_equal "is too long (maximum is 10 characters)", @jeff.errors.on(:password)
    
    @jeff.password = "password"
    assert @jeff.save, @jeff.errors.full_messages.join("; ")
    assert verify_password('password', @jeff.password_hash, @jeff.password_salt)
  end
    
  def test_validate_password_format
    assert verify_password('secret', @jeff.password_hash)
    @jeff.password = "sec ret"
    assert !@jeff.save, @jeff.errors.full_messages.join("; ")
    assert_equal 1, @jeff.errors.count
    @jeff.password = '234%@#$'
    assert @jeff.save, @jeff.errors.full_messages.join("; ")
    assert verify_password('234%@#$', @jeff.password_hash, @jeff.password_salt)
  end
  
  def test_validate_alias
    @jeff.alias = ""
    assert !@jeff.save
    assert_equal 2, @jeff.errors.count
    # assert_equal ["should be letters, nums, dash, underscore only", "can't be blank"], @jeff.errors.on(:alias)
    @jeff.alias = @fred.alias
    assert !@jeff.save, @jeff.errors.full_messages.join("; ")
    assert_equal "has already been taken", @jeff.errors.on(:alias)
  end
  
  def test_validate_username
    assert_equal "jeff", @jeff.username
    @jeff.username = "j eff"
    assert !@jeff.save, @jeff.errors.full_messages.join("; ")
    assert_equal "should be letters, nums, dash, underscore only", @jeff.errors.on(:username)    
  end
  
  def test_validate_email
    assert_equal users(:jeff).email, @jeff.email
    @jeff.email = "myaddress"
    assert !@jeff.save, @jeff.errors.full_messages.join("; ")
    assert_equal "is not a valid email address", @jeff.errors.on(:email)
  end
  
  def test_add_view
    @prog_one = pages(:progressions_1)
    view = @cindy.find_or_create_view(:page => @prog_one)    
    @cindy.reload
    view_two = @cindy.page_view @prog_one
    assert_equal view, view_two
    
    view_three = @cindy.find_or_create_view(:page => @prog_one)
    assert_equal view, view_three
  end

end
