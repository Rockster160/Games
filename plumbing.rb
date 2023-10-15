require "pry-rails"

@bad_starts = []
@current_attempt = []

class Piece
  MAP_WIDTH = 5
  MAP_HEIGHT = 5
  COORD_IDXS = { u: 0, r: 1, d: 2, l: 3 }
  SYM_LIST = {
    ur: "┗",
    rd: "┏",
    dl: "┓",
    ul: "┛",
    ud: "║",
    rl: "═",
    jn: "╋",
  }
  COORD_LIST = {
    #   [u, r, d, l]
    ur: [1, 1, 0, 0],
    rd: [0, 1, 1, 0],
    dl: [0, 0, 1, 1],
    ul: [1, 0, 0, 1],
    ud: [1, 0, 1, 0],
    rl: [0, 1, 0, 1],
    jn: [1, 1, 1, 1],
  }
  COORD_KEYS = COORD_LIST.keys
  UPS = COORD_KEYS.select { |k| k.to_s.include?("u") }
  DOWNS = COORD_KEYS.select { |k| k.to_s.include?("d") }
  LEFTS = COORD_KEYS.select { |k| k.to_s.include?("l") }
  RIGHTS = COORD_KEYS.select { |k| k.to_s.include?("r") }
  FOLLOWS = COORD_KEYS.each_with_object({}) do |key, obj|
    next obj[key] = COORD_KEYS if key == :jn
    obj[key] = [:jn]
    obj[key] << @downs if key.to_s.include?("d")
    obj[key] << @ups if key.to_s.include?("u")
    obj[key] << @lefts if key.to_s.include?("l")
    obj[key] << @rights if key.to_s.include?("r")
  end

  def initialize(char)
    @char = char
  end

  def dir?(dir) = COORD_LIST[COORD_IDXS[dir]] == 1
  def u?; dir?(:u); end
  def r?; dir?(:r); end
  def d?; dir?(:d); end
  def l?; dir?(:l); end

  def to_s = char
  def sym = SYM_LIST.key(@char)
  def coord = COORD_LIST[sym]
  #
  # def allowed?(x, y)
  #   return false if l? && x == 0
  #   return false if r? && x == MAP_WIDTH-1
  #   return false if u? && y == 0 && x != 0
  #   return false if u? && y == MAP_HEIGHT-1
  #
  #   true
  # end
end

@base = [
  %q(┗┏┓╋┛),
  %q(┏╋║║║),
  %q(┏┗╋═┓),
  %q(║┏┓┛╋),
  %q(╋┛╋═┛),
].map(&:chars)
@height = @base.length
@width = @base.first.length

@pieces = @base.flatten.map { |char| Piece.new(char) }

available = []

@base.each_with_index { |row, y|
  row.each_with_index { |char, x|
    piece = Piece.new(char)
    next if piece.sym == :jn # Junctions cannot be moved?
    available << piece
    @base[y][x] = "." # Placeholder
  }
}

binding.pry

def draw(map)
  puts ""
  map.each { |row| puts "     #{row.join("").gsub(".", "\e[100m \e[0m").gsub("╋", "\e[35m╋\e[0m").gsub("x", "\e[41mx\e[0m")}" }
  puts ""
end

def filter(left, match=true, dir)
  left.select { |piece| piece.dir?(dir).then { |v| !(match == :not || !match) } }
end

def add_bad_attempt(new_map)
  # @bad_starts.unshift(new_map)
  # @bad_starts.reject! { |bad|
  #   next if new_map.length > bad.length
  #   !bad.start_with?(new_map)
  # }
  # @bad_starts.uniq!
end

def attempt(map_attempt, current)
  # puts "\e[33m[LOGIT]\e[0m"
  # puts current.map(&:to_s).join("")
  # draw map_attempt
  # puts "\e[33m[LOGIT]\e[0m"
  map_attempt.each_with_index.with_object(map_attempt) { |(row, y), map|
    idx = (y * @width) - 1
    row.each_with_index { |char, x|
      idx += 1
      next unless char == "."
      left = current.dup
      # puts "[#{x}, #{y}]: #{left.map(&:to_s).join(" ")}"
      # draw map_attempt

      left = filter(left, :u) if y == 0 && x == 0 # Must point up in the top left corner
      left = filter(left, :u) if y == 0 && x == @width - 1 # Must point up in the top right corner
      left = filter(left, :not, :u) if y == 0 && !(x == 0 || x == @width - 1) # Top, not left/right
      left = filter(left, :not, :d) if y == @height - 1
      left = filter(left, :not, :l) if x == 0
      left = filter(left, :not, :r) if x == @width - 1

      # binding.pry if left.none?
      # next map_attempt[y][x] = "x" if left.none?
      if left.none?
        add_bad_attempt(current.join("")[0..((@width*y)+x-1)])
        return map_attempt
      end
      preleft = left.dup
      [
        [1, 0],
        [-1, 0],
        [0, 1],
        [0, -1],
      ].each do |rx, ry|
        nx, ny = x + rx, y + ry
        neighbor = map_attempt.dig(ny, nx)
        next if ny < 0 || nx < 0 # No neighbors off the board
        next if ny >= @height || nx >= @width # No neighbors off the board
        next if neighbor.nil? || neighbor.is_a?(String) # Any piece allowed

        left = filter(left, :u) if ry == 1 && neighbor.d? # neighbor on UP
        left = filter(left, :r) if rx == 1 && neighbor.l? # neighbor on RIGHT
        left = filter(left, :d) if ry == -1 && neighbor.u? # neighbor on DOWN
        left = filter(left, :l) if rx == -1 && neighbor.r? # neighbor on LEFT
      end

      # binding.pry if left.none?
      # next map_attempt[y][x] = "x" if left.none?
      if left.none?
        add_bad_attempt(current.join("")[0..((@width*y)+x-1)])
        return map_attempt
      end
      new_idx = current.map(&:to_s).index(left.first.to_s)
      binding.pry if idx.nil?
      # puts "\e[31m#{current.map(&:to_s)[idx]} == #{current.map(&:to_s)[new_idx]}\e[0m"
      piece = current.delete_at(new_idx)
      binding.pry if piece.nil?
      map_attempt[y][x] = piece
    }
  }
end

def measure_block(&block)
  t = Time.now.to_f
  yield
  Time.now.to_f - t
end

def bruteforce(available)
  available.permutation.find.with_index { |perm, idx|
    # str = perm.map(&:to_s).join("")
    # next if @bad_starts.any? { |bad| str.start_with?(bad) }
    # binding.pry if idx > 2
    # @bad_starts.unshift()
    # puts perm.join("")
    # sleep 2
    # nil
    # break if idx > 10
    puts "====== #{idx} ======"
    success = false
    t = measure_block {
      s = attempt(@base.map {|b|b.map(&:dup)}, perm.reverse) # reverse sso we have more variations first
      success = true if !s.to_s.match?(/[\.]/)
      draw s
    }
    puts t
    success
  }
end

# Not currently working. Need to come up with a more efficient way
# bruteforce(available)
