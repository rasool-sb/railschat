=begin
    This source was originally written by Alex MacCaw.
    copyright(c) 2006 Alex MacCaw
    copyright(c) 2006 arton
=end

require "base64"
require "yaml"
require "socket"
begin
  require "json"
rescue LoadError
  require "rubygems"
  require "json"
end

module Juggernaut
  FS_APP_CONFIG = YAML::load(File.open("#{RAILS_ROOT}/config/juggernaut_config.yml"))
  @socket = nil

  def self.config
    return FS_APP_CONFIG
  end

  def self.send(data,chan = ["default"])
    unless @socket
      @socket = TCPSocket.new(FS_APP_CONFIG["PUSH_HELPER_HOST"], FS_APP_CONFIG["PUSH_PORT"])
    end
    fc = { :message => Base64.encode64(data), :secret => FS_APP_CONFIG["PUSH_SECRET"], :broadcast => 1, :channels => chan}
    @socket.puts fc.to_json
    @socket.flush
  rescue
    @socket = nil
    false
  end

  def self.diag(chan = ["default"])
    socket = TCPSocket.new(FS_APP_CONFIG["PUSH_HELPER_HOST"], FS_APP_CONFIG["PUSH_PORT"])
    fc = { :diag => 1, :channels => chan }
    socket.puts fc.to_json
    socket.flush
    s = socket.read
    data = JSON.parse(s.strip.gsub(/\0/, ''))
    socket.close
    data
  end

  def self.html_escape(s)
    s.to_s.gsub(/&/, "&amp;").gsub(/\"/, "&quot;").gsub(/>/, "&gt;").gsub(/</, "&lt;")
  end
  
  def self.string_escape(s)
    s.gsub(/[']/, '\\\\\'')
  end
  
  def self.parse_string(s)
    s.gsub(/\r\n|\n|\r/, "\\n").gsub(/["']/) { |m| "\\#{m}" }
  end
  
  def self.html_and_string_escape(s)
    i = s.gsub(/[']/, '\\\\\'')
    i.to_s.gsub(/&/, "&amp;").gsub(/\"/, "&quot;").gsub(/>/, "&gt;").gsub(/</, "&lt;")
  end

end
