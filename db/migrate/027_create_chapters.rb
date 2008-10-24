class CreateChapters < ActiveRecord::Migration
  def self.up
    create_table :chapters do |t|
      t.column :name, :string
      t.column :comic_id, :integer
      t.column :page_id, :integer
      t.column :created_by, :integer
      t.column :created_on, :datetime
      t.column :updated_on, :datetime
      t.column :live, :boolean
      t.column :position, :integer
    end
  end

  def self.down
    drop_table :chapters
  end
end
