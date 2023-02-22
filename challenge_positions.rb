require "pry-rails"
# REQUIRED OUTPUT
=begin
Designer
-UI Designer
-UX Designer
Engineer
-Mechanical Engineer
-Software Engineer
--Front-End Engineer
--Machine Learning Engineer
=end

@positions = [{ "id"=>1, "name"=>"Engineer", "parent_id"=>nil },
             { "id"=>2, "name"=>"Front-End Engineer", "parent_id"=>3 },
             { "id"=>3, "name"=>"Software Engineer", "parent_id"=>1 },
             { "id"=>4, "name"=>"Mechanical Engineer", "parent_id"=>1 },
             { "id"=>5, "name"=>"UX Designer", "parent_id"=>6 },
             { "id"=>6, "name"=>"Designer", "parent_id"=>nil },
             { "id"=>7, "name"=>"Machine Learning Engineer", "parent_id"=>3 },
             { "id"=>8, "name"=>"UI Designer", "parent_id"=>6 }]

# ==================================================================================================

@positions.each do |pos|
  next if pos["parent_id"].nil?

  @positions[pos["parent_id"]-1]["children"] ||= []
  @positions[pos["parent_id"]-1]["children"].unshift(pos)
end

def sort(positions)
  return if positions.nil?

  positions.sort_by { |pos| pos["name"] }.sort_by { |pos| descendants(pos).count }
end

def descendants(pos)
  pos["children"]&.map { |child| [child] + descendants(child) }&.flatten || []
end

def show(pos, age=0)
  puts "-"*age + pos["name"]
  sort(pos["children"])&.each { |child| show(child, age+1) }
end

sort(@positions).each do |pos|
  next unless pos["parent_id"].nil?
  show(pos)
end
