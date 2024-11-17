#!/usr/bin/env ruby

# Args:
#   replace|copy|inline
#   from_value (snake case)
#   to_value (snake case)
#   path (or content to replace inline)

require "fileutils"
require "find"

def to_text(str)
  str.split("_").join(" ")
end

def to_title(str)
  str.split("_").map(&:capitalize).join(" ")
end

def to_pascal_case(str)
  str.split("_").map(&:capitalize).join
end

def to_snake_case(str)
  str.gsub(/::/, "/")
    .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
    .gsub(/([a-z\d])([A-Z])/, '\1_\2')
    .tr("-", "_")
    .downcase
end

def pluralize(str)
  if str.end_with?("y")
    str[0..-2] + "ies"
  elsif str.end_with?("s")
    str + "es"
  else
    str + "s"
  end
end

def refactor_text(text, from_snake, to_snake)
  text
    .gsub(pluralize(from_snake), pluralize(to_snake))
    .gsub(from_snake, to_snake)
    .gsub(pluralize(to_pascal_case(from_snake)), pluralize(to_pascal_case(to_snake)))
    .gsub(to_pascal_case(from_snake), to_pascal_case(to_snake))
    .gsub(to_title(from_snake), to_title(to_snake))
    .gsub(Regexp.new(to_text(from_snake), Regexp::IGNORECASE), to_text(to_snake))
rescue ArgumentError
  text
end

def refactor_file(filepath, from_snake, to_snake, style=:replace)
  content = File.read(filepath)
  refactored = refactor_text(content, from_snake, to_snake)
  new_filepath = refactor_text(filepath, from_snake, to_snake)
  return if content == refactored && filepath == new_filepath

  if style == :replace # replace-mode
    # Will change the files in-place and/or rename/move the file accordingly.
    puts "\e[33m===== #{filepath} → #{new_filepath}\e[0m"
    File.write(filepath, refactored) # Write the new data to the old file
    return unless filepath != new_filepath # This technically isn't needed, but helps logically

    FileUtils.mkdir_p(File.dirname(new_filepath)) # Create the new directory for the new file
    File.rename(filepath, new_filepath) # Move/rename the file/path to the new filepath
    # TODO: Clean up / delete the empty directories!
  elsif filepath != new_filepath # copy-mode, different files
    # Simply create a new file with the new content.
    # New content might match the old content if there were no changes to make inside.

    if File.file?(new_filepath)
      puts "\e[31m===== File already exists: #{new_filepath}\e[0m"
    else
      puts "\e[32m===== #{new_filepath}\e[0m"
      FileUtils.mkdir_p(File.dirname(new_filepath)) # Create the new directory for the new file
      File.write(new_filepath, refactored)
    end
  else # copy-mode, but the files are the same (generic file index)
    # Spit out the lines that match so that I can modify them manually
    content.split("\n").each_with_index do |line, idx|
      newline = refactor_text(line, from_snake, to_snake)
      next unless line != newline

      puts "\e[0m===== #{filepath}:#{idx+1}\n\e[90m > #{line}\n\e[36m > #{newline}"
    end
  end
end

# def file_by_pattern(patterns)
  # patterns.flat_map { |pat|
  #   Dir.glob([
  #     "**/#{pat}/**/*",
  #     "**/#{pat}",
  #   ]).select { |path| File.file?(path) }
  # }.uniq
# end

def file_extensions
  @file_extensions ||= [
    # Bad because we want to be able to excape special chars
    # File::FNM_NOESCAPE, # Disables the backslash escape character. By default, a backslash can be used to escape special characters in the pattern, but setting this flag will treat backslashes as regular characters.
    # Bad because we want "*" to match directories and/or files
    # File::FNM_PATHNAME, # Changes the matching behavior so that the / character (directory separator) must be matched explicitly by a / in the pattern. This prevents * and ? from matching /.
    # Bad because these are typically special files
    # File::FNM_DOTMATCH, # Allows the * and ? wildcards to match the initial . in filenames. By default, these wildcards do not match . at the beginning of filenames.
    # Bad because if files have capitals you should have to match them explicitly
    # File::FNM_CASEFOLD, # Makes the pattern matching case-insensitive. This means that `a` will match both `a` and `A`.
    # Allows us to use regex
    File::FNM_EXTGLOB, # Enables extended glob patterns like ?(pattern-list), *(pattern-list), +(pattern-list), @(pattern-list), and !(pattern-list). These are similar to regex alternation and repetition.
  ].reduce(0) { |accumulator, extension| accumulator | extension }
end

def file_match?(file, str_pattern)
  patterns = str_pattern.split(",").map(&:strip)
  return false if patterns.any? { |pattern|
    next unless pattern.start_with?("!")
    File.fnmatch(pattern[1..], file, file_extensions)
  }
  return true if str_pattern == "."
  patterns.any? do |pattern|
    next if pattern.start_with?("!")
    File.fnmatch(pattern, file, file_extensions)
  end
end

def all_not_gitignored
  tracked_files = `git ls-files`.split("\n")
  untracked_files = `git ls-files --others --exclude-standard`.split("\n")
  (tracked_files + untracked_files).uniq.select { |file| File.exist?(file) }
end

def find_files(pattern)
  files = File.exist?(".gitignore") ? all_not_gitignored : Dir.glob("./**/*")
  files.select { |file| file_match?(file, pattern) }
end

def refactor(path, from_snake, to_snake, style=:replace)
  from_pascal = to_pascal_case(from_snake)
  to_pascal = to_pascal_case(to_snake)

  if style == :inline
    inline_text = refactor_text(path, from_snake, to_snake)
    if __FILE__ == $0
      puts "\e[36m#{inline_text}\e[0m"
      return
    else
      return inline_text
    end
  end

  find_files(path).each do |filepath|
    refactor_file(filepath, from_snake, to_snake, style)
  end
end

if __FILE__ == $0
  style = ARGV[0].to_s.downcase.to_sym
  if ARGV.length != 4 && ARGV.length != 3
    puts "Usage: `refactor replace|copy|inline <from_value> <to_value> <path|content>`"
    exit 1
  elsif ![:replace, :copy, :inline].include?(style)
    puts "Usage: `refactor replace|copy|inline <from_value> <to_value> <path|content>`"
    puts "Must specify either `replace`, `copy`, or `inline` as first argument."
    puts " • `replace` will change files in-place, including renaming and moving the file"
    puts " • `copy` will create a renamed copy of the file. If a rename isn't possible, will show which lines match for manually updating."
    puts " • `inline` will replace all instances only in the given content from the last argument rather than a path."
    exit 1
  end

  from_value = ARGV[1]
  to_value = ARGV[2]
  path = ARGV[3] || "."

  refactor(path, to_snake_case(from_value), to_snake_case(to_value), style)
end
