# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  def only_public
    {:find => {:conditions => ["? <= created_at AND public = ?", 
                               '2006-07-19 10:00:00',true],
               :include    => :attachment, 
               :limit      => 50}}
  end
end
