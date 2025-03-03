# replacer = FileReplacer.new("config/routes.rb")
# replacer.within(/\n  resources :call_logs.*?\n  end/m) do |resources|
#   resources.within(/\n    collection do(.*?)\n    end/m) do |collection|
#     collection.add_after(/get :value_options/, "delete :woo")
#   end
# end
# replacer.save
require "/Users/rocco/code/games/meta/differ.rb"

class ReplaceableText
  attr_accessor :text, :starting_text, :matchdata

  def initialize(text, matchdata=nil)
    @matchdata = matchdata
    @starting_text = text.dup
    @text = text
  end

  def recurse_klass
    @skip_replace ? DiggableText : ReplaceableText
  end

  def within(find, text=nil, &block)
    did_find = @text.gsub!(find) do |found|
      next text unless block_given?

      recurse_klass.new(found, Regexp.last_match).then { |rtext|
        replaced = block.call(rtext)
        replaced.nil? ? found : replaced
      }
    end
    did_find.nil? ? nil : self
  end

  def between(open_match, close_match=nil, text=nil, &block)
    rxs = scan_full_lines(open_match).map { |start_line|
      indent = indent_of(start_line)
      /(?<open_match>#{Regexp.escape(start_line)})(?<inner_content>.*?)(?<close_match>\n#{indent}(?<=\s)(?=\S)#{close_match}.*?$)/m
    }
    return if rxs.empty?
    within(/^(?:#{rxs.join("|")})/m, text, &block)
  end

  def inside(open_match, close_match=nil, text=nil, &block)
    between(open_match, close_match, text, &block)
  end

  def replace(find, text=nil, &block)
    within(find, text, &block)
  end

  def changed?
    @text != @starting_text
  end

  def show_diff(only_changes: false)
    Differ.compare(@starting_text, @text, only_changes: only_changes)
  end

  def diff
    Differ.diff(@starting_text, @text)
  end

  def full_line(line)
    if line.is_a?(Regexp)
      content[/^[^\n]*?#{line.source}[^\n]*?$/m].to_s
    else
      line = line.to_s.gsub(/\A\s*/m, "")
      content[/^[^\n]*?#{Regexp.escape(line)}[^\n]*?$/m].to_s
    end
  end

  def scan_full_lines(line)
    if line.is_a?(Regexp)
      content.scan(/^[^\n]*?#{line.source}[^\n]*?$/m)
    else
      line = line.to_s.gsub(/\A\s*/m, "")
      content.scan(/^[^\n]*?#{Regexp.escape(line)}[^\n]*?$/m)
    end
  end

  def indent
    indent_of(@text)
  end

  def indent_of(line)
    full_line(line)[/^( *)/, 1].to_s
  end

  def add_before(match, text=nil, indent: 0, &block)
    replace(/^.*?#{match}.*?$/) do |found|
      new_text = (
        if block_given?
          recurse_klass.new(found, Regexp.last_match).tap { |rtext| block.call(rtext) }.text
        else
          text
        end
      )

      indented_text = ("\n" + new_text).gsub(/\n/, "\n" + indent_of(found) + ("  "*indent))
      found.gsub(match) { |f| indented_text + f }.gsub(/\n\s+\n/, "\n\n")
    end
  end

  # def add_after(**args, index: ) # index could be `nil` for all matches, an array|range, or something like -1 to say last match only
  def add_after(match, text=nil, indent: 0, &block)
    replace(/^.*?#{match}.*?$/) do |found|
      new_text = (
        if block_given?
          recurse_klass.new(found, Regexp.last_match).tap { |rtext| block.call(rtext) }.text
        else
          text
        end
      )
      found + ("\n" + new_text).gsub(/\n/, "\n" + indent_of(found) + ("  "*indent)).gsub(/\n\s+\n/, "\n\n")
    end
  end

  # BE CAREFUL! This will not work for multiple matches that are the same text content!
  def add_after_last(match, text=nil, &block)
    scan_full_lines(match).last&.then { |end_line|
      add_after(end_line, text, &block)
    }
  end

  # def insert_inside(open, close, ...)
  def add_under(match, text=nil, indent: 1, &block)
    add_after(match, text, indent: indent, &block)
  end

  def content
    @text
  end

  def open_match
    matchdata[:open_match]
  end

  def close_match
    matchdata[:close_match]
  end

  def inner_content
    matchdata[:inner_content]
  end

  def [](matcher)
    matchdata[matcher]
  end

  def to_s
    @text
  end

  def method_missing(method, *args, &block)
    @text.send(method, *args, &block)
  end
end

class DiggableText < ReplaceableText
  def initialize(*args)
    super(*args)
    @skip_replace = true
  end

  def within(find, text=nil, &block)
    did_find = @text.gsub(find) do |found|
      next found unless block_given?

      recurse_klass.new(found, Regexp.last_match).then { |rtext|
        replaced = block.call(rtext)
        replaced.nil? ? found : replaced
      }
    end
    did_find.nil? ? nil : self
  end
end

class FileReplacer
  attr_accessor :file_path, :working, :valid, :matchdata

  def self.work(file_path, &block)
    new(file_path).work(&block)
  end

  def initialize(file_path)
    @working = false
    @file_path = file_path

    @valid = File.file?(@file_path)
    @file_path = Dir.glob(@file_path).first if !@valid
    @valid = @file_path && File.file?(@file_path)

    return puts "\e[31mNo file found! \e[4m#{file_path}\e[0m" unless @valid
    @starting_text = File.read(@file_path)
  end

  def work(&block)
    @working = true
    self.instance_eval(&block)
    @working = false
    save
  end

  def file?
    @valid
  end

  def changed?
    text != @starting_text
  end

  def content
    @content ||= ReplaceableText.new(@starting_text.dup)
  end

  def text
    content.text
  end

  def to_s
    content.text
  end

  def save
    return false unless changed?

    File.write(@file_path, text) unless @working
  end

  def open
    puts "\e[90mOpening \e[4m#{file_path}\e[0m\e[90m...\e[0m"
    `/usr/local/bin/code "#{file_path}" --reuse-window`
  end

  def add_import(*klasses, from:)
    within(/^import { ?(.*?) ?} from ["']#{from}["'];/) { |imports|
      prev = imports[1].strip.split(/,/).map { |s| s.strip.to_sym }
      imports.replace(imports[1], (prev + klasses.map(&:to_sym)).uniq.join(", "))
    } || add_after_last(/^import [^;]*;$/m, "import { #{klasses.join(", ")} } from \"#{from}\";")
  end

  def show_diff(only_changes: false)
    # Need to be explicit because of named arguments, maybe?
    content.show_diff(only_changes: only_changes)
  end

  def method_missing(method, *args, &block)
    content.send(method, *args, &block)
  end
end
