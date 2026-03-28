class SetStartLetterOnExistingSongs < ActiveRecord::Migration[8.0]
  def up
    Song.find_each do |song|
      song.update_column(:start_letter, song.send(:letter))
    end
  end

  def down
    Song.update_all(start_letter: nil)
  end
end
