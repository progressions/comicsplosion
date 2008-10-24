class CreateComics < ActiveRecord::Migration
  def self.up
    create_table :comics do |t|
      t.column :name, :string
      t.column :description, :text
      t.column :image, :string
      t.column :created_by, :integer
      t.column :updated_by, :integer
      t.column :created_on, :timestamp
      t.column :updated_on, :timestamp
    end
  end

  def self.down
    drop_table :comics
  end
end
