class Differ
  class << self
    def compare(str1, str2, only_changes: false)
      diff_lines = diff(str1, str2)
      total_count = diff_lines.count
      num = total_count.to_s.length
      i1, i2 = 0, 0
      diff_lines.each do |line|
        if line.is_a?(String)
          i2 += 1
          i1 = i2
          puts "\e[38;2;180;180;180m #{i2.to_s.rjust(num)} | #{line}\e[0m" unless only_changes
        else
          line[:add].each do |add_line|
            puts "\e[38;2;50;150;50m #{(i2+=1).to_s.rjust(num)} |+#{add_line}\e[0m"
          end
          line[:remove].each do |rem_line|
            puts "\e[38;2;150;50;50m #{(i1+=1).to_s.rjust(num)} |-#{rem_line}\e[0m"
          end
        end
      end
    end

    def diff(str1, str2)
      # str1, str2 = @starting_text, text
      lines1 = str1.to_s.split("\n")
      lines2 = str2.to_s.split("\n")
      diff_result = []
      idx1 = idx2 = 0
      current_remove = [] # Batch of removed lines
      current_add = []    # Batch of added lines

      loop do
        break if idx1 >= lines1.size && idx2 >= lines2.size

        l1 = lines1[idx1]
        l2 = lines2[idx2]

        # When lines match, flush any pending diff batch
        if idx1 < lines1.size && idx2 < lines2.size && l1 == l2
          if current_remove.any? || current_add.any?
            diff_result << { remove: current_remove, add: current_add }
            current_remove = []
            current_add = []
          end
          idx1 += 1
          idx2 += 1
          diff_result << l1
          next
        end

        # If one string has ended, treat the rest as diff
        if idx1 >= lines1.size
          current_add << l2
          idx2 += 1
          next
        end
        if idx2 >= lines2.size
          current_remove << l1
          idx1 += 1
          next
        end

        # Both lines exist but differ; attempt to realign using lookahead.
        pos_in_lines2 =
          idx1 + 1 < lines1.size ? lines2[idx2..-1].index(lines1[idx1 + 1]) : nil
        pos_in_lines1 =
          idx2 + 1 < lines2.size ? lines1[idx1..-1].index(lines2[idx2 + 1]) : nil

        # if pos_in_lines2 && (!pos_in_lines1 || pos_in_lines2 <= pos_in_lines1)
        if pos_in_lines2 && (!pos_in_lines1 || pos_in_lines2 <= pos_in_lines1)
        # if pos_in_lines2
          # Next line from lines1 found in lines2:
          # Batch current removal and add any intervening added lines.
          # [ROCCO] - The below breaks single line diffs!
          # if !pos_in_lines1 || pos_in_lines2 < pos_in_lines1
            current_remove << l1
            current_add.concat(lines2[idx2...(idx2 + pos_in_lines2)])
          # elsif pos_in_lines2 < pos_in_lines1
          #   current_add.concat(lines2[idx2...(idx2 + pos_in_lines2-1)])
          # else
          #   current_add.concat(lines2[idx2...(idx2 + pos_in_lines2-1)])
          # end

          idx1 += 1
          idx2 += pos_in_lines2
        elsif pos_in_lines1
          # Next line from lines2 found in lines1:
          # Batch removals until that match and record current addition.
          # current_remove.concat(lines1[idx1...(idx1 + pos_in_lines1-1)])
          current_remove.concat(lines1[idx1...(idx1 + pos_in_lines1)])
          current_add << l2
          idx1 += pos_in_lines1
          idx2 += 1
        else
          # No lookahead match; treat as a substitution.
          current_remove << l1
          current_add << l2
          idx1 += 1
          idx2 += 1
        end
      end

      diff_result << { remove: current_remove, add: current_add } if current_remove.any? || current_add.any?
      diff_result
    end
  end
end
