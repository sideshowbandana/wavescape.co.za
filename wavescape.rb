require "fileutils"
require "mechanize"
require "digest"
page = 
  pic = 
  agent = Mechanize.new{ |a|
  a.user_agent_alias = 'Mac Safari'
}
[
  ["https://www.wavescape.co.za/tools/webcams/big-bay.html", "bigbay"],
  ["https://www.wavescape.co.za/tools/webcams/kommetjie.html", "longbeach"],
  ["https://www.wavescape.co.za/tools/webcams/table-view.html", "tableview"],
  ["https://www.wavescape.co.za/tools/webcams/noordhoek.html", "noordhoek"],
  ["https://www.wavescape.co.za/tools/webcams/kalk-bay.html", "kalk-bay"]
].map do |page, pic|
  Thread.new do 
    begin
      FileUtils.mkdir_p(pic)
      previous_link = ""
      md5s = Dir.glob(File.join(pic, "*.jpg")).map{|img| Digest::MD5.hexdigest File.read(img) }
      while true do 
        time = Time.now.strftime("%F-%T")
        begin
          link = agent.get(page).links_with(href: /newfetch/).first.href
          file_out = "#{File.join(pic, time)}.jpg"
          unless previous_link == link
            puts "saving #{ link } as #{file_out}"
            agent.get(link).save(file_out)
          end
          puts "getting hexdigest of #{file_out}"
          md5 = Digest::MD5.hexdigest File.read(file_out)
          if md5s.include?(md5)
            puts "already downloaded #{file_out}"
            FileUtils.rm(file_out)
          else
            md5s << md5
          end
          previous_link = link
        rescue Errno::ENETDOWN
        end
        sleep 300
      end
    rescue
      puts "=" * 10
      puts "#{pic} has died"
      puts "=" * 10
    end
  end
end.map(&:join)
