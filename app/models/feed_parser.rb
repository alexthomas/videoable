module Youtuber
  class FeedParser
    
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

      title = entry.at("title").text
     
      media_group = entry.at_xpath('media:group')
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
        media_content << parse_media_content(mce)
      end

      noembed     = entry.at_xpath("yt:noembed") ? true : false

      if entry.namespaces['xmlns:app']
        control = entry.at_xpath("app:control")
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

      insight_uri = (entry.at_xpath('xmlns:link[@rel="http://gdata.youtube.com/schemas/2007#insight.views"]')['href'] rescue nil)

      perm_private = media_group.at_xpath("yt:private") ? true : false

      YouTubeIt::Model::Video.new(
        :video_id       => video_id,
        :published_at   => published_at,
        :updated_at     => updated_at,
        :uploaded_at    => uploaded_at,
        :categories     => categories,
        :keywords       => keywords,
        :title          => title,
        :html_content   => html_content,
        :author         => author,
        :description    => description,
        :duration       => duration,
        :media_content  => media_content,
        :player_url     => player_url,
        :thumbnails     => thumbnails,
        :rating         => rating,
        :view_count     => view_count,
        :favorite_count => favorite_count,
        :comment_count  => comment_count,
        :access_control => access_control,
        :widescreen     => widescreen,
        :noembed        => noembed,
        :safe_search    => safe_search,
        :position       => position,
        :latitude       => latitude,
        :longitude      => longitude,
        :state          => state,
        :insight_uri    => insight_uri,
        :unique_id      => ytid,
        :perm_private   => perm_private)
    end
      
    end
    
    def parse_content content
      entries = []
      doc  = Nokogiri::XML(content)
      doc.xpath("//entry").each do |entry|
        entries << entry
      end
    
      if doc.at('feed') && entries.length > 1
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