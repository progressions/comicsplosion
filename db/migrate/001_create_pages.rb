class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.column :name, :string
      t.column :description, :text
      t.column :created_on, :timestamp
      t.column :updated_on, :timestamp
      t.column :published_on, :timestamp
    end
  end

  def self.down
    drop_table :pages
  end
end
