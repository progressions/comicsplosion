require 'digest/sha1'

class User < ActiveRecord::Base    
  validates_presence_of :password, :if => :validate_password?
  validates_confirmation_of :password, :if => :validate_password?
  validates_length_of :password, { :in => 6..10, :if => :validate_password? }
  validates_format_of :password, { :with =>  /\A[\S]+\Z/, :message => "cannot contain any spaces", :if => :validate_password? }
  
  validates_format_of :username, :alias, :with => /\A[\w\-]+\Z/, :message => "should be letters, numbers, dash, underscore only"
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "is not a valid email address"

  validates_presence_of :username, :on => :create
  validates_presence_of :alias
  validates_uniqueness_of :username, :alias, :email
  
  attr_accessor :password, :password_confirmation, :new_password
  cattr_accessor :current_user
  
  # the user's image is stored in 3 ways:
  # [original]    don't do anything with the original yet, 
  #               but that may change.
  # [thumb]       constrained to be exactly a 25 by 25px square.
  #               The thumbnail is used on the "comments" view 
  #               and in the upper right corner of every comic
  #               the user creates.
  # [medium]      constrained to be exactly a 50 by 50px square.
  #               The medium is used on the comments list in the
  #               main comic view.
  # 
  # file_column :image, :magick => { 
#      :versions => { "thumb" => "25x25!", "medium" => "50x50!" }
#    } 
  acts_as_attachment :content_type => :image, 
                 :storage => :file_system,
                 :thumbnail_class => "Thumbnail",
                 :thumbnails => { :thumb => '25x25!', :medium => '50x50!' }

  validates_as_attachment
  
  has_many :permissions, :dependent => :destroy
  has_many :roles, :through => :permissions
  
  has_many :views, :class_name => "View", :foreign_key => "created_by", :dependent => :destroy
  has_many :favorites, :class_name => "Favorite", :foreign_key => "created_by"
  
  has_many :pages, :class_name => "Page", :foreign_key => "created_by", :dependent => :destroy
  
  # live pages are defined as follows:
  # - the page's _live_ attribute is true
  # - the page's published_on date has passed.
  # 
  # The pages are ordered by their position in the acts_as_list, 
  # but this position can't serve as their page number because 
  # the position scope covers all pages, live or not.
  # 
  has_many :live_pages, :class_name => "Page", :foreign_key => "created_by", :order => :position, :conditions => ["live = 1 AND published_on <= ?", Time.now], :dependent => :destroy
  
  has_many :comics, :class_name => "Comic", :foreign_key => "created_by", :order => "last_updated DESC", :dependent => :destroy
  has_many :live_comics, :class_name => "Comic", :foreign_key => "created_by", :order => "last_updated DESC", :conditions => ["live = 1 AND published_on <= ?", Time.now]
 
  has_many :blogs, :class_name => "Blog", :foreign_key => "created_by", :dependent => :destroy  
  has_many :comments, :class_name => "Comment", :foreign_key => "created_by", :dependent => :destroy
  
  # When a new object is created, flag its
  # password as needing confirmation.
  # 
  def initialize(attributes = nil)
    super
    @new_password = true
  end
  
  # Once the object has been saved, the
  # password doesn't need confirmation anymore.
  # 
  after_save '@new_password = false'
  
  # A more robust system will be necessary, but for now
  # we prevent the destruction of the "jeff" user, so 
  # there is at least one admin.
  # 
  def before_destroy
    raise "Can't destroy jeff" if self.username == "jeff"
  end
  
  # The validate_password? method is used by
  # the password validations to indicated whether
  # the password needs confirmation or not.
  # 
  # This is significant since it's possible to edit
  # the user info without editing the password.  In
  # such cases, @new_password doesn't get flagged as
  # true so we don't need to validate the password.
  # 
  def validate_password?
    @new_password
  end
  
  # This method changes the password.
  # 
  def change_password(pass, confirm = nil)
    self.password = pass
    self.password_confirmation = confirm.nil? ? pass : confirm
    @new_password = true
  end
  
  # This Class method authenticates the user
  # given the username and password.  It returns
  # the user object if it passes validation, returns
  # nil otherwise.
  # 
  def self.authenticate(username, password)
    user = User.find(:first, 
      :conditions => ['username = ?', username])
    user unless user.blank? ||
        User.encrypt(password, user.password_salt) != user.password_hash
  end
  
  # Returns the Favorite object for this user
  # and a given page, if it exists.
  # 
  def has_favorite page
    self.favorites.find_by_page_id(page)
  end
  
  # Returns the password, while it's still
  # stored in memory for changing the password.
  # 
  def password
    @password
  end

  # Assigns the user a new password, encoding it first and storing 
  # the encoded password and salt in the User model. 
  # 
  def password=(pass)
    @new_password = true
    @password = pass
    salt = [Array.new(6){rand(256).chr}.join].pack("m").chomp
    self.password_salt, self.password_hash = salt, User.encrypt(pass, salt)
  end
  
  # The View model, like the Favorite, must be unique for
  # its given user and page.  The View model is complicated
  # because it's polymorphic and can apply to a Comic or a Page.
  # 
  # This method adds a view to this page for the current user, 
  # if one doesn't exist, and returns the existing view if it does.
  # 
  def add_view page
    find_or_create_view(:page => page)
  end
  
  # Finds or creates a View object for this user and the
  # specified page.
  # 
  def find_or_create_view options
    if options.is_a? Hash
      View.find_or_create_page(:user => self, :page => options[:page]) if options[:page]
    end
  end
  
  # Returns the View object for this user and the specified
  # page.
  # 
  def page_view page
    self.views.find(:first, :conditions => ["resource_type = 'Page' and resource_id = ?", page.id ])
  end
  
  # Returns this user's full name, which is its _firstname_ 
  # and its _lastname_ together.  If that's blank, return
  # the user's username.
  # 
  def fullname
    full = [self.firstname, self.lastname].join(' ').strip
    unless full.blank?
      return full
    else
      return self.username
    end
  end
  
  # If this user doesn't have an alias, return its
  # username.
  # 
  # (All users must have an alias, so this method can
  # be phased out.)
  # 
  def alias
    super || self.username
  end
  
  # Role management methods
  
  def is_admin?
    has_role? :admin
  end
  
  def is_creator?
    has_role? :creator
  end
  
  def is_reader?
    has_role? :reader
  end
  
  # Takes a _role_ as parameter and returns true if
  # this user has that role.
  # 
  def has_role? role
    r = Role.find_by_name(role.to_s)
    self.roles.include? r
  end
  
  # Encrypts password with a given salt.
  # 
  def self.encrypt(password, salt)
    string_to_hash = password + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end
end