module Youtuber
  
  module Parser
    class VimeoParser < FeedParser
      
      
      
      def parse_content content
        entries = content.is_a?(String) ? JSON.parse(content) : content
        Youtuber::Response.new(
          :entries             => entries)
      end
      
      def parse_video video
         noembed = video['embed_privacy'] == 'anywhere' ? false : true
         Youtuber::Video.new(
           :video_id       => video['id'],
           :uploaded_at    => video['upload_date'],

           :title          => video['title'],
           :description    => video['description'],
           :duration       => video['duration'],
           :player_url     => video['url'],
           :noembed        => noembed,
           :is_private   => false,
           :video_type  => 'vimeo'
           )
      end
      
    end
  end
  
end