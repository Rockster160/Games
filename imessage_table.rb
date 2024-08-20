module IMessageTable
  module_function

  def pad_left(text, length)
    length = length*2 # To compensate for characters being 2 wide
    text = " 11" if text == "11"
    calculate_padding(text, length) + text
  end

  def pad_right(text, length)
    length = length*2 # To compensate for characters being 2 wide
    length -= 1 if text == "Brendan:"
    text + calculate_padding(text, length)
  end

  def char_width(char)
    case char
    when "I", "i", "l", ".", " ", ":" then 1
    when "r", "1" then 1.5
    when "W", "M" then 3
    else 2
    end
  end

  def text_width(text)
    text.chars.sum { |char| char_width(char) }
  end

  def calculate_padding(text, col_width)
    width = text_width(text)
    spaces_needed = ((col_width - width) / char_width(" ").to_f).ceil
    " " * [spaces_needed, 0].max
  end

  def ascii_table(data)
    col_widths = data.first.map.with_index { |_, idx| data.map { |c| text_width(c[idx]) }.max }
    rows = data.map do |row|
      row.each_with_index.map do |item, index|
        item + calculate_padding(item, col_widths[index])
      end.join(" | ")
    end
    rows.join("\n")
  end
end

# include IMessageTable
# puts "----- August -----"
# puts pad_right("Saya:", 8) + "|" + pad_left("61", 6)
# puts pad_right("Rocco:", 8) + "|" + pad_left("57", 6)
# puts pad_right("Brendan:", 8) + "|" + pad_left("11", 6)
# puts "---- All Time ----"
# puts pad_right("Saya:", 8) + "|" + pad_left("2,569", 6)
# puts pad_right("Rocco:", 8) + "|" + pad_left("2,568", 6)
# puts pad_right("Brendan:", 8) + "|" + pad_left("655", 6)

### Example usage
# data = [
#   ["Name", "Age", "Occupation"],
#   ["Alice", "30", "Engineer"],
#   ["Bob", "25", "Doctor"],
#   ["Eve", "29", "Chef"]
# ]
#
# puts ascii_table(data, col_widths)
