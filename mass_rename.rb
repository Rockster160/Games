directory = "/Users/rocconicholls/Downloads/*"
target = " copy"
newTarget = ""

Dir.glob(directory).sort.each do |entry|
  if File.basename(entry, File.extname(entry)).include?(target)
    newEntry = entry.gsub(target, newTarget)
    File.rename( entry, newEntry )
    puts "Rename from " + entry + " to " + newEntry
  end
end
