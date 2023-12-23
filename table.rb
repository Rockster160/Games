require "/Users/rocco/code/games/to_table.rb"

table_arr = ARGV[0].split("\n").map { |r| r.includes?("\t") ? r.split("\t") : r.split(/\s*,\s*/) }
ToTable.show(table_arr, align: :left, padding: 3)

# def uncolor(str) = str.to_s.gsub(/\e\[.*?m/, "")
# def invisible_count(str) = str.to_s.scan(/\e\[[\d;]+m/).join.length
# def table(array)
#   column_widths = array.transpose.map { |col| col.map { |cell| uncolor(cell).length }.max + 1 }
#   array.each do |row|
#     row.each_with_index do |cell, x|
#       clean = uncolor(cell)
#       just = x == 0 ? :ljust : :rjust
#       cell = cell.to_s&.tap { |s| s.gsub!(clean, clean[1..]) if clean[0] == ":" }
#       print " " unless x == 0
#       print clean.send(just, column_widths[x] + invisible_count(cell))
#     end
#     puts # Move to the next line after each row
#   end; nil
# end
