class CreateTeamMembers < ActiveRecord::Migration
  def change
    create_table :yt_videos do |t|
      t.string :title
      t.text :description
      t.string :url
      t.string :code
      t.timestamps
    end
  end
end