namespace :youtuber do
  task :world do
    p "world"
  end
  
  task :setup => "resque:setup"
end
