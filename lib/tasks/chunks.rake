namespace :chunks do
  desc "Recreate chunks for all songs"
  task recreate: :environment do
    songs = Song.all
    puts "Recreating chunks for #{songs.count} songs..."
    songs.each do |song|
      song.send(:create_chunks)
      print "."
    end
    puts "\nDone."
  end
end
