class TagsController < ApplicationController

  # GET /tags/1
  # GET /tags/1.xml
  def show
    @tag = params[:id]
    @comics = Comic.find_tagged_with(@tag)
  end

end
