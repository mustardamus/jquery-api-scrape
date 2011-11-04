# Screen scraping http://api.jquery.com and building a navigation
#   Hacked together by Sebastian Senf (c) 20 10
#   Not the prettiest script, I know. Yet it does the job. Fork!

require "rubygems"
require "mechanize"

html_start = "<!DOCTYPE html>\n<html lang='en'><head><meta http-equiv='content-type' content='text/html; charset=UTF-8' /></head><body>"
html_end = "</body></html>"

agent = Mechanize.new
mainpage = agent.get("http://api.jquery.com/")

version = mainpage.search("#categories > ul > li:last > ul > li:last a")[0].text
version = version[8..version.length]

system("rm -r #{version}") #I know... :)
Dir.mkdir version
Dir.mkdir "#{version}/docs"

navigation = "<div id='search'><input type='search' placeholder='Search' autosave='searchdoc' results='10' id='search-field' autocomplete='off' /></div><ul id='static-list'>"

mainpage.search("#categories > ul > li > a").each do |mainlink|
  main_name = mainlink.text
  
  unless main_name == "All" || main_name == "Version"
    puts main_name

    navigation << "<li class='category'><span>#{main_name}</span><ul>"
    
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
        
        File.open("#{path}/index.html", "w") { |f| f.write("#{html_start}\n#{content}\n\n#{html_end}") }
      rescue Exception => e #file or folder exist
        #puts e.message 
      end
      
      navigation << "<li class='sub'><a href='docs/#{method_fold}/index.html'><span class='searchable'>#{method_name}</span><span class='desc'>#{method_desc}</span></a></li>"
      puts "-- #{method_name}"
    end
    
    navigation << "</ul>"
  end
  
  navigation << "</li>"
end

navigation << "</ul>"

File.open("#{version}/navigation.html", "w") { |f| f.write("#{html_start}\n#{navigation}\n#{html_end}") }