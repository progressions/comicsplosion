class CreateViews < ActiveRecord::Migration
  def self.up
    rename_column :comics, :views, :view_count
    
    create_table :views do |t|
      t.column :resource_id, :integer
      t.column :resource_type, :string
      t.column :page_id, :integer
      t.column :created_by, :integer
      t.column :rating, :integer
      t.column :favorite, :boolean
      t.column :created_on, :datetime
      t.column :updated_on, :datetime
      t.column :views, :integer, :null => false, :default => 0
    end
  end

  def self.down
    drop_table :views
  end
end
