class DungeonWalker
  attr_reader :dungeon

  def initialize(dungeon_size:, walk_length:, max_rooms:, room_size_range:, start_position: nil)
    @dungeon_size = dungeon_size
    @walk_length = walk_length
    @max_rooms = max_rooms
    @room_size_range = room_size_range
    @dungeon = Array.new(dungeon_size) { Array.new(dungeon_size, "# ") }
    @start_position = start_position || [dungeon_size / 2, dungeon_size / 2]
    @rooms = []
    generate_dungeon
  end

  def generate_dungeon
    current_position = @start_position.dup
    @max_rooms.times do
      # Random room size
      width = rand(@room_size_range)
      height = rand(@room_size_range)

      # Carve out a room
      add_room(current_position, width, height)

      # Walker moves for a random number of steps
      @walk_length.times do
        next_position = random_walk(current_position)
        break unless inside_bounds?(next_position)

        current_position = next_position
        @dungeon[current_position[1]][current_position[0]] = ". " # Carve out path
      end
    end
  end

  private

  def add_room(position, width, height)
    x, y = position
    x_range = [(x - width / 2), 1].max...[x + width / 2, @dungeon_size - 1].min
    y_range = [(y - height / 2), 1].max...[y + height / 2, @dungeon_size - 1].min

    y_range.each do |i|
      x_range.each do |j|
        @dungeon[i][j] = ". " # Carve out the room
      end
    end
    @rooms << position
  end

  def random_walk(position)
    x, y = position
    direction = rand(4)

    case direction
    when 0 then [x, y - 1] # Move up
    when 1 then [x + 1, y] # Move right
    when 2 then [x, y + 1] # Move down
    when 3 then [x - 1, y] # Move left
    end
  end

  def inside_bounds?(position)
    x, y = position
    x.between?(1, @dungeon_size - 2) && y.between?(1, @dungeon_size - 2)
  end
end

# Parameters
dungeon_size = 40
walk_length = 30
max_rooms = 10
room_size_range = 3..7

# Generate dungeon
walker = DungeonWalker.new(
  dungeon_size: dungeon_size,
  walk_length: walk_length,
  max_rooms: max_rooms,
  room_size_range: room_size_range
)

# Display dungeon in terminal
walker.dungeon.each { |row| puts row.join }
