# ruby /Users/rocco/code/games/update_outdated.rb "$(echo -ne "$(bundle outdated --filter-patch)")"

require "pry-rails"

gem_count = ENV["GEM_COUNT"]&.to_i

lines = ARGV[0].split("\n").select { |line| line.match?(/^\s*\*/) }
gemdata = lines.map { |line|
  {
    name:       line.match(/^\s*\* ([\w-]+)/).to_a[1],
    newest:     line.match(/newest ((?:\d+\.?)*)/).to_a[1],
    installed:  line.match(/installed ((?:\d+\.?)*)/).to_a[1],
    _requested: line.match(/requested = ((?:\d+\.?)*)/).to_a[1],
    _groups:    line.match(/in groups? \"(.*?)\"/).to_a[1]&.split(", "),
  }
}

gemfile = File.read("Gemfile")
gemdata.first(gem_count || gemdata.count).each do |data|
  next if ENV["SELECTED_GEM"] && ENV["SELECTED_GEM"] != data[:name]
  old_str = "gem \"#{data[:name]}\", \"#{data[:installed]}\""
  new_str = "gem \"#{data[:name]}\", \"#{data[:newest]}\""
  if gemfile.gsub!(old_str, new_str).nil?
    puts "\e[31mFailed to replace [#{old_str}] with [#{new_str}]\e[0m"
  else
    puts "\e[32mReplaced: [#{old_str}] => [#{new_str}]\e[0m"
  end
end
File.open("Gemfile", "w") { |f| f.puts gemfile }
