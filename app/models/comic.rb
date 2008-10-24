class Comic < ActiveRecord::Base
  # file_column :image, :magick => { 
#      :versions => { "thumb" => "50x50", "medium" => "150x150>" }
#    }
  
  acts_as_taggable
  
  has_many :pages, :order => :position, :dependent => :destroy
  has_many :live_pages, :class_name => "Page", :foreign_key => "comic_id", :order => :position, :conditions => ["live = 1 AND published_on <= ?", Time.now], :include => [:comments, :views]

  has_many :chapters, :order => :position
  has_many :live_chapters, :class_name => "Chapter", :foreign_key => "comic_id", :order => :position, :conditions => ["live = 1"], :include => [:pages]
  
  has_many :comments
  has_many :new_comments, :class_name => "Comment", :foreign_key => "comic_id", :order => "created_on DESC", :conditions => ["created_on > ?", 2.days.ago]
  
  has_many :views, :as => :resource, :dependent => :destroy
  has_many :favorites, :dependent => :destroy
    
  belongs_to :created_by, :class_name => "User", :foreign_key => "created_by"
  belongs_to :updated_by, :class_name => "User", :foreign_key => "updated_by"
  
  validates_presence_of :name, :alias
  validates_uniqueness_of :name, :alias  
  
  validates_format_of :alias, :with => /^[\w\-]+$/, :message => "should be letters, nums, dash, underscore only"
  
  # Takes a Date as a parameter and returns an array of all 
  # pages published in this comic since that Date.
  # 
  # Example:
  #   @comic.new_pages :since => 2.days.ago
  # 
  # Returns all live pages published in the last 2 days.
  # 
  # If no parameter is supplied, new_pages returns all the comic's
  # live pages.
  # 
  def new_pages options={}    
    if options[:since]
      find_options = {:conditions => ["published_on >= ?", options[:since]], :order => "position"}
      find_options[:limit] = options[:limit] if options[:limit]
      new_pages = self.live_pages.find(:all, find_options)
    else
      new_pages = self.live_pages
    end
    new_pages
  end
  
  # Takes a page or chapter number as a parameter and returns 
  # the relevant Page object in the context of this comic's 
  # live chapters or pages.  Options can take one of two parameters:
  #   [:page]     Returns the page located at this page number.
  #   [:chapter]  Returns the page referred to by this chapter number.
  # 
  def locate options={}
    if options.is_a? Hash
      page_number = options[:page]
      chapter_number = options[:chapter]
    end
    if page_number
      self.live_pages[page_number-1]
    else
      self.live_chapters[chapter_number-1]
    end
  end
  
  # This Class method returns all the live comics.
  # 
  # It's a bit flawed because it doesn't check the comic's pages to
  # make sure it has one or more live pages.
  # 
  def self.live_comics
    comics = Comic.find(:all, :conditions => ["comics.live = 1 AND comics.published_on <= ?", Time.now], :include => [:pages, :comments, :created_by] )
    comics.map { |comic| comic unless comic.live_pages.blank? }.compact
  end
  
  # A Comic's unique _alias_ is its more important identifier.
  # We don't really use ids except internally.  This Class method 
  # takes one parameter, either an alias or an id, and returns the
  # associated Comic.
  # 
  def self.find_by_alias_or_id id
    comic = find_by_alias(id, :include => [:pages, :comments, :views, :created_by])
    comic ||= find(id)
    # comic
  end
  
  # A Comic is live if:
  # - its _live_ attribute is true,
  # - its _published_on_ date has passed,
  # - it contains one or more live pages.
  #   
  def is_live?
    self.live? and self.published_on <= Time.now and !self.live_pages.blank?
  end
end
