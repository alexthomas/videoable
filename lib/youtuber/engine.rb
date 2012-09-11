
module Youtuber

  class Engine < Rails::Engine

    initializer "youtuber.load_app_instance_data" do |app|
      Youtuber.setup do |config|
        config.app_root = app.root
        #config.add_feed :user => 'livestrong', :dev_key => 'AI39si5Nh-ajaWS3q5DXLi-kUx7ZFAlOWySn278vRPU1SuIDDU7I6roX9TFD6HpClsFK2ccL9IFmvShMqFMqpNCE7EM1riZ1JQ'
        config.add_feed :user => 'user3103460', :video_source => 'vimeo',:consumer_key => 'd1831f1350518e6125032ea1fd6fa7ee7b7567c5',:consumer_secret => '4b7f5afe3f4b657dccd358e33fa7cb914aa102bf' 
      end
    end

    initializer "youtuber.load_static_assets" do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
    end
    
    
  end

end