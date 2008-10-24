class AddDetails < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.transaction do
      add_column :comics, :show_blog, :boolean
      add_column :comics, :show_comments, :boolean            
      add_column :users, :email, :string          
    end
  end

  def self.down
    ActiveRecord::Base.connection.transaction do
      remove_column :comics, :show_blog
      remove_column :comics, :show_comments          
      remove_column :users, :email
    end
  end
end
