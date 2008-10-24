class AddImage < ActiveRecord::Migration
  def self.up    
		ActiveRecord::Base.connection.transaction do
		  add_column :pages, :image, :string
		end
  end

  def self.down
		ActiveRecord::Base.connection.transaction do
		  remove_column :pages, :image
		end
  end
end
