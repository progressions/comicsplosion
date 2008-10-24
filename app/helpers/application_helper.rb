# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # include DatebocksEngine
  
  def signed_in?
    session[:user]
  end
  
  def current_user
    User.current_user if signed_in?
  end
  
  def current_user_has_role? role
    current_user and current_user.has_role? role
  end

  def current_username_or_fullname
    user = current_user
    if user and user.fullname != nil
      user.fullname
    else
      user.username
    end
  end
  
  def mine? thing
    signed_in? and thing.created_by == current_user
  end
  
  def recent_comments comic
    comments_path(:comic_id => comic.alias, :days => 2)
  end
  
  def show_flash key
    if flash[key]
      "<p class='flash'>#{flash[key]}</p>"
    end
  end
  
  def file_image user, image_size=nil
    user.public_filename(image_size)
  end
  
  def user_image user, image_size=nil
    i = file_image(user, image_size)
    link_to(image_tag(i, :class => 'user_image'), user_path(user.alias)) if i
  end
  
  def fuser_image user, image_size=nil
    image_size ||= 'medium'
    link_to(image_tag(file_image(user,image_size), :class => 'user_image'), user_path(user.alias))
  end
  
  def comic_path_from page
    comic_path(:id => page.comic.alias, :page => page.locate) if page || page.is_live?
  end
  
  def page_number page, options={}
    comic_name = ""
    if options.is_a? Hash
      comic_name = h(page.comic.name) if options[:long]
    end
    page and page.is_live? ? comic_name + "page #{page.locate} of #{page.comic.live_pages.length}" : nil
  end
  
  def img_columns page
    begin
      page.width > 350 ? page.width : 350
    rescue
      780
    end
  end
  
  def full_time time
    time.strftime("at %I:%M%p on %B %d, %Y")
  end

  def last_updated comic
    if comic.last_updated
      time_ago = time_ago_in_words(comic.last_updated)
      "Last updated #{time_ago} ago."
    end
  end
  
  def calendar_include_tag	  	
		javascript_include_tag 'datebocks_engine.js'
	  javascript_include_tag 'calendar.js'
		javascript_include_tag 'calendar-setup.js'
		javascript_include_tag 'calendar-en.js'
		stylesheet_link_tag 'datebocks_engine.css'
		stylesheet_link_tag 'calendar.css'
  end

  def in_place_editor(field_id, options = {})
        function =  "new Ajax.InPlaceEditor("
        function << "'#{field_id}', "
        function << "'#{url_for(options[:url])}'"

        js_options = {}
        js_options['cancelText'] = %('#{options[:cancel_text]}') if options[:cancel_text]
        js_options['okText'] = %('#{options[:save_text]}') if options[:save_text]
        js_options['loadingText'] = %('#{options[:loading_text]}') if options[:loading_text]
        js_options['savingText'] = %('#{options[:saving_text]}') if options[:saving_text]
        js_options['rows'] = options[:rows] if options[:rows]
        js_options['cols'] = options[:cols] if options[:cols]
        js_options['size'] = options[:size] if options[:size]
        js_options['externalControl'] = "'#{options[:external_control]}'" if options[:external_control]
        js_options['loadTextURL'] = "'#{url_for(options[:load_text_url])}'" if options[:load_text_url]        
        js_options['ajaxOptions'] = options[:options] if options[:options]
        js_options['evalScripts'] = options[:script] if options[:script]
        js_options['callback']   = "function(form) { return #{options[:with]} }" if options[:with]
        js_options['clickToEditText'] = %('#{options[:click_to_edit_text]}') if options[:click_to_edit_text]
        js_options['highlightcolor'] = %('#{options[:highlight_color]}') if options[:highlight_color]
        js_options['highlightendcolor'] = %('#{options[:highlight_end_color]}') if options[:highlight_end_color]
        function << (', ' + options_for_javascript(js_options)) unless js_options.empty?
        
        function << ')'

        javascript_tag(function)
      end
end
