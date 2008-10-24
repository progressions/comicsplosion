class CreateFavorites < ActiveRecord::Migration
  def self.up
    remove_column :views, :favorite
    create_table :favorites do |t|
      t.column :page_id, :integer
      t.column :created_by, :integer
      t.column :created_on, :datetime
      t.column :updated_on, :datetime
      t.column :comic_id, :integer
    end
  end

  def self.down
    add_column :views, :favorite, :boolean
    drop_table :favorites
  end
end
