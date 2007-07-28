ActionController::Routing::Routes.draw do |map|
  map.connect '',     :controller => 'chat'
  map.connect 'feed', :controller => 'archive', :action => 'feed'
  map.connect 'log',  :controller => 'archive', :action => 'list'
  
  map.connect '/daily/:year/:month/:day', :controller => 'archive',
                                          :action     => 'daily',
                                          :year       => nil,
                                          :month      => nil,
                                          :day        => nil
  
  # backward compatibility routing
  map.connect '/chat/show/:id', :controller => 'archive', :action => 'show'
  map.connect '/list', :controller => 'archive', :action => 'list'

  map.connect ':controller/:action/:id'
end
