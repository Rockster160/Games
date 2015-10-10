module Item
  attr_accessor :name, :weight, :icon, :color, :stack_size, :x, :y, :depth, :auto_pickup, :description, :usable_after_death

  def initialize(defaults)
    defaults.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
    self.usable_after_death ||= false
    self.stack_size ||= 1
    self.auto_pickup = true unless self.auto_pickup == false
    $items << self
  end

  def drop(coords)
    self.x = coords[:x]
    self.y = coords[:y]
    self.depth = coords[:depth]
    $screen_shot_objects << {instance: self, x: self.x, y: self.y, depth: self.depth}
    self
  end

  def destroy
    Player.inventory.delete(self)
    if self.respond_to?(:equipment_slot) && self.equipment_slot
      slot = Player.equipped[self.equipment_slot]
      Player.equipped[self.equipment_slot] = slot == self ? nil : slot
    end
    $items.delete(self)
    $screen_shot_objects.delete({instance: self, x: self.x, y: self.y, depth: self.depth})
    true
  end

  def aoe(radius, script)
    (-radius..radius).map do |rel_y|
      (-radius..radius).map do |rel_x|
        coord = {x: x + rel_x, y: y + rel_y, depth: depth}
        if Dungeon.current[y + rel_y] && Dungeon.current[y + rel_y][rel_x + x]
          eval(script)
        end
      end
    end
  end

  def should_destroy_on_collision(collided_with)
    return false unless destroy_on_collision_with
    cast_object = case
    when collided_with.class == Creature then 'C'
    when collided_with.class == String then collided_with.is_solid? ? 'S' : 's'
    when collided_with.class == Player then 'P'
    else 'o'
    end
    (destroy_on_collision_with.split('') + ['a']).include?(cast_object)
  end

  def use!
    return false if $gameover && !(usable_after_death)
    if Player.energy <= 0 && self.class != Consumable
      Log.add "I don't have the energy to do that."
      $message = "I don't have the energy to do that."
      $gamemode = 'play'
      Game.redraw
      return false
    end

    tick = true
    play = true
    if self.equipment_slot
      tick = Player.equip(self)
    elsif self.class == RangedWeapon || self.class == MagicWeapon
      tick = self.fire!
    elsif self.class == SpellBook
      Settings.read_book(self)
      tick = false
      play = false
    elsif self.class == Spell
      tick = self.cast!(true)
    elsif self.respond_to?(:consume)
      tick = self.consume
    elsif self.class == StaticItem
      tick = self.examine
    else
      Log.add "Couldn't do anything with #{self.name}."
      tick = false
    end
    play ? Game.redraw : Settings.show
    tick
  end

  def collided_damage(power)
    on_hit_damage || Math.less_of((weight * power), power)
  end

  def collide(collided_with)
    if should_destroy_on_collision(collided_with)
      destroy
    end
    if self.respond_to?(:collided_action) && collided_action
      eval(collided_action)
    else
      false
    end
  end

  def show
    @color ||= :white
    "#{icon} ".color(color)
  end

  def coords
    return nil unless x && y
    {x: x, y: y, depth: depth}
  end
  def coords=(new_coords)
    self.x = new_coords[:x]
    self.y = new_coords[:y]
    self.depth = new_coords[:depth]
    coords
  end

  def pickup
    $screen_shot_objects.delete({instance: self, x: self.x, y: self.y, depth: self.depth})
    self.x = nil
    self.y = nil
    self.depth = nil
    self
  end

  def duplicate
    item = self.clone
    item.save!
    item
  end

  def save!
    $items.delete(self)
    $items << self
  end

  def self.generate
     Consumable.generate
     MeleeWeapon.generate
     RangedWeapon.generate
     MagicWeapon.generate
     Equipment.generate
     SpellBook.generate
     Spell.generate
     StaticItem.generate
     LightSource.generate
  end

  def self.damage_to_coord(coord, damage, type)
    unless Dungeon.at(coord).is_solid?
      VisualEffect.new("Fire Blast Effect", "* ".color(:light_red), coord) # refactor this to be more expandable
      Creature.at(coord).each do |creature|
        creature.hit(damage, type)
      end
    end
  end

  def self.all; $items; end
  def self.count; all.count; end
  def self.[](name)
    item = all.select {|i| i.name == name }.first
    if item
      new_item = item.dup
      $items << new_item
      new_item
    else
      nil
    end
  end
  def self.at(coords); all.select { |i| i.coords == coords }; end
  def self.by_name(name); all.select { |i| i.name == name }.first; end
  def self.all_by_name(name); all.select { |i| i.name == name }; end
  def self.on_board; all.select { |i| i.depth == Player.depth }; end
  def self.melee; all.select { |i| i.class == MeleeWeapon }; end
  def self.ranged; all.select { |i| i.class == RangedWeapon }; end
  def self.magic; all.select { |i| i.class == MagicWeapon }; end
  def self.equipment; all.select { |i| i.class == Equipment }; end
  def self.consumable; all.select { |i| i.class == Consumable }; end
  def self.light_sources; all.select { |i| i.class == LightSource }; end

  def self.equippable
    [
      melee +
      ranged +
      magic +
      equipment
    ]
  end

end
