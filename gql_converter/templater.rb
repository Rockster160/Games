module SlingshotUtils
  class TemplaterError < StandardError; end
  class Templater
    attr_accessor :filepath, :lines, :status

    def self.lines_from_template(root, template_path, opts={}, &block)
      text = File.read("#{root}/templates/#{template_path}.template")

      opts.each do |opt_key, opt_val|
        text.gsub!("{{#{opt_key.to_s}}}", opt_val.to_s)
      end

      if block_given? && text.include?("{{yield}}")
        text.gsub!(/( *)\{\{yield\}\}/) do
          indent_length = Regexp.last_match[1].length
          indent = " " * indent_length
          lines = yield
          next Regexp.last_match[0] if lines.blank?
          indent + lines.split("\n").join("\n#{indent}")
        end
      end

      text.split("\n")
    end

    def self.find_or_create(filepath)
      return new(filepath, status: :existing) if File.exists?(filepath)

      path, _, filename = filepath.to_s.rpartition("/")

      # Create nested directories
      FileUtils::mkdir_p(path)
      # Create empty file
      File.open(filepath, "w")
      file = new(filepath, status: :created)
      yield(file) if block_given?
      file
    end

    def initialize(filepath, status: :existing)
      @status = status
      @filepath = filepath
      @lines = File.read(filepath).split("\n")
    end

    def includes?(text)
      lines.join("").match?(text)
    end

    def write(newlines)
      File.write(@filepath, newlines.join("\n") + "\n")
      @lines = File.read(@filepath).split("\n")

      self
    end

    def insert(newlines, after_line: nil, after_text: nil, indent: true)
      if after_text.present?
        return insert_after_text(newlines, after_text: after_text, indent: indent)
      end

      if after_line.present?
        return insert_after_line(newlines, after_line: after_line, indent: indent)
      end

      raise TemplaterError, "Must include location to insert text"
    end

    private

    def insert_after_line(newlines, after_line: -1, indent: true)
      newlines = [newlines] if newlines.is_a?(String)
      prev_line_indent = lines[after_line][/^\s*/]
      new_indent = indent ? "  #{prev_line_indent}" : prev_line_indent

      new_file = lines.dup.tap { |changed_lines|
        new_text = newlines.map { |l| "#{new_indent}#{l}".presence }.join("\n")
        changed_lines[after_line] += "\n#{new_text}"
      }

      write(new_file)
    end

    def insert_after_text(newlines, after_text: nil, indent: true)
      after_idx = search_idx(after_text)

      insert_after_line(newlines, after_line: after_idx, indent: indent)
    end

    def search_idx(text, after: -1)
      found_idx = lines[(after+1)..-1].index { |l| l.match?(text) }
      raise TemplaterError, "Not found: #{text} after: #{after}" if found_idx.nil?

      (after + 1) + found_idx
    end
  end
end
