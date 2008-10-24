class PagesController < ApplicationController

  before_filter :find_comic
  before_filter :check_authentication, :except => [:show, :favorites] 

  def set_page_name
    @page = Page.find(params[:id])
    previous_name = @page.name
    @page.name = params[:value]
    @page.name = previous_name unless @page.save
    render :text => @page.name
  end

  # GET /pages
  # GET /pages.xml
  def index
    @pages = @comic.pages
    
    respond_to do |format|
      format.html
      format.xml
    end
  end

  # GET /pages/1
  # GET /pages/1.xml
  def show
    flash.keep
    begin
      @page = Page.find(params[:id])
      raise ActiveRecord::RecordNotFound unless @page.is_live?
      @comic = @page.comic 
      params[:page] = @page.locate
      unless params[:page].blank?
        redirect_to :controller => 'comics', :action => 'show', :id => @comic.alias, :page => params[:page]
      else
        redirect_to comic_path(@comic.alias)
      end
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "The page you are looking for could not be found."
      redirect_to home_path
    end      
  end

  # GET /pages/new
  def new
    @page = Page.new
  end

  # GET /pages/1;edit
  def edit
    @page = Page.find(params[:id])
  end

  # POST /pages
  # POST /pages.xml
  def create
    # sleep 2 # Wait for Windows to catch up!
    @page = Page.new(params[:page])
    
    @comic.last_updated = Time.now
    @comic.pages << @page 
    
    respond_to do |format|
      if @page.save
        @comic.save
        flash[:notice] = 'Page was successfully created.'
        format.html { redirect_to edit_page_path(:comic_id => @comic.alias, :id => @page) }
        format.xml  { head :created, :location => page_url(:comic_id => @comic.alias, :id => @page) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @page.errors.to_xml }
      end
    end
  end

  # PUT /pages/1
  # PUT /pages/1.xml
  def update
    @page = Page.find(params[:id])
    
    if params[:page][:image].blank?
      # raise params[:page].inspect
      params[:page].delete(:image) 
      params[:page].delete(:image_temp)
    end
    
    respond_to do |format|
      if @page.update_attributes(params[:page])
        flash[:notice] = 'Page was successfully updated.'
        # format.html { redirect_to :controller => 'comics', :action => 'list_pages', :id => @page.comic}        
        format.html { redirect_to pages_path(@page.comic.alias) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @page.errors.to_xml }
      end
    end
  end

  # DELETE /pages/1
  # DELETE /pages/1.xml
  def destroy
    @page = Page.find(params[:id])
    @page.destroy
    flash[:notice] = "Page was successfully deleted."

    respond_to do |format|
      format.html { redirect_to :controller => 'comics', :action => 'list_pages', :id => @page.comic }
      format.xml  { head :ok }
    end
  end
  
  
  # GET /comics/:comic_id/pages/:id;favorites
  def favorites
    @page = Page.find(params[:id])
    @favorites = @page.favorites

    respond_to do |format|
      format.html 
      format.xml  { head :ok }
    end
  end
  
  # POST /comics/:comic_id/pages/:id;favorite
  def favorite
    @user = User.current_user
    @page = Page.find(params[:id])
    # @view = @user.views.find(:first, :conditions => ["resource_id = ? and resource_type = 'Page'", @page])
    
    @page.toggle_favorite
    
    respond_to do |format|
      format.html { render :nothing => true }
      format.js {
        render :update do |page|
          page.replace_html 'favorite', :partial => '/comics/favorite'
        end
      }
    end
  end
  
  # POST /comics/:comic_id/pages/:id;sort
  def sort
    @comic.pages.each do |page|
      page.position = params['page_list'].index(page.id.to_s) + 1
      page.save
    end
    render :nothing => true
  end
  
  private
  
  def find_comic
    @comic_id = params[:comic_id]
    redirect_to comics_path unless @comic_id
    @comic = Comic.find_by_alias_or_id(@comic_id)
  end
end
