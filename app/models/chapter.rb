class Chapter < ActiveRecord::Base
  belongs_to :page
  belongs_to :comic
  
  belongs_to :created_by, :class_name => "User", :foreign_key => "created_by"
  
  acts_as_list :scope => :comic_id
  
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :comic_id
  validates_uniqueness_of :page_id, :scope => :comic_id
  
  def is_live?
    comic.is_live? and page.is_live? and self.live?
  end
end
