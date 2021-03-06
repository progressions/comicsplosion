# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 30) do

  create_table "blogs", :force => true do |t|
    t.column "name",       :string
    t.column "content",    :text
    t.column "created_on", :datetime
    t.column "updated_on", :datetime
    t.column "created_by", :integer
    t.column "updated_by", :integer
    t.column "page_id",    :integer
  end

  create_table "chapters", :force => true do |t|
    t.column "name",       :string
    t.column "comic_id",   :integer
    t.column "page_id",    :integer
    t.column "created_by", :integer
    t.column "created_on", :datetime
    t.column "updated_on", :datetime
    t.column "live",       :boolean
    t.column "position",   :integer
  end

  create_table "comics", :force => true do |t|
    t.column "name",          :string
    t.column "description",   :text
    t.column "image",         :string
    t.column "created_by",    :integer
    t.column "updated_by",    :integer
    t.column "created_on",    :datetime
    t.column "updated_on",    :datetime
    t.column "last_updated",  :datetime
    t.column "live",          :boolean
    t.column "published_on",  :datetime
    t.column "alias",         :string,   :limit => 100
    t.column "view_count",    :integer
    t.column "copyright",     :text
    t.column "byline",        :string
    t.column "schedule",      :string
    t.column "show_blog",     :boolean
    t.column "show_comments", :boolean
    t.column "parent_id",     :integer
    t.column "content_type",  :string
    t.column "filename",      :string
    t.column "thumbnail",     :string
    t.column "size",          :integer
    t.column "width",         :integer
    t.column "height",        :integer
  end

  create_table "comments", :force => true do |t|
    t.column "content",    :text
    t.column "created_on", :datetime
    t.column "updated_on", :datetime
    t.column "created_by", :integer
    t.column "updated_by", :integer
    t.column "page_id",    :integer
    t.column "comic_id",   :integer
  end

  create_table "favorites", :force => true do |t|
    t.column "page_id",    :integer
    t.column "created_by", :integer
    t.column "created_on", :datetime
    t.column "updated_on", :datetime
    t.column "comic_id",   :integer
  end

  create_table "pages", :force => true do |t|
    t.column "name",         :string
    t.column "description",  :text
    t.column "created_on",   :datetime
    t.column "updated_on",   :datetime
    t.column "published_on", :datetime
    t.column "image",        :string
    t.column "created_by",   :integer
    t.column "updated_by",   :integer
    t.column "comic_id",     :integer
    t.column "position",     :integer
    t.column "live",         :boolean
    t.column "views",        :integer,  :default => 0
    t.column "parent_id",    :integer
    t.column "content_type", :string
    t.column "filename",     :string
    t.column "thumbnail",    :string
    t.column "size",         :integer
    t.column "width",        :integer
    t.column "height",       :integer
  end

  create_table "permissions", :force => true do |t|
    t.column "user_id", :integer, :null => false
    t.column "role_id", :integer, :null => false
  end

  create_table "roles", :force => true do |t|
    t.column "name", :string
  end

  create_table "taggings", :force => true do |t|
    t.column "taggable_id",   :integer
    t.column "tag_id",        :integer
    t.column "taggable_type", :string
  end

  create_table "tags", :force => true do |t|
    t.column "name", :string
  end

  create_table "thumbnails", :force => true do |t|
    t.column "parent_id",    :integer
    t.column "content_type", :string
    t.column "filename",     :string
    t.column "thumbnail",    :string
    t.column "size",         :integer
    t.column "width",        :integer
    t.column "height",       :integer
  end

  create_table "users", :force => true do |t|
    t.column "username",        :string
    t.column "password_salt",   :string
    t.column "password_hash",   :string
    t.column "firstname",       :string
    t.column "lastname",        :string
    t.column "image",           :string
    t.column "last_signin",     :datetime
    t.column "login_count",     :integer
    t.column "bio",             :text
    t.column "alias",           :string,   :limit => 100
    t.column "email",           :string
    t.column "created_on",      :datetime
    t.column "updated_on",      :datetime
    t.column "previous_signin", :datetime
    t.column "parent_id",       :integer
    t.column "content_type",    :string
    t.column "filename",        :string
    t.column "thumbnail",       :string
    t.column "size",            :integer
    t.column "width",           :integer
    t.column "height",          :integer
  end

  create_table "views", :force => true do |t|
    t.column "resource_id",   :integer
    t.column "resource_type", :string
    t.column "created_by",    :integer
    t.column "rating",        :integer
    t.column "created_on",    :datetime
    t.column "updated_on",    :datetime
    t.column "views",         :integer,  :default => 0, :null => false
  end

end
