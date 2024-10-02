#!/usr/bin/env ruby

# Finder → Locations → Network → zoropc → connect → username:"owner" password: Z!
# cd to the current (downloads) directory before running!

# open -a "Google Chrome" "https://bsaber.com/?s=Iridium"

def url_list(array)
  [
    "She Wants Me by The Happy Fits",
    "Something Just Like This",
    "Wake Me Up by Avicii",
    "Determinate",
  ].each { |str|
    `open -a \"Google Chrome\" \"https://bsaber.com/?s=#{URI::Parser.new.escape(str)}\"`
  }
end

def esc(original_filename)
  escaped = original_filename.gsub(/[ \(\)\&\'\"\$\`\*\?\!\{\}\[\]\;\|\>\<\\]/) { |match| "\\" + "#{match}" }
  *path, filename = escaped.gsub(/\/$/, "").split("/")
  [path.join("/") + "/", filename]
end

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

def unzip(path, folder)
  old_filepath = [path, folder].join("")
  folder_name = folder.match(/^(.*)\.zip$/i).to_a[1]

  new_filepath = [path, folder_name].join("")
  if folder_name.nil?
    return [path, folder]
  elsif File.directory?(new_filepath)
    File.delete(old_filepath)
    pst "Unzipped already exists: #{folder_name}. Deleting #{folder}"
    return [path, folder_name]
  end

  # Create a folder with the extracted name
  system("mkdir #{new_filepath}")
  # Extract the contents of the zip file into the created folder
  system("unzip -q #{old_filepath} -d #{new_filepath}")
  # Remove the old zipfile
  system("rm #{old_filepath}")

  pst "Extracted: #{folder} → #{folder_name}"
  return [path, folder_name]
rescue StandardError => e
  pst("zip[#{e.class}]#{e.message}", color: :red)
end

def correct_filename(path, folder)
  filename = folder.match(/^[\w]{3,6} \((.*?)\)\/?$/).to_a[1]
  return [path, folder] if filename.nil?

  new_filepath = [path, filename].join("")
  if File.directory?(new_filepath)
    pst "File already exists: #{new_filepath}. Deleting #{folder}"
    system("rm -r #{new_filepath}")
    return [path, filename]
  end

  old_filepath = [path, folder].join("")
  # File.rename(folder, new_filepath)
  system("mv #{old_filepath} #{new_filepath}")
  pst "Renamed: #{folder} → #{filename}"
  return [path, filename]
rescue StandardError => e
  pst("rename[#{e.class}]#{e.message}", color: :red)
end

def transfer(path, folder)
  filepath = [path, folder].join("")

  # "/Users/rocco/Downloads/TWENTY\\ TWENTY\\ -\\ Jonas_0_0,\\ minsiii"
  if system("mv #{filepath} /Volumes/CustomLevels/#{folder}")
    pst("File moved to Windows: #{folder}")
  else
    pst("Failed to move #{folder}", color: :red)
  end

  return [path, folder]
rescue StandardError => e
  pst("mv[#{e.class}]#{e.message}", color: :red)
end

folders = ARGV.map { |folder| esc(folder) }
unzipped = folders.filter_map { |path, folder| unzip(path, folder) }
corrected = unzipped.filter_map { |path, folder| correct_filename(path, folder) }
corrected.filter_map { |path, folder| transfer(path, folder) }
