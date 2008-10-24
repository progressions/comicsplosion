class FeedsController < ApplicationController
  layout nil
  session :off

  # GET /feeds
  # GET /feeds.xml
  def index
    @feeds = Feed.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @feeds.to_xml }
    end
  end

  # GET /feeds/1
  # GET /feeds/1.xml
  def show
    @feed = Feed.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @feed.to_xml }
    end
  end
  
  # GET /feeds/latest_comics
  def latest_comics
    @comics = Comic.find(:all, :order => "last_updated DESC", :conditions => "last_updated > 0 AND live = 1", :limit => 15 )
    
    respond_to do |format|
      format.rss { render :action => "latest_comics.rxml" }
    end
  end
  
  # GET /feeds/latest_pages
  def latest_pages
    @pages = Page.find(:all, :order => "position DESC", :conditions => "published_on > 0 AND live = 1", :limit => 15 )
    
    respond_to do |format|
      format.rss { render :action => "latest_pages.rxml" }
    end
  end
    
  # GET /feeds/latest/comic_alias
  def latest
    @comic = Comic.find_by_alias(params[:id]) 
    @comic = Comic.find(params[:id]) unless @comic
    
    @pages = @comic.pages.find(:all, :order => "position DESC", :conditions => "published_on > 0 AND live = 1", :limit => 15 )
    
    respond_to do |format|
      format.rss { render :action => "latest.rxml" }
    end
  end

  # GET /feeds/new
  def new
    @feed = Feed.new
  end

  # GET /feeds/1;edit
  def edit
    @feed = Feed.find(params[:id])
  end

  # POST /feeds
  # POST /feeds.xml
  def create
    @feed = Feed.new(params[:feed])

    respond_to do |format|
      if @feed.save
        flash[:notice] = 'Feed was successfully created.'
        format.html { redirect_to feed_url(@feed) }
        format.xml  { head :created, :location => feed_url(@feed) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @feed.errors.to_xml }
      end
    end
  end

  # PUT /feeds/1
  # PUT /feeds/1.xml
  def update
    @feed = Feed.find(params[:id])

    respond_to do |format|
      if @feed.update_attributes(params[:feed])
        flash[:notice] = 'Feed was successfully updated.'
        format.html { redirect_to feed_url(@feed) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @feed.errors.to_xml }
      end
    end
  end

  # DELETE /feeds/1
  # DELETE /feeds/1.xml
  def destroy
    @feed = Feed.find(params[:id])
    @feed.destroy

    respond_to do |format|
      format.html { redirect_to feeds_url }
      format.xml  { head :ok }
    end
  end
end
