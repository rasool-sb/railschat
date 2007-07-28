require 'resolv'
class ChatController < ApplicationController
  
  def index
    session[:juggernaut_channels] = ['chat_channel']
    Message.with_scope(only_public) do
      @messages = Message.find(:all, :order => 'messages.id DESC', :limit => 10)
    end
  end

  def login
    reset_session
    session[:juggernaut_channels] = ['chat_channel']
    send_line_item(login_message)
    render :nothing => true
  end

  def send_data
    if invalid_message?
      logger.info "SPAM MESSAGE!?"
      # message = Message.new(
      #           :name    => "System", :created_at => Time.new,
      #           :message => "Blocked Spam or Invalid Message. (Active: #{diag_data['active']})")
      # send_line_item(message)
      render :nothing => true
      return
    end
    message = init_message

    if message.save
      send_line_item(message)
      if session[:name].nil?
        # `@name' is used in app/views/chat/_name.rhtml
        @name = session[:name] = params[:name]
        render :update do |page|
          page.replace_html 'namearea', :partial => 'name'
        end
      else
        render :nothing => true
      end
    end
  end

private
  def login_message
    Message.new(:name    => "System", :created_at => Time.new,
                :message => "New User Connected! (Active: #{diag_data['active']})")
  end

  def init_message
    message = Message.new(:name    => (session[:name] || params[:name]),
                          :message => params[:chat_input])
    message.public = false if in_comment_block?
    comment_block_control(message)
    unless params[:attachment].blank?
      attachment = Attachment.new(:title => message.message,
                                  :body  => params[:attachment])
      attachment.title = message.name if attachment.title.blank?
      if attachment.save
        message.attachment = attachment
      end
    end
    message
  end

  def invalid_message?
    logger.debug("spam check: blank_message?")
    return true if blank_message?
    logger.debug("spam check: session[:name].blank?")
    return false if !session[:name].blank?
    logger.debug("spam check: default_message? == #{params[:chat_input]}")
    return true if default_message?(params[:chat_input])
    logger.debug("spam check: black_keyword?")
    return true if black_keyword?(params[:chat_input]) or black_keyword?(params[:attachment])
    logger.debug("spam check: black_url?")
    return true if black_url?(params[:chat_input]) or black_url?(params[:attachment])
    logger.debug("not spam")
    false
  end
    
  def blank_message?
    (params[:chat_input].blank? and params[:attachment].blank?) or (session[:name].blank? and params[:name].blank?)
  end
  
  def default_message?(message)
    message == 'Please, input the message'
  end

  def black_keyword?(message)
    @spam_regexp ||= /#{SPAM_KEYWORD.map{|i| Regexp.escape(i)}.join('|')}/i
    @spam_regexp === message
  end
  SPAM_KEYWORD = ['viagra', 'phentermine', 'casino', '[URL='].freeze
  
  def black_domain?(domain)
    begin
      Resolv.getaddress("#{domain}.rbl.bulkfeeds.jp")
      return true
    rescue
      logger.debug "resolv error"
    end
    false
  end
  
  def black_url?(message)
    message.scan( %r|http://([^/]+)/| ) do |s|
      logger.debug "domain #{s[0]}"
      return true if black_domain?( s[0] )
    end
    false
  end
  
  def send_line_item(item)
    str = render_to_string(:partial => "message", :locals => {:message => item })
    Juggernaut.send(str.gsub("\n","<break>"), session[:juggernaut_channels])
  end

  def diag_data
    begin
      Juggernaut.diag(session[:juggernaut_channels])
    rescue
      { :diag => 0, 'active' => 0 }
    end
  end

  def in_comment_block?
    [:eol, :block].include?(session[:comment_block])
  end

  # TODO refactoring
  def comment_block_control(message_obj)
    unless session[:comment_block] == :eol
      case message_obj.message
      when COMMENT_BEGIN_RE
        session[:comment_block] = :block
        message_obj.public = false
      when COMMENT_END_RE
        session[:comment_block] = nil if session[:comment_block] == :block
        message_obj.public = false
      when COMMENT_EOL_RE
        session[:comment_block] = :eol
        message_obj.public = false
      end
    end
  end

  COMMENT_BEGIN_RE = /\A=begin\Z/
  COMMENT_END_RE   = /\A=end\Z/
  COMMENT_EOL_RE   = /\A__END__\Z/
end