class AddUserData < ActiveRecord::Migration
  def self.up   
		ActiveRecord::Base.connection.transaction do
		  add_column :users, :firstname, :string
		  add_column :users, :lastname, :string
		  add_column :users, :image, :string
		  add_column :users, :last_signin, :datetime
		  add_column :users, :login_count, :integer
		  add_column :users, :bio, :text
		  
		  add_column :pages, :created_by, :integer
		end
  end

  def self.down
		ActiveRecord::Base.connection.transaction do
		  remove_column :users, :firstname
		  remove_column :users, :lastname
		  remove_column :users, :image
		  remove_column :users, :last_signin 
		  remove_column :users, :login_count
		  remove_column :users, :bio
		  
		  remove_column :pages, :created_by
		end
  end
end
