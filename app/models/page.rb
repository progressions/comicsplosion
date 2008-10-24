class Page < ActiveRecord::Base
  # sets a conditional root_page for use in testing.
  # 
  # A page's image is saved in four separate versions:
  # [the original]  the original (currently) is constrained to be
  #                 no wider than 780px.  This could change but currently
  #                 it's set that way to make sure the comic's page doesn't
  #                 overlap the right sidebar.
  # [tiny]          a 50 by 50 square image, cropped from the original to
  #                 possibly use in an overview or mosaic showing multiple
  #                 pages.  This hasn't got a specific use yet.
  # [thumb]         keeps the original's proportions, constrained to 150px 
  #                 on either side.
  # [medium]        keeps the original's proportions, constrained to 350px
  #                 on either side.    
  has_attachment :content_type => :image, 
                 :storage => :file_system,
                 :resize_to => '780x>',
                 :thumbnail_class => "Thumbnail",
                 :thumbnails => { :thumb => '150x150>', :medium => '350x350>' }

  validates_as_attachment
  

  belongs_to :comic
  has_one :chapter
  has_one :blog, :dependent => :destroy
  has_many :comments, :dependent => :destroy, :include => [:created_by]
  has_many :views, :as => :resource, :dependent => :destroy
  has_many :favorites, :dependent => :destroy
  
  acts_as_list :scope => :comic_id
  
  belongs_to :created_by, :class_name => "User", :foreign_key => "created_by"
  belongs_to :updated_by, :class_name => "User", :foreign_key => "updated_by"
  
  
  # This Class method returns all the live pages.
  # 
  # It's a bit flawed because it doesn't check the associated comic to
  # confirm that the comic is live.
  # 
  # TODO: Find a way to check if the associated comic is live.
  # 
  def self.live_pages
    Page.find(:all, :conditions => ["pages.live = 1 AND pages.published_on <= ?", Time.now], :include => [:comic, :comments, :created_by] )
  end
	
	# returns an ImageMagick object that can be manipulated 
	# to get information about the dimensions (or other 
	# properties) of this page's image file.
	# 
	# TODO: Find out how to construct ImageMagick
	# objects for the other varities--thumb, medium, etc.
	# 
	# CHANGED: This method is obsolete since the use of acts_as_attachment.
	# 
  def img
    Magick::Image::read(self.image).first
  end
  
  # returns the latest _count_ number of pages, in descending
  # order of publication date.
  # 
	def latest_published count
	  self.find(:all, :order => "published_on DESC", :conditions => "published_on > 0 AND live = 1", :limit => count )
	end
	
	# a page is only live if:
	# - its comic is live
	# - its _live_ value is true
	# - its publication date has passed.
	# 
	def is_live?
	  self.comic.is_live? and self.live? and self.published_on <= Time.now
	end
	
	# return this page's page number relative to its
	# comic.  The page number differs from the page's _id_ 
	# attribute in two ways:
	# - only live pages have page number
	# - pages can be reordered, changing their position
	# 
	def locate
	  i = self.comic.live_pages.index(self)
	  i ? (i + 1) : false
	end
	
	# returns true if the comic is first in
	# the context of its comic's live pages
	# 
	def first?
	  locate == 1
	end
	
	# returns true if the comic is last in
	# the context of its comic's live pages
	# 
	def last?
	  locate == self.comic.live_pages.length
	end
	
	# returns either the page number of the 
	# previous page (in the context of its 
	# comic's live pages) or nil if this page
  # is the first.
  # 
	def previous
	  first? ? nil : locate - 1
	end
	
	# returns either the page number of the 
	# next page (in the context of its 
	# comic's live pages) or nil if this page
  # is the last.
  # 
  def next
    last? ? nil : locate + 1
  end
  
  # Highest-level Favorite utility methods:
  # 
  # The most basic is toggle_favorite.  In most 
  # cases, simply call page.toggle_favorite to 
  # change the status of the page for the currently
  # signed-in user.
  # 
  # Ask page.is_favorite? if you need to know the
  # favorite status for the current user.
  # 
  
	# to toggle the 'favorite' status of this page 
	# for the current user
	# 
	def toggle_favorite
	  toggle_favorite_for User.current_user
	end
	
	# to check the status of this page--
	# is it a favorite of the current user?
	# 
	def is_favorite?
	  favorite?
	end
	
	# to add this page as a favorite for the
	# current user
	# 
	def add_favorite options={}
	  options[:comic_id] = self.comic
	  self.favorites.create!(options)
	end
	
	# to remove this page as a favorite from the
	# current user
	# 
	def remove_favorite
	  remove_favorite_of User.current_user
	end
	
	# Lower-level Favorite utility methods:
	
	# toggles this page's favorite status for
	# the given user
	# 
	def toggle_favorite_for user
	  fave = user.favorites.find_by_page_id(self)
	  if fave
	    fave.destroy
	  else
	    fave = add_favorite(:created_by => user)
	  end
	  fave
	end
	
	# removes this page's favorite status from
	# the given user
	# 
	def remove_favorite_of user
	  fave = user.favorites.find_by_page_id(self)
	  fave.destroy
	end
	
	# is this page a favorite of the given user?
	# 
	def is_favorite_of user
	  fave = get_favorite_for user
	  fave ? true : false
	end
	
	# is this page a favorite of the current user?
	# 
	def favorite?
	  is_favorite_of User.current_user
	end
	
	# return the Favorite object for this page
	# and the given user
	# 
	def get_favorite_for user
	  user.favorites.find_by_page_id(self)
  end
	
end
