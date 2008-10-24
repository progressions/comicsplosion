class CreateBlogs < ActiveRecord::Migration
  def self.up
    create_table :blogs do |t|
      t.column :name, :string
      t.column :content, :text
      t.column :created_on, :timestamp
      t.column :updated_on, :timestamp
      t.column :created_by, :integer
      t.column :updated_by, :integer
      t.column :page_id, :integer
    end
  end

  def self.down
    drop_table :blogs
  end
end
