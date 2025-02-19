# replacer = FileReplacer.new("config/routes.rb")
# replacer.within(/\n  resources :call_logs.*?\n  end/m) do |resources|
#   resources.within(/\n    collection do(.*?)\n    end/m) do |collection|
#     collection.add_after(/get :value_options/, "delete :woo")
#   end
# end
# replacer.save

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

  def show_diff
    diff_lines = diff
    total_count = diff_lines.count
    num = total_count.to_s.length
    i1, i2 = 0, 0
    diff_lines.each do |line|
      if line.is_a?(String)
        i1 = i2 + 1
        puts "\e[38;2;180;180;180m #{(i2+=1).to_s.rjust(num)} | #{line}\e[0m"
      else
        line[:add].each do |add_line|
          puts "\e[38;2;50;150;50m+#{(i2+=1).to_s.rjust(num)} | #{add_line}\e[0m"
        end
        line[:remove].each do |rem_line|
          puts "\e[38;2;150;50;50m-#{(i1+=1).to_s.rjust(num)} | #{rem_line}\e[0m"
        end
      end
    end
  end

  def diff
    str1, str2 = @starting_text, text
    lines1 = str1.split("\n")
    lines2 = str2.split("\n")
    diff_result = []
    idx1 = idx2 = 0
    current_remove = [] # Batch of removed lines
    current_add = []    # Batch of added lines

    loop do
      break if idx1 >= lines1.size && idx2 >= lines2.size

      l1 = lines1[idx1]
      l2 = lines2[idx2]

      # When lines match, flush any pending diff batch
      if idx1 < lines1.size && idx2 < lines2.size && l1 == l2
        if current_remove.any? || current_add.any?
          diff_result << { remove: current_remove, add: current_add }
          current_remove = []
          current_add = []
        end
        idx1 += 1
        idx2 += 1
        diff_result << l1
        next
      end

      # If one string has ended, treat the rest as diff
      if idx1 >= lines1.size
        current_add << lines2[idx2]
        idx2 += 1
        next
      end
      if idx2 >= lines2.size
        current_remove << lines1[idx1]
        idx1 += 1
        next
      end

      # Both lines exist but differ; attempt to realign using lookahead.
      pos_in_lines2 =
        idx1 + 1 < lines1.size ? lines2[idx2..-1].index(lines1[idx1 + 1]) : nil
      pos_in_lines1 =
        idx2 + 1 < lines2.size ? lines1[idx1..-1].index(lines2[idx2 + 1]) : nil

      if pos_in_lines2 && (!pos_in_lines1 || pos_in_lines2 <= pos_in_lines1)
        # Next line from lines1 found in lines2:
        # Batch current removal and add any intervening added lines.
        current_remove << l1
        current_add.concat(lines2[idx2...(idx2 + pos_in_lines2)])
        idx1 += 1
        idx2 += pos_in_lines2
      elsif pos_in_lines1
        # Next line from lines2 found in lines1:
        # Batch removals until that match and record current addition.
        current_remove.concat(lines1[idx1...(idx1 + pos_in_lines1)])
        current_add << l2
        idx1 += pos_in_lines1
        idx2 += 1
      else
        # No lookahead match; treat as a substitution.
        current_remove << l1
        current_add << l2
        idx1 += 1
        idx2 += 1
      end
    end

    diff_result << { remove: current_remove, add: current_add } if current_remove.any? || current_add.any?
    diff_result
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

  def method_missing(method, *args, &block)
    content.send(method, *args, &block)
  end
end
