class ArchiveController < ApplicationController
  session :off
  
  def list
    Message.with_scope(only_public) do
      @messages_pages, @messages = paginate :messages,
                                   :per_page => 50,
                                   :order    => 'messages.id DESC'
    end
  end

  def daily
    today = Time.now
    pub_date = Time.parse('2006-07-19 10:00:00')
    year  = (params[:year]  || today.year ).to_i
    month = (params[:month] || today.month).to_i
    day   = (params[:day]   || today.day  ).to_i
    
    begin
      @current_day = Time.mktime(year, month, day)
    rescue
      @current_day = today
    end
    @current_day   = pub_date if @current_day < pub_date
    @next_day      = @current_day.tomorrow
    @previous_day  = @current_day.yesterday
    
    @messages = Message.find(
      :all, :order => "messages.id DESC",
      :conditions  => ["? <= created_at AND ? > created_at AND public = ?",
                       @current_day, @current_day.tomorrow, true],
      :include     => :attachment)
  end

  def feed
    Message.with_scope(only_public) do
      @messages = Message.find(:all, :order => 'messages.id DESC')
      render :layout => false
    end
  end

  def show
    begin
      Message.with_scope(only_public) do
        hardlimit = 1000
        options   = {:order=>"messages.id", :limit=>hardlimit}
        @messages = []

        case params[:id].to_s
        when /\A\d+(,\d+)*\Z/
          options[:conditions] = ["messages.id IN (?)", params[:id].split(/,/)]
        when /\A(\d+)-(\d+)\Z/
          options[:conditions] = ["messages.id BETWEEN ? AND ?", $1, $2]
        when /\A(\d+):(\d+)\Z/
          options[:conditions] = ["messages.id >= ?", $1]
          options[:limit]      = $2.to_i
        when /\A(\d+)n\Z/
          options[:conditions] = ["messages.id >= ?", $1]
        when /\Al(\d+)\Z/
          options[:order] = "messages.id DESC"
          options[:limit] = $1.to_i
          reverse         = true
        else
          options[:limit] = 0
        end

        options[:limit] = [options[:limit], hardlimit].min
        @messages = Message.find(:all, options)
        @messages.reverse! if reverse
      end
    rescue
      render_text(IO.read(File.join(RAILS_ROOT, 'public', '404.html')), "404 Not Found")
    end
  end

end
