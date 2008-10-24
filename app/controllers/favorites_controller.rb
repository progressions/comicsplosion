class FavoritesController < ApplicationController
  # GET /favorites
  # GET /favorites.xml
  def index
    @favorites = Favorite.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @favorites.to_xml }
    end
  end

  # GET /favorites/1
  # GET /favorites/1.xml
  def show
    @favorite = Favorite.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @favorite.to_xml }
    end
  end

  # GET /favorites/new
  def new
    @favorite = Favorite.new
  end

  # GET /favorites/1;edit
  def edit
    @favorite = Favorite.find(params[:id])
  end

  # POST /favorites
  # POST /favorites.xml
  def create
    @favorite = Favorite.new(params[:favorite])

    respond_to do |format|
      if @favorite.save
        flash[:notice] = 'Favorite was successfully created.'
        format.html { redirect_to favorite_url(@favorite) }
        format.xml  { head :created, :location => favorite_url(@favorite) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @favorite.errors.to_xml }
      end
    end
  end

  # PUT /favorites/1
  # PUT /favorites/1.xml
  def update
    @favorite = Favorite.find(params[:id])

    respond_to do |format|
      if @favorite.update_attributes(params[:favorite])
        flash[:notice] = 'Favorite was successfully updated.'
        format.html { redirect_to favorite_url(@favorite) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @favorite.errors.to_xml }
      end
    end
  end

  # DELETE /favorites/1
  # DELETE /favorites/1.xml
  def destroy
    @favorite = Favorite.find(params[:id])
    @favorite.destroy

    respond_to do |format|
      format.html { redirect_to favorites_url }
      format.xml  { head :ok }
    end
  end
end
