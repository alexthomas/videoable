module Youtuber
  module Responses
    class YoutubeResponse < Response
     attr_reader :updated_at,:page

   
     def current_page
       offset > 1 ? (offset / items_per_page) + 1 : 1
     end
   
     # current_page + 1 or nil if there is no next page
     def next_page
       current_page < total_pages ? (current_page + 1) : nil
     end

     def total_pages
       (total_result_count / items_per_page.to_f).ceil
     end
   
     def next_offset
        next_page != nil ? ((next_page - 1) * items_per_page) + 1 : nil
     end

    end
  end
  
end