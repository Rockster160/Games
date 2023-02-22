require 'csv'

@people = {}

class String
  def squish
    gsub(/[[:space:]]+/, " ").strip
  end
end

Person = Struct.new(:name, :bday, :number, :col, :list) do
  def id
    "#{name}-#{bday}"
  end
end

List = Struct.new(:name, :dir, :fname_idx, :lname_idx, :bday_idx, :custom_proc, :people) do
  def compile
    return unless people.nil?
    self.people = []

    CSV.foreach(dir).with_index do |row, idx|
      next if idx == 0

      fname, num = row[fname_idx].split("+")
      num = 1 if num.to_i < 1
      lname = row[lname_idx]
      bday = row[bday_idx].split("/").map { |char| char.gsub(/^0/, "") }.join("/")
      full_name = [fname, lname].join(" ").squish.upcase

      person = Person.new(full_name, bday.squish, num.to_i, idx, name)
      custom_proc.call(row, person) unless custom_proc.nil?
      self.people << person
    end

    self
  end
end

# Find within a year of turning 65

lista = List.new(
  :lista,
  "/Users/rocconicholls/Documents/BrendanBOB125/Individual-Table\ 1.csv",
  0,
  2,
  3
).compile

listb = List.new(
  :listb,
  "/Users/rocconicholls/Downloads/applications-933132-20210127T000405.csv",
  0,
  1,
  5,
  Proc.new { |row, person|
    person.number = row[27].to_i
  }
).compile

def count
  @people.values.sum do |persons|
    persons.first.number
  end
end

def missing(list_name)
  @people.values.select { |person|
    person.select { |lp| lp.list == list_name }.none?
  }.map { |persons|
    person = persons.first
    "  [#{person.col}] = #{person.id}"
  }.join("\n")
end

def merge(*lists)
  @people ||= {}

  lists.each do |list|
    list.people.each do |person|
      @people[person.id] ||= []
      @people[person.id] << person
    end
  end

  @people
end

merge(lista, listb)
puts "Count: #{count}"
puts "Missing from list 1: \n#{missing(:lista)}"
puts "Missing from list 2: \n#{missing(:listb)}"
