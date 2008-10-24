class AddUpdatedBy < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.transaction do
		  add_column :pages, :updated_by, :integer
		end
  end

  def self.down
    ActiveRecord::Base.connection.transaction do
		  remove_column :pages
		end
  end
end
