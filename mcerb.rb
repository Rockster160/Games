# MC ERB
#
# Call `mcerb /path/to/config.mcerb` to run
#
# Would need a project config to track: {
#   name / namespace
#   datapack location(s?) ((Could save the datapack to multiple directories!!))
#   taggable namespace
# }
#
# Fancy things:
# ```
# function func_name {
#   This defines a new function file that is called whenever <%= func_name %> is called
#   Anything inside of the brackets should be raw mcfunction that's injected
# }
# ```
#
# Find all tags and auto-apply namespacing

require "pry-rails"
require "json"
require "erb"
require "fileutils"
require "listen"

class MCERB
  def initialize(base_dir=".")
    @logging = true
    @log_data = []
    @base_dir = base_dir
    @base_path, _sep, @dir = @base_dir.rpartition("/")

    @config = JSON.parse(File.read("#{@base_dir}/mcerb/config.json"), symbolize_names: true)
    @save_paths = @config[:save].is_a?(Array) ? @config[:save] : [@config[:save]]
  end

  def go
    @save_paths.each do |save_path|
      save_dir = "#{save_path}/#{@dir}"
      FileUtils.remove_dir("#{save_dir}/data") if File.directory?("#{save_dir}/data")
    end

    Dir["#{@base_dir}/**/*"].each do |filename|
      log("Checking file #{filename}")
      next log("    Skipping DIR!", :bad) if File.directory?(filename)
      next log("    Skipping MCERB file!", :bad) if filename.include?("/mcerb/")
      log("  Copying file...")

      copy_file(filename)
      log("    Copy Complete!", :good)
    end
    # Also add a top level .txt file saying how it was generated- possibly contain details about what was parsed?
  end

  def session
    @session ||= begin
      if File.file?("#{@base_dir}/mcerb/helpers.rb")
        session_binding.eval(File.read("#{@base_dir}/mcerb/helpers.rb"))
        session_binding.eval("extend Helpers")
        session_binding
      else
        session_binding
      end
    end
  end

  def session_binding
    binding
  end

  def copy_file(src_filename)
    content = (
      if src_filename.end_with?(".mc.erb")
        log("  Embedding file...")
        embed_file_contents(src_filename)
      else
        log("  Using source")
        File.read(src_filename)
      end
    )

    rel_path = src_filename.sub(@base_path, "").sub(".mc.erb", ".mcfunction")
    log("  Saving file")
    save_file(rel_path, content)
  end

  def save_file(rel_filepath, contents)
    @save_paths.each do |save_path|
      path, _, rel_filename = rel_filepath.rpartition("/")
      full_save_path = save_path + path
      save_file_name = "#{full_save_path}/#{rel_filename}"

      FileUtils.mkpath(full_save_path)
      File.open(save_file_name, "w+") { |f| f.print contents }
    end
  end

  def embed_file_contents(mcerb_filename)
    ERB.new(File.read(mcerb_filename)).result(session)
  end

  def log(msg, status=:ok)
    @log_data << { msg: msg, status: status, time: Time.now }
    return unless @logging

    color_mapping = {
      good: 32,
      ok:   33,
      bad:  31,
    }

    color = color_mapping[status] || 35
    puts "\e[#{color}m#{msg}\e[0m"
  end
end

path = ARGV[0]
# "/Users/rocco/code/games/mc_datapacks/cauldron_brewing"

# Do some sort of validation here to make sure we can find the config file and such

listener = Listen.to(path) do |modified, added, removed|
  puts(modified: modified, added: added, removed: removed)
  MCERB.new(path).go
end
listener.start
sleep
