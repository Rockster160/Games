class ToTable
  def self.show(rows, opts={})
    new(opts).render(rows)
  end

  def initialize(opts={})
    @opts = {}
    @opts[:align] = opts.delete(:align) || :left
    @opts[:padding] = opts.delete(:padding) || 1
    @output = opts.key?(:output) ? opts.delete(:output) : true
    # alignment
    # borders
    # forced sized?
    # header behavior? (alignment, hr below, etc...)
  end

  def uncolor(str) = str.to_s.gsub(/\e\[.*?m/, "")
  def invisible_count(str) = str.to_s.scan(/\e\[[\d;]+m/).join.length

  def render(rows)
    @sizes = []
    rows.each { |row| row.each_with_index { |cell, idx|
      @sizes[idx] = [@sizes[idx], uncolor(cell).length+@opts[:padding]].compact.sort.reverse.first
    } }
    rows.map.with_index { |row, ridx| row.map.with_index { |cell, idx|
      spacer = @sizes[idx] - uncolor(cell).length
      case @opts[:align]
      when :right
        ((" "*spacer) + cell.to_s).tap { |s| @output && print(s) }
      when :center
        half = spacer/2.0
        ((" "*half.floor) + cell.to_s.center(@sizes[idx]) + (" "*half.ceil)).tap { |s| @output && print(s) }
      else # :left
        (cell.to_s + (" "*spacer)).tap { |s| @output && print(s) }
      end

      cell
    }.join("\t").tap { @output && puts } }.join("\n")
  end
end
# ToTable.show(array)

# ToTable.new.render(array)
# File.open("export.csv", "w+") { |f| f.puts ToTable.show(array) }
