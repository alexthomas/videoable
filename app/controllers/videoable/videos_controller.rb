module Videoable
  
  class VideosController < ::ApplicationController
    
    def index
      Videoable::FeedParser.parse_feeds
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
      uploader = Videoable::Uploader.new('d1831f1350518e6125032ea1fd6fa7ee7b7567c5',
        '4b7f5afe3f4b657dccd358e33fa7cb914aa102bf',
        :atoken => '09cb943ba3379a5f35d0c73c3e1f88c4',
        :asecret => '9fa3bc0d546744080c9e638643cc237fd96119e7')
      @greedyIo = uploader.upload('bunny.mp4')
    end
  end
end