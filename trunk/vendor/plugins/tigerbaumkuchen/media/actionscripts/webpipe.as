import com.macromedia.javascript.JavaScriptProxy;

class WebPipe {
    static var pipe : WebPipe;
    var socket : XMLSocket;
    var interval:Number = 10000;
    var intervalId: Number;
    var alive: Boolean;
    var autoConnect: Boolean = true;
    var connectToHost: Function;
    static var now = new Date();
    var log_message = "log now: " + now + "\n";
    
    var proxy: JavaScriptProxy;

    function WebPipe(crossdomain, host, port, sig, intvl, autocnn) {
        System.security.loadPolicyFile(crossdomain);
        proxy = new JavaScriptProxy(_root.lcId, this);
        // Create new XMLSocket object
        var juggernaut_data: String = sig;
        var me = this;
        var sock = new XMLSocket();
        if (intvl != undefined) {
            interval = intvl;
        }
        if (autocnn != undefined) {
            autoConnect = autocnn;
        }
        socket = sock;
        alive = false;
        socket.onConnect = function(success:Boolean) {
            if (success) {
                sock.send('{"broadcast":0,"channels":[' + unescape(juggernaut_data) + ']}' + "\n");
                me.alive = true;
                me.intervalId = setInterval(me, "interPing", me.interval);
                getURL("javascript:flashConnected()");
            }
            else {
                if (me.autoConnect) {
                    me.intervalId = setInterval(me, "reConnect", me.interval);
                } else {
                    getURL("javascript:flashErrorConnecting()");
                }
            }
        };
                
        socket.onXML = function(input:XML) {
            clearInterval(me.intervalId);
            me.alive = true;
            var msg = input.toString();
            if (msg.indexOf("&quot;pong&quot;:1") < 0) {
                fscommand('send_var', msg);
            }
            me.intervalId = setInterval(me, "interPing", me.interval);
        }
            
        socket.onClose = function() {
            me.endConnection();
        }
        
        connectToHost = function() {
            me.socket.connect(host, port);
        }
        connectToHost();
    }

    function reConnect() {
        clearInterval(intervalId);        
        connectToHost();
    }

    function interPing() {
        if (!alive) {
            endConnection();
        } else {
            alive = false;
            socket.send('{"ping":1,"message":[\"1234567890ABCDEF\"]}' + "\n");
        }
    }

    function endConnection() {
        clearInterval(intervalId);
        socket.close();
        if (autoConnect) {
            intervalId = setInterval(this, "reConnect", interval);
        } else {
            getURL("javascript:flashConnectionLost()");
        }
    }

    public function log(message) {
        log_message += message + "\n";
        System.setClipboard(log_message);
    }
 
    public function ping() {
        socket.send('{"ping":1,"message":[\"1234567890ABCDEF\"]}' + "\n");        
    }
    
    public function stopPing() {
        clearInterval(intervalId);        
    }

    static function main(mc) {
        pipe = new WebPipe(mc['crossdomain'],
                           mc['host'],
                           mc['port'],
                           mc['juggernaut_data'],
                           mc['keepalive'],
                           mc['autoconnect']);
    }
}
