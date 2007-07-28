class AttachmentController < ApplicationController
  verify :session => :juggernaut_channels,
         :params  => :id,
         :render  => {:nothing => true}
  
  def download
    Attachment.with_scope(only_public) do
      begin
        item = Attachment.find(params[:id])
        send_data item.body, :filename => "#{item.cut_title}#{item.id}.#{item.content_type}"
      rescue
        not_found
      end
    end 
  end
  
  def show
    Attachment.with_scope(only_public) do
      begin
        item = Attachment.find(params[:id])
        send_data item.body, :type => 'text/plain', :disposition => 'inline'
      rescue
        not_found
      end
    end
  end
  
private
  def only_public
    {:find => {:conditions => ["? <= created_at OR public = ?", Time.now.yesterday, true],
               :include => :message}}
  end
  
  def not_found
    render_text(IO.read(File.join(RAILS_ROOT, 'public', '404.html')), "404 Not Found")
  end
end
