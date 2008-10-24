class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.column :content, :text
      t.column :created_on, :timestamp
      t.column :updated_on, :timestamp
      t.column :created_by, :integer
      t.column :updated_by, :integer
      t.column :page_id, :integer
    end
  end

  def self.down
    drop_table :comments
  end
end
