class AddLiveToPages < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.transaction do
      add_column :pages, :live, :boolean
    end
  end

  def self.down
    ActiveRecord::Base.connection.transaction do
      remove_column :pages, :live
    end
  end
end
