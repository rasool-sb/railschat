desc "Install the js and swf files to correct places"
task :install_tigerbaumkuchen do
  puts "Installing Tigerbaumkuchen..."
  FileUtils.cp(File.dirname(__FILE__) + "/../media/javascripts/juggernaut_javascript.js", RAILS_ROOT + '/public/javascripts/')
  FileUtils.cp(File.dirname(__FILE__) + "/../media/javascripts/JavaScriptFlashGateway.js", RAILS_ROOT + '/public/javascripts/')

  FileUtils.cp(File.dirname(__FILE__) + "/../media/flash/webpipe.swf", RAILS_ROOT + '/public/')
  FileUtils.cp(File.dirname(__FILE__) + "/../media/flash/JavaScriptFlashGateway.swf", RAILS_ROOT + '/public/')

  FileUtils.cp(File.dirname(__FILE__) + "/../script/push_server", RAILS_ROOT + '/script/')
  FileUtils.cp(File.dirname(__FILE__) + "/../JUGGERNAUT-README", RAILS_ROOT)
  FileUtils.cp(File.dirname(__FILE__) + "/../media/juggernaut_config.yml", RAILS_ROOT + '/config/')
  FileUtils.cp(File.dirname(__FILE__) + "/../media/crossdomain.xml", RAILS_ROOT + '/public/')
  puts "Done"
end

task :compile_as do
  if RUBY_PLATFORM.index('mswin')
    mtasc = "c:\\program files\\mtasc-1.12\\mtasc.exe"
    ['webpipe'].each do |as|
      dir = File.expand_path("../media/actionscripts", File.dirname(__FILE__)).gsub('/', '\\')
      src = File.expand_path("../media/actionscripts/#{as}.as", File.dirname(__FILE__)).gsub('/', '\\')
      dst = File.expand_path("../media/flash/#{as}.swf", File.dirname(__FILE__)).gsub('/', '\\')
      system("#{mtasc} -cp \"#{dir}\" -header 1:1:60 -main \"#{src}\" -swf \"#{dst}\"")
    end
  else
    puts 'sorry, no compile taks'
  end
end

