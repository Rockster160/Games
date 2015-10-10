class LightSource < BaseObject
  include Item

  attr_accessor :equipment_slot, :is_equipped, :bonus_strength, :bonus_defense, :bonus_accuracy, :bonus_speed, :bonus_health, :bonus_mana, :bonus_energy, :bonus_self_regen, :bonus_magic_power
  attr_accessor :range, :duration, :is_lighting

  def update_vision
    return false unless coords && range
    self.is_lighting = Visible.new(Dungeon.current, {x: x, y: y}, range).find_visible
  end

  def calculate_times(percentage)
    this_range, val = self.range, self.duration
    times = {this_range.to_s => val}
    until this_range == 1
      val *= percentage
      this_range -= 1
      times[this_range.to_s] = val.round
    end
    times
  end

  def pickup
    $screen_shot_objects.delete({instance: self, x: self.x, y: self.y, depth: self.depth})
    self.is_lighting = []
    self.x = nil
    self.y = nil
    self.depth = nil
    self
  end

  def self.find_visible; Item.light_sources.map { |light| light.is_lighting }.flatten; end
  def self.tick; Item.light_sources.select { |light| light && !([light.x, light.y, light.depth] == [nil]*3) }.each(&:tick); end

  def tick
    @times ||= calculate_times(0.3)
    self.duration -= 1
    @times.each do |time, tick|
      next if time.to_i > range
      next if time.to_i < range
      if self.duration <= tick && range > 1
        self.range -= 1
        self.update_vision
      end
    end
    self.destroy if duration <= 0
  end

  def self.generate
    new({
      name: 'Torch',
      icon: 'i',
      weight: 0.1,
      auto_pickup: false,
      equipment_slot: :off_hand,
      color: :light_yellow,
      range: 4,
      stack_size: 99,
      duration: 2000,
      description: "Torches Light the way. Equip a torch to increase the vision around the Player. \nPlace torches on the ground to light the area.\n Torches last a certain duration, determined by movement ticks from the Player. The light produced from a torch will diminish as the duration decreases. Upon reaching 0, a torch will be destroyed."
    })
  end
end
