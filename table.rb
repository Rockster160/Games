require "/Users/rocco/code/games/to_table.rb"

table_arr = ARGV[0].split("\n").map { |r| r.includes?("\t") ? r.split("\t") : r.split(/\s*,\s*/) }
ToTable.show(table_arr, align: :left, padding: 3)
