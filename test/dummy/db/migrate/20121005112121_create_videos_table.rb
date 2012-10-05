class CreateVideosTable < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.string :title
      t.string :description
    end
  end
end
