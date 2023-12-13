require "/Users/rocco/code/games/to_table.rb"

table_arr = ARGV[0].split("\n").map { |r| r.includes?("\t") ? r.split("\t") : r.split(/\s*,\s*/) }
ToTable.show(table_arr, align: :left, padding: 3)

# def table(array)
#   column_widths = array.map { |layer| layer.map { |cell| cell.to_s.length }.max }
#   array.each do |row|
#     row.each_with_index do |cell, col_index|
#       print cell.to_s.rjust(column_widths[col_index] + 2)  # Add 2 for padding
#     end
#     puts # Move to the next line after each row
#   end
# end
