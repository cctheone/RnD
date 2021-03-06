class CreateLyrics < ActiveRecord::Migration
  def change
    create_table :lyrics do |t|
      t.text :line
      t.text :description
      t.string :artist
      t.string :song
      t.string :album
      t.string :link

      t.timestamps
    end
  end
end
