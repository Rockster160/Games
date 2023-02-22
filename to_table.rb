class ToTable
  def self.show(rows)
    new.render(rows)
  end

  def initialize(opts={})
    # alignment
    # borders
    # forced sized?
    # header behavior? (alignment, hr below, etc...)
  end

  def render(rows)
    @sizes = []
    rows.each { |row| row.each_with_index { |cell, idx|
      @sizes[idx] = [@sizes[idx], cell.to_s.length+1].compact.sort.reverse.first
    } }
    rows.map.with_index { |row, ridx| row.map.with_index { |cell, idx|
      print cell.to_s.rjust(@sizes[idx])
      cell
    }.join("\t").tap { puts } }.join("\n")
  end
end
ToTable.show(array)

# ToTable.new.render(array)
# File.open("export.csv", "w+") { |f| f.puts ToTable.show(array) }
