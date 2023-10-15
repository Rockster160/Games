class ToTable
  def self.show(rows, opts={})
    new(opts).render(rows)
  end

  def initialize(opts={})
    @opts = {}
    @opts[:align] = opts.delete(:align) || :left
    @opts[:padding] = opts.delete(:padding) || 1
    # alignment
    # borders
    # forced sized?
    # header behavior? (alignment, hr below, etc...)
  end

  def render(rows)
    @sizes = []
    rows.each { |row| row.each_with_index { |cell, idx|
      @sizes[idx] = [@sizes[idx], cell.to_s.length+@opts[:padding]].compact.sort.reverse.first
    } }
    rows.map.with_index { |row, ridx| row.map.with_index { |cell, idx|
      case @opts[:align]
      when :right
        print cell.to_s.rjust(@sizes[idx])
      when :center
        print cell.to_s.center(@sizes[idx])
      else # :left
        print cell.to_s.ljust(@sizes[idx])
      end

      cell
    }.join("\t").tap { puts } }.join("\n")
  end
end
# ToTable.show(array)

# ToTable.new.render(array)
# File.open("export.csv", "w+") { |f| f.puts ToTable.show(array) }
