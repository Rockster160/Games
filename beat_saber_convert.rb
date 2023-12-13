#!/usr/bin/env ruby

# open -a "Google Chrome" "https://bsaber.com/?s=Iridium"
# open -a "Google Chrome" "https://bsaber.com/?s=Arcade+Busters"
# open -a "Google Chrome" "https://bsaber.com/?s=Majesty"
# open -a "Google Chrome" "https://bsaber.com/?s=Dire+Dire+Docks"
# open -a "Google Chrome" "https://bsaber.com/?s=YYZ"
# open -a "Google Chrome" "https://bsaber.com/?s=Chinese+Restaurant"
# open -a "Google Chrome" "https://bsaber.com/?s=NiceNiceNice"
# open -a "Google Chrome" "https://bsaber.com/?s=Blue+Zenith"

def pst(msg, color: :grey)
  code = (
    case color
    when :grey   then 90
    when :red    then 31
    when :yellow then 33
    when :green  then 32
    when :cyan   then 36
    else 90
    end
  )
  puts "\e[#{code}m#{msg}\e[0m"
end

# Iterate through zip files in the current directory
Dir["*.zip"].each do |zip_file|
  folder_name = zip_file.match(/^(.*)\.zip$/)[1]

  if File.directory?(folder_name)
    File.delete(zip_file)
    pst "Unzipped already exists: #{folder_name}. Deleting #{zip_file}"
    next
  end

  # Create a folder with the extracted name
  Dir.mkdir(folder_name)

  # Extract the contents of the zip file into the created folder
  system("unzip -q '#{zip_file.gsub("'", "\\'")}' -d '#{folder_name.gsub("'", "\\'")}'")
  File.delete(zip_file)

  puts "Extracted: #{zip_file} -> #{folder_name}/"
rescue StandardError => e
  pst("zip[#{e.class}]#{e.message}", color: :red)
end

Dir["*/"].each do |song_file|
  filename = song_file.match(/^[\w]{3,6} \((.*?)\)\/$/).to_a[1]
  next if filename.nil?

  if File.directory?(filename)
    pst "File already exists: #{filename}. Deleting #{song_file}"
    system("rm -r '#{song_file.gsub("'", "\\'")}'")
    next
  end

  File.rename(song_file, filename)
  system("mv '#{filename.gsub("'", "\\'")}' '#{song_file.gsub("'", "\\'")}'")
  puts "Renamed: #{song_file} -> #{filename}"
rescue StandardError => e
  pst("mv[#{e.class}]#{e.message}", color: :red)
end
