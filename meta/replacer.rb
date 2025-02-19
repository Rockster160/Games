# TODO: Get rid of FileMatcher in favor of Replacer

# require "/Users/rocco/code/ocs-backend/_scripts/meta/lib/replacer.rb"

# ----- For multiple files file -----
# require "/Users/rocco/code/games/meta/replacer.rb"
## Use `replace!` or `Replacer.new(make_changes: true).replace` to apply changes
# Replacer.replace(
#   "app/validations/**/*.rb": {
#     /\s*(required|optional)_associations(\(.*?\)|\s*.*?$))?/m => -> (matcher) {
#       next if matcher.file.match?(/base_validation.rb/)

#       "new text to replace with"
#     }
#   },
# )

# ----- For an individual file -----
# require "/Users/rocco/code/games/meta/file_replacer.rb"
# replacer = FileReplacer.new("config/routes.rb")
# replacer.within(/\n  resources :call_logs.*?\n  end/m) do |resources|
#   resources.within(/\n    collection do(.*?)\n    end/m) do |collection|
#     collection.add_after(/get :value_options/, "delete :woo")
#   end
# end
# replacer.save

require_relative "file_matcher"

class Replacer
  def self.replace(data)
    new.replace(data)
  end

  def self.replace!(data)
    new.replace!(data)
  end

  def initialize(quiet: nil, make_changes: nil)
    @quiet = quiet.nil? ? (ARGV.include?("--quiet") || ARGV.include?("-q")) : quiet
    @make_changes = make_changes.nil? ? (ARGV.include?("--change") || ARGV.include?("-c")) : make_changes
  end

  def find_files(glob)
    return Dir.glob(glob.to_s) if glob.is_a?(String) || glob.is_a?(Symbol)

    @all_files ||= Dir.glob("**/*").select { |f| File.file?(f) }.uniq
    backoff = glob.to_s.scan(/\(\?\-mix\:((?:\\.\\.\\\/)+)/).length
    files = backoff == 0 ? @all_files : Dir.glob("../ocs-frontend/**/*").select { |f| File.file?(f) }.uniq
    files.select { |file| file.match?(Regexp.new(glob.to_s)) }
    # TODO: Do more magic with the backoff to work properly without globbing the entire universe
    # backoff = glob.to_s.scan(/\(\?\-mix\:((?:\\.\\.\\\/)+)/).length
    # files = backoff == 0 ? @all_files : Dir.glob("#{"../"*backoff}**/*").select { |f| File.file?(f) }.uniq
    # files.select { |file| file.match?(Regexp.new(glob.to_s)) }
  end

  def replace!(data)
    replace(data, preview: false)
  end

  def show(text)
    text.gsub(" ", "·").gsub("\n", "¶\n") # dot and newline
  end

  def replace(data=nil, preview: !@make_changes)
    return if data.nil?

    any_changes = false
    data.each do |glob, changes|
      find_files(glob).each do |file|
        changed = false
        content = File.read(file)
        changes.each do |text, blo|
          content.gsub!(Regexp.new(text.to_s)) do |found|
            blo.call(FileMatcher.new(file, Regexp.last_match)).then { |new_text|
              new_text.nil? ? found : new_text
            }.tap { |new_text|
              unchanged = new_text == found
              any_changes = changed = true unless unchanged

              next if @quiet
              puts "\e[90m#{file}\e[0m"
              if unchanged
                puts "\e[36m → #{show(new_text)}\e[0m"
              else
                puts "\e[33m → #{show(found)}\e[0m"
                puts "\e[32m → #{show(new_text)}\e[0m"
              end
            }
          end
        end

        File.write(file, content) if !preview && changed
      end
    end

    puts "\e[94mFiles unchanged! Rerun with `--change` to apply changes\e[0m" if preview && any_changes
    puts "\e[33mNo changes!\e[0m" if !any_changes
  end
end
