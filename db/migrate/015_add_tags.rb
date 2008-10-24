class AddTags < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.transaction do
      create_table :taggings do |t|
        t.column :taggable_id, :integer
        t.column :tag_id, :integer
        t.column :taggable_type, :string
      end
      create_table :tags do |t|
        t.column :name, :string
      end
    end
  end
  
  def self.down
    ActiveRecord::Base.connection.transaction do
      drop_table :taggings
      drop_table :tags
    end
  end
end