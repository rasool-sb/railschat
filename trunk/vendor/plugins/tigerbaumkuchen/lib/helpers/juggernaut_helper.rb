=begin
    This source was originally written by Alex MacCaw.
    copyright(c) 2006 Alex MacCaw
    copyright(c) 2006 arton
=end

require "cgi"
CONFIG = Juggernaut.config

module ActionView
  module Helpers
    module JuggernautHelper

      def flash_plugin(channels = ["default"])

        host = CONFIG["PUSH_HELPER_HOST"]
        port = CONFIG["PUSH_PORT"]
        crossdomain = CONFIG["CROSSDOMAIN"]
        juggernaut_data =  CGI.escape('"' + channels.join('","') + '"')
        uid = Time.new.to_i
<<-"END_OF_HTML"
<script type="text/javascript">
  juggernautInit();
  var uid = #{uid};
  var flashProxy = new FlashProxy(uid, 'JavaScriptFlashGateway.swf');
</script>
<OBJECT classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"
 codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=5,0,0,0"
 WIDTH="1" HEIGHT="1" id="myFlash">
 <PARAM NAME=movie VALUE="/webpipe.swf?host=#{host}&port=#{port}&crossdomain=#{crossdomain}&juggernaut_data=#{juggernaut_data}&lcId=#{uid}"> <PARAM NAME=quality VALUE=high> 
 <EMBED src="/webpipe.swf?host=#{host}&port=#{port}&crossdomain=#{crossdomain}&juggernaut_data=#{juggernaut_data}&lcId=#{uid}" quality=high  WIDTH="1" HEIGHT="1" NAME="myFlash" swLiveConnect="true" TYPE="application/x-shockwave-flash" PLUGINSPAGE="http://www.macromedia.com/go/getflashplayer"></EMBED>
</OBJECT>
END_OF_HTML
      end

    end
  end
end
