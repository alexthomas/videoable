module Youtuber
  
  class VideosController < ::ApplicationController
    
    def index
      Youtuber::Feed.feeds = []
      #Youtuber::Feed.add_feed :user => 'unitednations'
      Youtuber::Feed.parse_feeds
      @videos = Video.all
    end
    
    def search
      
    end
    
    def upload

      xml = "<note>
      <to>Tove</to>
      <from>Jani</from>
      <heading>Reminder</heading>
      <body>Don't forget me this weekend!</body>
      </note>"
      
      #io = File.open('test.mov')
      uploader = Youtuber::Uploader.new
      @greedyIo = uploader.upload('test.mov')
    end
  end
end