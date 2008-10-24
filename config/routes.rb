ActionController::Routing::Routes.draw do |map|
  map.resources :chapters

  map.resources :favorites

  map.resources :permissions

  map.resources :roles

  map.resources :blogs

  map.resources :tags
  
  map.resources :comics do |comic|
    comic.resources :comments
    comic.resources :pages
    comic.resources :pages, :collection => { :sort => :post }
    comic.resources :pages, :member => { :favorite => :post }
    comic.resources :pages, :member => { :favorites => :get }
  end
  
  map.resources :users

  # map.resources :pages

  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)
  
  map.home '', :controller => 'comics'

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"
  
  # map.comments '/comments/:id', :controller => 'comments', :action => 'show', :id => 'id'
  
  map.new_user '/register/', :controller => 'users', :action => 'new'
  
  map.first '/comics/:id/first/', :controller => 'comics', :action => 'first', :id => 'id'  
  map.latest '/comics/:id/latest/', :controller => 'comics', :action => 'latest', :id => 'id'
  
  map.recent '/comics/:id/recent/', :controller => 'comics', :action => 'recent', :id => 'id'
  
  map.list_pages '/comics/:id/pages', :controller => "comics", :action => "list_pages", :id => 'id'
    
  map.new_edit_pages '/comic/edit_pages/', :controller => 'comics', :action => 'new_edit_pages'
  map.new_logo '/comic/new_logo/', :controller => 'comics', :action => 'new_logo'
  map.new_describe '/comic/describe/', :controller => 'comics', :action => 'new_describe'
  map.new_publish '/comic/publish/', :controller => 'comics', :action => 'new_publish'
  map.new_congrats '/comic/congratulations/', :controller => 'comics', :action => 'new_congratulations'
  
  map.image_preview '/image_preview/:id', :controller => 'comics', :action => 'image_preview', :id => 'id'
    
  map.latest_comics '/comics/:id.rss', :controller => 'comics', :action => 'show', :id => 'id'
  map.latest_pages '/feeds/latest_pages/', :controller => 'feeds', :action => 'latest_pages'
  
  map.show_page '/pages/:id/', :controller => 'pages', :action => 'show', :id => 'id'
  map.show_page_with_comment '/comment/:id', :controller => 'comment', :action => 'view', :id => 'id'
  
  map.signin '/signin/', :controller => 'admin', :action => 'signin'
  
  map.add_tag 'add_tag/:id', :controller => 'comics', :action => 'add_tag', :id => 'id'
  map.remove_tag 'remove_tag/:id', :controller => 'comics', :action => 'remove_tag', :id => 'id'
  
  map.person ':id', :controller => "users", :action => 'show', :id => 'id'
  
  map.favorites ':id/favorites', :controller => 'users', :action => 'favorites', :id => 'id'
  # map.new_favorite '/comics/:comic_id/pages/:id/favorite', :controller => 'pages', :action => 'favorite', :comic_id => 'comic_id', :id => 'id'
  
  map.manage_comics ':id/comics', :controller => 'comics', :action => 'manage', :id => 'id'
  
  map.connect 'stylesheets/:rcss.:format', :controller => '/stylesheets', :action => 'rcss'

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
