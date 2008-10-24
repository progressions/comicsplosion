class Role < ActiveRecord::Base
  has_many :permissions, :dependent => :destroy
  has_many :users, :through => :permissions
  
  validates_uniqueness_of :name
  validates_presence_of :name
end
