#!/usr/bin/env ruby

# -- Call with song names to look them up
# bsaber Iridium Hottogo "Simple and clean" "Ocean Avenue"

# -- Call with a path to a file to convert/transfer it
# bsaber /Users/rocco/Downloads/425d4\ \(Simple\ And\ Clean\ -\ RateGyro\ \&\ OneSpookyBoi\).zip

# Finder → Locations → Network → zoropc → Connect As → Registered User → username:"owner" password: Z!
# cd to the current (downloads) directory before running!

# open -a "Google Chrome" "https://bsaber.com/?s=Iridium"

@args, @options = ARGV.each_with_object([[], []]) { |arg, memo|
  arg.start_with?("--") ? memo[1] << arg : memo[0] << arg
}

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
  @code = code
  puts "\e[#{code}m#{msg}\e[0m"
end

def esc(original_filename)
  original_filename.gsub(/[ \(\)\&\'\"\$\`\*\?\!\{\}\[\]\;\|\>\<\\]/) { |match| "\\" + "#{match}" }
end

def show(file)
  "'\e[94m#{file}\e[#{@code || 0}m'"
end

def path_and_folder(filepath)
  *path, filename = filepath.gsub(/\/$/, "").split("/")
  [path.join("/") + "/", filename]
end

def unzip(path, folder)
  old_filepath = [path, folder].join("")
  folder_name = folder.match(/^(.*)\.zip$/i).to_a[1]

  new_filepath = [path, folder_name].join("")
  if folder_name.nil?
    return [path, folder]
  elsif File.directory?(new_filepath)
    pst "Unzipped already exists: #{show(folder_name)}"
    pst " → Deleting #{show(folder)}" if File.exist?(old_filepath)
    File.delete(old_filepath) if File.exist?(old_filepath)
    return [path, folder_name]
  end

  # Create a folder with the extracted name
  system("mkdir #{esc(new_filepath)}")
  # Extract the contents of the zip file into the created folder
  system("unzip -q #{esc(old_filepath)} -d #{esc(new_filepath)}")
  # Remove the old zipfile
  system("rm #{esc(old_filepath)}")

  pst "Extracted: #{show(folder)} → #{show(folder_name)}"
  return [path, folder_name]
rescue StandardError => e
  pst("zip[#{e.class}]#{e.message}", color: :red)
end

def correct_filename(path, folder)
  filename = folder.match(/^[\w]{3,6}.*?\((.*?)\\?\)\/?$/).to_a[1]
  return [path, folder] if filename.nil?

  old_filepath = [path, folder].join("")
  new_filepath = [path, filename].join("")
  if File.directory?(new_filepath)
    pst "File already exists: #{show(new_filepath)}"
    pst "Deleting #{show(folder)}" if File.exist?(old_filepath)
    system("rm -r #{esc(new_filepath)}") if File.exist?(old_filepath)
    return [path, filename]
  end

  # File.rename(folder, new_filepath)
  system("mv #{esc(old_filepath)} #{esc(new_filepath)}")
  pst "Renamed: #{show(folder)} → #{show(filename)}"
  return [path, filename]
rescue StandardError => e
  pst("rename[#{e.class}]#{e.message}", color: :red)
end

def transfer(path, folder)
  filepath = [path, folder].join("")

  # "/Users/rocco/Downloads/TWENTY\\ TWENTY\\ -\\ Jonas_0_0,\\ minsiii"
  if system("mv #{esc(filepath)} /Volumes/CustomLevels/#{esc(folder)}")
    pst("File moved to Windows: #{show(folder)}")
  else
    pst("Failed to move #{show(folder)}", color: :red)
  end

  return [path, folder]
rescue StandardError => e
  pst("mv[#{e.class}]#{e.message}", color: :red)
end

# --------------------------------------------------------------------------------------------------

if @options.include?("--fix-transferred")
  bad_files = Dir.glob("/Volumes/CustomLevels/*").select {|f| f.match?(/[\w]{3,6} \((.*?)\)\/?$/)}
  bad_files.each do |bad_file|
    filename = bad_file.match(/^.*?\/(.*?)$/).to_a[1]
    new_filename = filename.match(/^[\w]{3,6} \((.*?)\)\/?$/).to_a[1]
    new_file = bad_file.gsub(filename, new_filename)
    pst "Renaming: #{show(filename)} → #{show(new_filename)}"
    system("mv #{esc(bad_file)} #{esc(new_file)}")
  end
  exit
end

if !@args.first.to_s.include?("/")
  require "uri"

  ARGV.each do |str|
    pst " → Searching #{show(str)}"
    `open -a \"Google Chrome\" \"https://beatsaver.com/?q=#{URI::Parser.new.escape(str)}\"`
  end
  pst " → /Users/rocco/code/games/beatsaber/convert.rb"
  exit
end

if ARGV.empty?
  pst " → /Users/rocco/code/games/beatsaber/convert.rb"
  exit
end

if !Dir.exist?("/Volumes/CustomLevels") || @options.include?("--skip-transfer")
  puts "\e[31m[ERROR] -- Windows drive not mounted\e[0m"
  puts "\e[90m → include --skip-transfer to bypass\e[0m"
  puts "\e[90m → Finder → Locations → Network → zoropc → Connect As → Registered User → username:\"owner\" password: Z!\e[0m"
  puts "\e[90m → [NOTE!] After connecting, be sure to double-click/open the CustomLevels file to complete the connection.\e[0m"
  exit
end

`cd /Users/rocco/Downloads`

folders = @args.map { |filename| path_and_folder(filename) }
unzipped = folders.filter_map { |path, folder| unzip(path, folder) }
corrected = unzipped.filter_map { |path, folder| correct_filename(path, folder) }
corrected.filter_map { |path, folder| transfer(path, folder) } unless @options.include?("--skip-transfer")
