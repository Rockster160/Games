class Tools
  class << self
    def inspect
      pst("Tools.random_color")
      pst("Tools.count_each(arr)")
      pst("Tools.months_between(date1, date2)")
      pst("Tools.measure_block do ...")
      pst("Tools.measure_x_blocks(count=1000) do ...")
      pst("Tools.hashrocket_parse(\"{sup=>:foo}\")")

      super
    end

    def pst(str)
      puts "\e[33m#{str}\e[0m"
    end

    # Random Color
    def random_color
      "##{('%06x' % (rand * 0xffffff))}".upcase
    end

    # Count same objects in array
    def count_each(arr)
      arr.each_with_object(Hash.new(0)) { |instance, count_hash| count_hash[instance] += 1 }
    end
    # count_each(%w( a a a b c b b a a c ))
    #=> {"a"=>5, "b"=>3, "c"=>2}

    # Count the number of months between 2 dates
    def months_between(date_str1, date_str2)
      date1 = date_str1.to_datetime
      date2 = date_str2.to_datetime
      (date2.year - date1.year) * 12 + date2.month - date1.month - (date2.day >= date1.day ? 0 : 1)
    end
    #=> 5

    def to_dot(hash)
      JSON.parse(hash.to_json, object_class: OpenStruct)
    end

    # Get all of the keys in a hash
    def branches(hash)
      return unless hash.is_a?(Hash)
      return hash.keys if hash.none? { |k, v| v.is_a?(Hash) }

      hash.map do |k, v|
        split_branches = branches(v)

        if split_branches.is_a?(Array)
          split_branches.compact.map { |branch| [k, branch].join(".") }
        else
          k
        end
      end.flatten.compact
    end
    # hash.map do |(k, v)|
    #   if v.is_a?(Hash)
    #     {k => branches(v, parents + [k])}
    #   else
    #     k
    #   end
    # end
    # { a: nil, b: [1, 2, 3], c: { e: :f, g: [:a2, :b2, :c2], h: {a3: 1, b3: 2, c3: 3} }, d: 1 }
    # [:a, :b, "c.e", "c.g", "c.h.a3", "c.h.b3", "c.h.c3", :d]

    # Get the accessible methods of an object/class
    def methods(obj)
      obj.methods - Object.methods
    end

    # Measure how long a block of code takes
    def measure_block(&block)
      t = Time.now.to_f
      yield
      Time.now.to_f - t
    end
    def measure_x_blocks(count=10000, &block)
      count.times.map { measure_block(&block) }.sum / count.to_f
    end

    def hashrocket_parse(raw_hashrocket_json)
      subbed = raw_hashrocket_json.gsub(/\:(\w+)\=\>/) { |found| "\"#{Regexp.last_match[1]}\":"  }
      JSON.parse subbed
    rescue => e
      puts "\e[31mFailed to parse: #{e.class} => #{e.try(:message) || e.try(:body) || e}\e[0m"
    end
  end
end
