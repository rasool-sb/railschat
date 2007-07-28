require 'nkf'
class Mailman < ActionMailer::Base
  def receive(email)
    if email.to.first.to_s == "notice@#{CONFIG['PUSH_HELPER_HOST']}"
      return if Message.count(["created_at = ?", email.date]) > 0
      item            = Message.new
      item.name       = NKF.nkf('-w', email.subject)
      item.message    = email.body
      item.created_at = email.date
      item.save
      
      time = item.created_at.strftime("%H:%M:%S")
      str = "<li class=\"normal\"><strong>#{item.name} </strong><span>#{time}</span> #{item.message}</li>"
      
#      str = initialize_template_class(nil).render_to_string(
#        :partial => "chat/message", 
#        :locals  => {:message => item})
#      Juggernaut.send(str.gsub("\n",""), ['chat_channel'])
      Juggernaut.send(str.gsub("\n",""), ['chat_channel'])
    else
      logger.info("ERROR MAIL: " + email.to.first.to_s)
    end
  end
end
