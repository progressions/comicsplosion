class View < ActiveRecord::Base
  belongs_to :resource, :polymorphic => true
  belongs_to :page, :class_name => "Page", :foreign_key => "resource_id"
  
  belongs_to :created_by, :class_name => "User", :foreign_key => "created_by"
  
  validates_presence_of :resource_id, :resource_type, :created_by
  
  # A View must be unique within its resource and its creator,
  # meaning that each View represents one user's view of a
  # specific page or comic.  If that user views it again, no
  # new object can be created, but the _views_ property is 
  # incremented.
  # 
  def validate_on_create
    if View.find(:first, :conditions => ["created_by = ? and resource_type = ? and resource_id = ?", created_by, resource_type, resource_id])
      errors.add_to_base("View must be unique")
    end
  end
  
  # Finds or creates a view of a page for a given user, 
  # provided through the _options_ hash. If the view exists,
  # the _views_ property is incremented.
  # 
  def self.find_or_create_page options
    if options.is_a? Hash
      user = options[:user]
      view = user.views.find(:first, :conditions => ["resource_type = 'Page' and resource_id = ?", options[:page]])
      view = View.new(:created_by => user, :resource => options[:page]) unless view
      view.views += 1
      view if view.save!
    end
  end
  
  # A View is live if its page is live.
  # 
  def is_live?
    self.page.is_live?
  end
  
  # Returns the comic belonging to this View's page.
  # 
  def comic
    self.page.comic
  end
end
