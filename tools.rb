# require "/Users/rocco/code/games/tools.rb"

require "pry-rails"
require "/Users/rocco/code/games/tools_json_parser"
require "/Users/rocco/code/games/to_table.rb"

class Tools
  class << self
    def inspect
      pst("Tools.random_color")
      pst("Tools.pigment(\"#FF0000\")")
      pst("Tools.count_each(arr)")
      pst("Tools.months_between(date1, date2)")
      pst("Tools.measure_block do ...")
      pst("Tools.measure_x_blocks(count=1000) do ...")
      pst("Tools.table([[:abc, 1], [:b, 2345]])")
      pst("Tools.pretty_json(\"{\"sup\"=> :foo}\")")
      pst("Tools.duration(2366)")

      super
    end

    def pst(str)
      puts "\e[33m#{str}\e[0m"
    end

    # Random Color
    def random_color
      "##{('%06x' % (rand * 0xffffff))}".upcase
    end

    def hex_to_rgb(hex)
      hex = hex.strip.gsub("#", "")
      hex = hex.length == 3 ? hex.split("").map { |v| "#{v}#{v}" } : hex
      raise "Invalid format. Must pass a valid 3 or 6 length hex string." unless hex.match?(/^[0-9a-f]{6}$/i)

      r, g, b = hex.scan(/.{2}/).map { |v| v.to_i(16) }
    end

    # Terminal output of the color
    def pigment(val)
      r, g, b = hex_to_rgb(val)
      contrast = val[1..6].to_i(16) > 0xffffff / 2 ? "30" : "97"
      "\e[48;2;#{r};#{g};#{b}m\e[#{contrast}m#{val}\e[0m"
    end

    def apply_pigments(str, rx=nil)
      # puts Tools.apply_pigments(output_string) # Highlight ALL Hex Colors
      # puts Tools.apply_pigments(output_string, / color:.*?\n/) # Highlight Hex Colors in matching area
      str.gsub(rx || /#[0-9a-f]{6}(?:\b|$)/i) { |val|
        val.match?(/^#[0-9a-f]{6}$/i) ? pigment(val) : apply_pigments(val)
      }
    end

    # Count same objects in array
    def count_each(arr)
      arr.each_with_object(Hash.new(0)) { |instance, count_hash| count_hash[instance] += 1 }
    end
    # count_each(%w( a a a b c b b a a c ))
    #=> {"a"=>5, "b"=>3, "c"=>2}

    # Find the age based on the date
    def age(dob)
      require "date"

      now = Time.now.to_date
      dob = Date.parse(dob) if dob.is_a?(String)
      now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
    end
    #=> 26

    # Count the number of months between 2 dates
    def months_between(date_str1, date_str2)
      date1 = date_str1.to_datetime
      date2 = date_str2.to_datetime
      (date2.year - date1.year) * 12 + date2.month - date1.month - (date2.day >= date1.day ? 0 : 1)
    end
    #=> 5

    # Returns a string for a number with comma delimiters
    def delimiter(num)
      num.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
    end
    #=> "1,234,567"

    class DotHash < Hash
      def method_missing(method, *args, &block)
        if self.key?(method.to_s.to_sym)
          self[method.to_s.to_sym]
        else
          super
        end
      end

      def branches(hash=nil)
        hash ||= self
        return hash unless hash.is_a?(Hash) || hash.is_a?(Array)
        return hash if hash.is_a?(Hash) && hash.none? { |k, v| v.is_a?(Hash) }

        # Hash with hashes
        if hash.is_a?(Array)
          hash = hash.each_with_index.with_object({}) do |(bval, idx), obj|
            obj["#{idx}"] = bval
          end
        end
        hash.each_with_object({}) do |(k, v), obj|
          next obj[k.to_s] = v if v.nil? || v == false # Falsey things will act weird in #branches

          bdata = branches(v)
          case bdata
          when Hash
            bdata.each do |bkey, bval|
              obj["#{k}.#{bkey}"] = bval
            end
          else
            obj["#{k}"] = bdata
          end
        end
      end
    end

    # Allows a hash to be dot-accessible
    def to_dot(hash)
      JSON.parse(hash.to_json, object_class: DotHash, symbolize_names: true)
    end

    # Flatten the hash so it is one level deep, using dot splitters
    def branches(hash)
      pp to_dot(hash).branches
    end
    # { a: nil, b: [1, 2, 3], c: { e: :f, g: [:a2, :b2, :c2], h: {a3: 1, b3: 2, c3: 3} }, d: 1 }
    # {"a"=>nil,
    #   "b.0"=>1,
    #   "b.1"=>2,
    #   "b.2"=>3,
    #   "c.e"=>"f",
    #   "c.g.0"=>"a2",
    #   "c.g.1"=>"b2",
    #   "c.g.2"=>"c2",
    #   "c.h.a3"=>1,
    #   "c.h.b3"=>2,
    #   "c.h.c3"=>3,
    #   "d"=>1}

    # Get the accessible methods of an object/class
    def methods(obj)
      obj.methods - Object.methods
    end

    # Measure how long a block of code takes
    def measure_block(&block)
      t = Time.now.to_f
      yield
      duration(t - Time.now.to_f)
    end
    def measure_x_blocks(count=10000, &block)
      count.times.map { measure_block(&block) }.sum / count.to_f
    end

    # Output array as a table
    def uncolor(str) = str.to_s.gsub(/\e\[.*?m/, "")
    def invisible_count(str) = str.to_s.scan(/\e\[[\d;]+m/).join.length
    def table(array)
      column_widths = array.transpose.map { |col| col.map { |cell| uncolor(cell).length }.max + 1 }
      array.each do |row|
        row.each_with_index do |cell, x|
          clean = uncolor(cell)
          just = x == 0 ? :ljust : :rjust
          cell = cell.to_s&.tap { |s| s.gsub!(clean, clean[1..]) if clean[0] == ":" }
          print " " unless x == 0
          print clean.send(just, column_widths[x] + invisible_count(cell))
        end
        puts # Move to the next line after each row
      end
    end

    def pretty_json(raw_json)
      json = ToolsJsonParser.parse(raw_json)
      puts ToolsJsonParser.pretty(json)
      json
    end

    def duration(seconds, sig_figs=5)
      seconds = seconds.to_i.abs
      return "<1s" if seconds <= 1

      time_lengths = {
        s: 1,
        m: 60,
        h: 60 * 60,
        d: 24 * 60 * 60,
        w: 7 * 24 * 60 * 60,
      }

      time_lengths.reverse_each.with_object([]) do |(time, length), durations|
        next if length > seconds
        next if durations.length >= sig_figs

        count = (seconds / length).round
        seconds -= count * length

        durations << "#{count}#{time}"
      end.join(" ")
    end

    def hashes_to_csv(hashes)
      keys = hashes.each_with_object(Set.new) { |row, set| set.merge(row.keys) }
      [keys.to_a] + hashes.map { |row| keys.map { |k| row[k] } }
    end

    # Default just aligns each row with ljust
    # This will PRINT the table as well as return the string!
    def table(rows_array, **opts)
      # TODO: opts[:csv] <bool> - returns csv string (newlines and commas)
      # TODO: opts[:ascii] <bool> - shows borders
      # TODO: opts[:only_return] <bool> - returns string, does NOT print
      # TODO: opts[:only_print] <bool> - prints table, returns nil
      # TODO: Should be able to pass options to align each column differently
      # TODO: If rows_array is an array of hashes, use the keys as headers
      ToTable.show(rows_array)
    end

    def progress_bar(count, enumerator, &block)
      require "/Users/rocco/code/games/progress_bar.rb"
      ProgressBar.track(count, enumerator, &block)
    end
  end
end
