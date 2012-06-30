module Youtuber
  class FeedParser
    
    attr_reader :entries
    
    def initialize(feed)
      @content = (feed =~ URI::regexp(%w(http https)) ? open(feed).read : false)
    rescue OpenURI::HTTPError => e
      raise OpenURI::HTTPError.new(e.io.status[0],e)
    rescue
      @content = false
      
    end  

    def parse
      @entries = (@content) ? parse_content(@content) : false
      yield self
    end
  
    def parse_video video
      video_id = video.at("id").text
      published_at = video.at("published") ? Time.parse(video.at("published").text) : nil
      uploaded_at = video.at_xpath("media:group/yt:uploaded") ? Time.parse(video.at_xpath("media:group/yt:uploaded").text) : nil
      updated_at = video.at("updated") ? Time.parse(video.at("updated").text) : nil

      title = video.at("title").text
     
      media_group = video.at_xpath('media:group')
      ytid = nil
      unless media_group.at_xpath("yt:videoid").nil?
        ytid = media_group.at_xpath("yt:videoid").text
      end

      # if content is not available on certain region, there is no media:description, media:player or yt:duration
      description = ""
      unless media_group.at_xpath("media:description").nil?
        description = media_group.at_xpath("media:description").text
      end
      
      duration = 0
      unless media_group.at_xpath("yt:duration").nil?
        duration = media_group.at_xpath("yt:duration")["seconds"].to_i
      end

      player_url = ""
      unless media_group.at_xpath("media:player").nil?
        player_url = media_group.at_xpath("media:player")["url"]
      end
      
      widescreen = nil
      unless media_group.at_xpath("yt:aspectRatio").nil?
        widescreen = media_group.at_xpath("yt:aspectRatio").text == 'widescreen' ? true : false
      end

      media_content = []
      media_group.xpath("media:content").each do |mce|
        #media_content << parse_media_content(mce)
      end

      noembed     = video.at_xpath("yt:noembed") ? true : false

      if video.namespaces['xmlns:app']
        control = video.at_xpath("app:control")
        state = { :name => "published" }
        if control && control.at_xpath("yt:state")
          state = {
            :name        => control.at_xpath("yt:state")["name"],
            :reason_code => control.at_xpath("yt:state")["reasonCode"],
            :help_url    => control.at_xpath("yt:state")["helpUrl"],
            :copy        => control.at_xpath("yt:state").text
          }
        end
      end

      is_private = media_group.at_xpath("yt:private") ? true : false

      video = {
        :video_id       => video_id,
        :published_at   => published_at,
        :updated_at     => updated_at,
        :uploaded_at    => uploaded_at,
        
        :description    => description,
        :duration       => duration,
        :player_url     => player_url,
        :widescreen     => widescreen,
        :noembed        => noembed,
        :state          => state,
        :ytid      => ytid,
        :is_private   => is_private}
    end
    
    def parse_content content
      entries = []
      doc  = Nokogiri::XML(content)
      doc.css("entry").each do |entry|
        entries << entry
      end
      feed = doc.at('feed')
      if feed && entries.length > 1
        feed_id            = feed.at("id").text
        updated_at         = Time.parse(feed.at("updated").text)
        total_result_count = feed.at_xpath("openSearch:totalResults").text.to_i
        offset             = feed.at_xpath("openSearch:startIndex").text.to_i
        max_result_count   = feed.at_xpath("openSearch:itemsPerPage").text.to_i
      end
      entries
    end
  
    def have_content?
      @content
    end
  end
end