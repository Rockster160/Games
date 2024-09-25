#!/usr/bin/env ruby

# Args:
#   CamelCaseModel
#   column_name
#   type (boolean, string, enum, etc...)
#   default (false, "hello", 4, etc...)

def to_text(str)
  to_snake_case(str).split("_").join(" ")
end

def to_title(str)
  to_snake_case(str).split("_").map(&:capitalize).join(" ")
end

def to_pascal_case(str)
  to_snake_case(str).split("_").map(&:capitalize).join
end

def to_snake_case(str)
  str.to_s.gsub(/^::\b/, "").gsub(/::/, "/")
    .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
    .gsub(/([a-z\d])([A-Z])/, '\1_\2')
    .tr("-", "_")
    .gsub(/_{2,}/, "_")
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

def table_and_row
  ":#{table}, :#{@column}"
end

def table
  @table ||= "#{pluralize(to_snake_case(@model))}"
end

def default_val
  @default_val ||= @type == "enum" ? "::#{@model}.#{pluralize(@column)}[:#{@default}]" : @default
end

def generate_add(filename)
  replace_change(filename, <<-DEF)
    def change
      add_column #{table_and_row}, :#{@type == "enum" ? :integer : type}
    end
  DEF
end

def generate_set_default(filename)
  replace_change(filename, <<-DEF)
    def change
      change_column_default #{table_and_row}, from: nil, to: #{default_val}
    end
  DEF
end

def generate_backfill(filename)
  replace_change(filename, <<-DEF)
    def change
      # |::#{@model}.count| #{pluralize(to_snake_case(@model))}, ran in _.____s
      ::#{@model}.update_all(#{@column}: #{default_val})
    end
  DEF
end

def generate_check_constraint(filename)
  replace_change(filename, <<-DEF)
    def change
      add_check_constraint(
        :#{table},
        "#{@column} IS NOT NULL",
        name: "#{table}_#{@column}_null",
        validate: false,
      )
    end
  DEF
end

def generate_non_null(filename)
  replace_change(filename, <<-DEF)
    def up
      # ===== This assumes the backfill has already been run and there are no invalid records! =====
      validate_check_constraint :#{table}, name: "#{table}_#{@column}_null"
      change_column_null :#{table}, :#{@column}, false
      remove_check_constraint(
        :#{table},
        "#{@column} IS NOT NULL",
        name: "#{table}_#{@column}_null",
      )
    end

    def down
      add_check_constraint(
        :#{table},
        "#{@column} IS NOT NULL",
        name: "#{table}_#{@column}_null",
        validate: false,
      )
      change_column_null :#{table}, :#{@column}, true
    end
  DEF
end

def replace_change(filename, text)
  contents = File.read(filename)
  formatted_text = text.strip.split("\n  ").join("\n")
  contents = contents.gsub(/def change[.\n]*?\n  end/m, formatted_text)
  File.write(filename, contents)
end

def add_magic_comment(filename)
  contents = File.read(filename)
  magic_comment = "# frozen_string_literal: true"
  if !contents.include?(magic_comment)
    contents = "#{magic_comment}\n\n#{contents}"
    File.write(filename, contents)
  end
end

def migration(snake)
  name = to_pascal_case(snake)
  print "\e[90m > Generating #{name}..."
  res = `rails g migration #{@title}#{name} 2>/dev/null`
  filename = res[/db\/migrate\/.*?\.rb/]

  if filename.to_s.length < 1
    error_text = "Error generating filename!\n\e[90m```\n#{res}\n\e[90m```\e[0m"
    puts "\n\e[31m#{error_text}"
    raise RuntimeError, error_text
  else
    add_magic_comment(filename)
    puts "\r\e[36m#{filename}\e[0m"
    filename
  end
end

def generate(section)
  # `rm db/migrate/*_#{to_snake_case(@title)}_#{section}.rb`
  filename = migration(section)
  send("generate_#{section}", filename)
  puts "\e[38;2;160;160;160m#{File.read(filename)}\e[0m"
end

def generate_migrations(model, column, type, default)
  @model, @column, @type, @default = model, column, type, default
  @title = to_pascal_case(@model + @column)
  @title = to_pascal_case("#{@model}_#{@column}")

  generate(:add)
  generate(:set_default)
  generate(:backfill)
  generate(:check_constraint)
  generate(:non_null)
end

if __FILE__ == $0
  if ARGV.length != 4
    puts "Usage: `nonNullMigration CamelCaseModel column_name <boolean|integer|enum|string> <default>`"
    exit 1
  end

  model, column, type, default = *ARGV
  if !default.nil?
    default = false if default == "false"
    default = true if default == "true"
    default = default.to_i if default.to_s == default.to_i.to_s
  end

  generate_migrations(model, column, type, default)
end
