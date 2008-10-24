class ChaptersController < ApplicationController
  # GET /chapters
  # GET /chapters.xml
  def index
    @chapters = Chapter.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @chapters.to_xml }
    end
  end

  # GET /chapters/1
  # GET /chapters/1.xml
  def show
    @chapter = Chapter.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @chapter.to_xml }
    end
  end

  # GET /chapters/new
  def new
    @chapter = Chapter.new
  end

  # GET /chapters/1;edit
  def edit
    @chapter = Chapter.find(params[:id])
  end

  # POST /chapters
  # POST /chapters.xml
  def create
    @chapter = Chapter.new(params[:chapter])

    respond_to do |format|
      if @chapter.save
        flash[:notice] = 'Chapter was successfully created.'
        format.html { redirect_to chapter_url(@chapter) }
        format.xml  { head :created, :location => chapter_url(@chapter) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @chapter.errors.to_xml }
      end
    end
  end

  # PUT /chapters/1
  # PUT /chapters/1.xml
  def update
    @chapter = Chapter.find(params[:id])

    respond_to do |format|
      if @chapter.update_attributes(params[:chapter])
        flash[:notice] = 'Chapter was successfully updated.'
        format.html { redirect_to chapter_url(@chapter) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @chapter.errors.to_xml }
      end
    end
  end

  # DELETE /chapters/1
  # DELETE /chapters/1.xml
  def destroy
    @chapter = Chapter.find(params[:id])
    @chapter.destroy

    respond_to do |format|
      format.html { redirect_to chapters_url }
      format.xml  { head :ok }
    end
  end
end
