require "/Users/rocco/code/games/easy_yml_parser.rb"
require "pry-rails"

# TODO:
# Nested blocks (calling [animal] in a list, for example) [animal.feral] should also work
# Special items
# * Range of numbers `(1-9)`: 1-9 `(450)`: 1-450
# * Inline list `this|or this|maybe this`
# Maybe? Add dot functions of each nested value (Multi-word would need to use square brackets)

class RbChance
  attr_accessor :json, :key, :parent, :ancestor

  def self.from_file(filename)
    from_str(File.read(filename))
  end

  def self.from_str(str)
    new(EasyYmlParser.parse(str))
  end

  def initialize(json, key=nil, parent=nil)
    @json = json
    @parent = parent
    @key = key
    @ancestor = parent&.ancestor || parent || self
  end

  def [](*keys)
    return self if keys.first.nil? || keys.none?
    dug = @json
    keys.each { |key|
      if dug[key]
        dug = RbChance.new(dug[key], key, self)
      elsif key.match?(/^\[.*?\]$/)
        dug = RbChance.new(@ancestor[key[1..-2]], key, self)
      elsif key.include?(".")
        dug = RbChance.new(self[*key.split(".")], key, self)
      else
        raise "No key found [#{key}] under #{@key ? "[#{@key}]" : "list"}"
      end
    }
    dug
  end

  def branches
    @json.keys
  end

  def possibilities(hash=@json)
    hash.each_with_object([]) { |(k, v), obj|
      case v
      when Hash then possibilities(v).each { |b| obj << b }
      when Array then v.each { |b| obj << b }
      else
        obj << v
      end
    }
  end

  def gen
    return @json if @json.is_a?(String)
    return @key || @parent&.gen if @json.is_a?(Hash) && @json.keys.none?
    return self[@json.keys.sample].gen if @json.is_a?(Hash)
    return @json.sample if @json.is_a?(Array)

    @json.gen
  end

  def to_s
    gen
  end
end

# p RbChance.from_file(ARGV[0])[*ARGV[1..]] if ARGV[0]
# p RbChance.from_file(ARGV[0])[*ARGV[1..]]
# p RbChance.from_file(ARGV[0])[*ARGV[1..]].possibilities
puts RbChance.from_file(ARGV[0])[*ARGV[1..]]
# topics_file = "/Users/rocco/code/games/rbchance/topics.yml"
# rb_chance_demo = ""

#   static rand() {
#     let args = Array.from(arguments)
#
#     if (args.length == 0) {
#       return Math.random()
#     } else if (args.length == 1) {
#       let arg = args[0]
#       if (this.isInt(arg)) { // Check if an int
#         return Math.floor(this.rand() * Number(arg)) // 0-int (exclude int)
#       } else if (/\d+\-\d+/.test(arg)) { // Is a num range like 10-15
#         let [num1, num2] = arg.split("-")
#         return this.rand(num1, num2)
#       } else if (typeof arg == "string" && arg.includes("|")) {
#         return this.rand(...arg.split("|"))
#       } else if (Array.isArray(arg)) {
#         return this.rand(...arg)
#       } else {
#         throw("Not a valid argument: " + (typeof arg) + " (" + arg + ")")
#       }
#     } else if (args.length == 2 && this.isInt(args[0]) && this.isInt(args[1])) {
#       // Num range like 10,15 inclusive
#       let [min, max] = args.map(function(n) { return Number(n) })
#       return Math.floor(this.rand() * (1 + max - min) + min)
#     } else {
#       return args[this.rand(args.length)]
#     }
#   }
#
