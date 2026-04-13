# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Admin user
admin_email = "admin@example.com"
admin = User.find_or_initialize_by(email: admin_email)
if admin.new_record?
  generated_password = SecureRandom.hex(10)
  admin.password = generated_password
  admin.role = "admin"
  admin.save!
  puts "Created admin user — login with:"
  puts "  Email:    #{admin_email}"
  puts "  Password: #{generated_password}"
else
  admin.update!(role: "admin") unless admin.admin?
  puts "Admin user already exists: #{admin_email}"
end

# Songs
songs_data = JSON.parse(File.read(Rails.root.join("db/seeds/songs.json")))

songs_data.each do |attrs|
  Song.find_or_create_by!(lyrics: attrs["lyrics"]) do |song|
    song.movie = attrs["movie"]
    song.year  = attrs["year"]
    song.user  = admin
  end
end

puts "Seeded #{Song.count} songs."
