class CreateYoutuberVideoTable < ActiveRecord::Migration
  def change
    create_table :yt_videos do |t|
      t.string :video_id
      t.string :title
      t.text :description
      t.string :ytid
      t.integer :duration
      t.string :player_url
      t.boolean :widescreen
      t.boolean :noembed
      t.boolean :is_private
      t.datetime :published_at
      t.datetime :updated_at
      t.datetime :uploaded_at
      t.string :video_type
      t.integer :videoable_id
      t.string :videoable_type
      t.string :status
      t.string :ticket_id
      t.timestamps
    end
  end
end
