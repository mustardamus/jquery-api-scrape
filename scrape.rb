# Screen scraping http://api.jquery.com and building a navigation
#   Hacked together by Sebastian Senf (c) 20 10
#   Not the prettiest script, I know. Yet it does the job. Fork!

require "rubygems"
require "mechanize"

html_start = "<!DOCTYPE html>\n<html lang='en'><head><meta http-equiv='content-type' content='text/html; charset=UTF-8' /><script type='text/javascript' src='http://ajax.googleapis.com/ajax/libs/jquery/1.4.1/jquery.min.js'></script>"
html_mid = "</head><body>"
html_end = "<script type=\"text/javascript\"> var gaJsHost = ((\"https:\" == document.location.protocol) ? \"https://ssl.\" : \"http://www.\"); document.write(unescape(\"%3Cscript src='\" + gaJsHost + \"google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E\")); </script> <script type=\"text/javascript\"> try { var pageTracker = _gat._getTracker(\"UA-12732447-1\"); pageTracker._trackPageview(); } catch(err) {}</script></body></html>"

navigation_head = "<link rel='stylesheet' type='text/css' href='css/navigation.css' /><script type='text/javascript' src='js/navigation.js'></script>"
single_head = "<link rel='stylesheet' type='text/css' href='../../css/single.css' /><script type='text/javascript' src='../../js/single.js'></script>"
single_demo = "<script type='text/javascript' src='../../js/demo.js'></script>"

agent = WWW::Mechanize.new
mainpage = agent.get("http://api.jquery.com/")

version = mainpage.search("#categories > ul > li:last > ul > li:last a")[0].text
version = version[8..version.length]

system("rm -r #{version}") #I know... :)
Dir.mkdir version
Dir.mkdir "#{version}/docs"

navigation = "<div id='search'><input type='text' id='search-field' /></div><ul>"

mainpage.search("#categories > ul > li > a").each do |mainlink|
  main_name = mainlink.text
  
  unless main_name == "All" || main_name == "Version"
    puts main_name

    navigation << "<li><a href='##{main_name.downcase}'>#{main_name}</a><ul>"
    
    subpage = agent.get(mainlink["href"])
    
    subpage.search("#method-list > li").each do |method|
      method_a = method.search("h2 a")[0]
      method_name = method_a.text.gsub(/“/, '"').gsub(/”/, '"')
      method_link = method_a["href"]
      method_desc = method.search(".desc")[0].text
      method_fold = method_link[22..method_link.length-2]
      
      begin
        path = "#{version}/docs/#{method_fold}"
        Dir.mkdir path
        
        singlepage = agent.get(method_link)
        content = singlepage.search(".entry-content")[0]
        
        File.open("#{path}/index.html", "w") { |f| f.write("#{html_start}\n#{single_head}\n#{html_mid}\n#{content}\n#{single_demo}\n#{html_end}") }
      rescue Exception => e #file or folder exist
        #puts e.message 
      end
      
      navigation << "<li><a href='docs/#{method_fold}/index.html' target='single'><span class='searchable'>#{method_name}</span><span class='desc'>#{method_desc}</span></a></li>"
      puts "-- #{method_name}"
    end
    
    navigation << "</ul>"
  end
  
  navigation << "</li>"
end

navigation << "</ul>"

File.open("#{version}/navigation.html", "w") { |f| f.write("#{html_start}\n#{navigation_head}\n#{html_mid}#{navigation}\n#{html_end}") }