class Player
  class_accessible :x, :y, :seen, :depth, :health, :mana,
  :raw_max_health, :raw_max_mana, :raw_strength, :raw_speed, :gold, :selected,
  :quickbar, :energy, :raw_max_energy, :visible, :raw_defense, :equipped,
  :inventory, :autopickup, :last_hit_id, :raw_self_regen, :bonus_stats,
  :raw_accuracy, :raw_magic_power, :invisibility_ticks, :sleeping,
  :inventory_size, :stunned_for, :live, :invincibility, :vision_radius

  @@x = 0
  @@y = 0
  @@vision_radius = 7

  @@depth = 1
  @@dungeon_level = 1 #0 for town?
  @@seen = []

  @@selected = 0
  @@skip_pick_up = false
  @@quickbar = Array.new(9) {nil}
  @@inventory = []
  @@inventory_size = 10

  @@gold = 0

  @@equipped = {
    head: nil,
    torso: nil,
    back: nil,
    off_hand: nil,
    main_hand: nil,
    ring1: nil,
    ring2: nil,
    ring3: nil,
    ring4: nil,
    waist: nil,
    leggings: nil,
    feet: nil
  }
  @@raw_accuracy = 90
  @@raw_max_health = 7
  @@health = 7
  @@raw_max_mana = 7
  @@mana = 7
  @@raw_max_energy = 100
  @@energy = 100
  @@raw_magic_power = 0
  @@raw_strength = 3
  @@raw_defense = 0
  @@raw_speed = 10
  @@raw_self_regen = 1
  @@live = true
  @@invincibility = 0
  @@invisibility_ticks = 0

  @@visible = true
  @@sleeping = false
  @@autopickup = true
  @@last_hit_id = nil
  @@stunned_for = 0

  def self.name; "me"; end
  def self.coords; {x: Player.x, y: Player.y, depth: Player.depth}; end
  def self.coords=(coord); {x: Player.x = coord[:x] || x, y: Player.y = coord[:y] || y, depth: Player.depth = coord[:depth] || depth}; end

  def self.last_hit_by
    return false unless last_hit_id
    Creature.find(last_hit_id)
  end

  def self.last_hit_name
    return false unless last_hit_by
    last_hit_by.name
  end

  def self.verify_stats
    if self.health <= 0 && @@live == true
      @@live = false
      Log.add("You have been slaughtered by #{last_hit_name}.")
      $gamemode = 'dead'
      $gameover = true
    end
    self.invisibility_ticks = 0 if self.invisibility_ticks < 0
    self.health = max_health if self.health > max_health
    self.mana = 0 if self.mana < 0
    self.mana = max_mana if self.mana > max_mana
    self.energy = 0 if self.energy < 0
    self.energy = max_energy if self.energy > max_energy
  end

  def self.resurrect
    $gamemode = 'play'
    $gameover = false
    Player.live = true
    Player.invincibility += 4
    Player.health = Player.max_health
  end

  def self.revitalize!
    Player.health = Player.max_health
    Player.energy = Player.max_energy
    Player.mana = Player.max_mana
  end

  def self.tick
    return false if $gameover
    self.selected = 0

    loss = (rand(50) == 0 ? 1 : 0)
    self.energy -= loss

    Log.add "I'm starving." if loss > 0 && energy <= 0

    hp_gain = (rand(5) == 0 ? self_regen : 0)
    mana_gain = (rand(3) == 0 ? self_regen : 0)

    self.health += hp_gain if energy >= 20
    self.mana += mana_gain if energy >= 10

    $sleep_condition = 'true' if energy <= 0 # Out of energy. Stop sleeping

    Player.equipped.each { |slot, item| item.tick if item.respond_to?(:tick) }

    Player.invincibility -= 1 if Player.invincibility >= 1
    Player.invisibility_ticks -= 1
    if Player.invisibility_ticks > 0
      if Player.visible
        Log.add "You have become invisible."
        Player.visibility(1)
      end
      Player.visible = false
    else
      Log.add "You have become visible." unless Player.visible
      Player.visible = true
    end

    while inventory_by_stacks.count > inventory_size
      drop_many(inventory_by_stacks.to_a.last[1])
    end
  end

  def self.hit(raw_damage, type_of_damage)
    damage = case type_of_damage
    when 'physical' then raw_damage - self.defense
    when 'magic' then raw_damage - self.magic_resist
    else raw_damage
    end
    self.hurt(damage, type_of_damage)
  end

  def self.hurt(damage=1, type="")
    if Player.invincible? || damage <= 0
      last_hit = Player.last_hit_by
      Log.add "#{last_hit.colored_name} #{last_hit.verbs.sample} you, but you receive no damage."
    else
      self.health -= damage
      $sleep_condition = 'true'
      last_hit = Player.last_hit_by
      type += ' ' if type.length > 0
      Log.add("#{last_hit.colored_name} #{last_hit.verbs.sample} you for #{damage} #{type}damage.") if last_hit
      ratio = (health / raw_max_health.to_f) * 100.00
      Log.add "You are critically low on health." if ratio < 20 && health > 0
    end
  end

  def self.heal(regenerate=1, src="You got healed by an unknown source.")
    return false if regenerate <= 0
    self.health += regenerate
    Log.add(src) if src
  end

  def self.drain(deplete=1, src="You lost mana from an unknown source.")
    self.mana -= deplete
    Log.add(src) if src
    ratio = (mana / raw_max_mana.to_f) * 100.00
    Log.add "You are critically low on mana." if ratio < 20
  end

  def self.restore(gain=1, src="You restored mana from an unknown source.")
    self.mana += gain
    Log.add(src) if src
  end

  def self.weaken(deplete=1, src=nil)
    self.energy -= deplete
    Log.add(src) if src
  end

  def self.energize(gain=1, src=nil)
    self.energy += gain
    Log.add(src) if src
    ratio = (energy / raw_max_energy.to_f) * 100.00
    Log.add "You are critically low on Energy." if ratio < 20
  end

  def self.show
    foreground = :light_blue
    background = :black
    foreground, background = :blue, :white unless Player.visible
    foreground = :yellow if Player.invincible?
    "@".color(foreground, background) + " "
  end

  def self.try_action(input)
    return false unless $gamemode == 'play'
    return true unless @@stunned_for == 0
    x_dest = 0
    y_dest = 0
    tick = false
    case input
    when ("1".."9") then use_quickbar(input.to_i - 1)
      # Movement
    when "UP", $key_mapping[:move_up]
      tick = true
      y_dest = -1
    when "LEFT", $key_mapping[:move_left]
      tick = true
      x_dest = -1
    when "DOWN", $key_mapping[:move_down]
      tick = true
      y_dest = 1
    when "RIGHT", $key_mapping[:move_right]
      tick = true
      x_dest = 1
    when $key_mapping[:move_up_left]
      tick = true
      y_dest = -1
      x_dest = -1
    when $key_mapping[:move_up_right]
      tick = true
      y_dest = -1
      x_dest = 1
    when $key_mapping[:move_down_right]
      tick = true
      y_dest = 1
      x_dest = 1
    when $key_mapping[:move_down_left]
      tick = true
      y_dest = 1
      x_dest = -1
    when $key_mapping[:move_nowhere]
      tick = true
    when $key_mapping[:pickup_items]
      try_pickup_items
      tick = true
    when $key_mapping[:down_stairs]
      if Dungeon.current[self.y + y_dest][self.x + x_dest].uncolor == "> "
        Game.use_stairs("DOWN")
        $spawn_creatures = true
        Log.add "You go down the stairs..."
        tick = true
      end
    when $key_mapping[:up_stairs]
      if Dungeon.current[self.y + y_dest][self.x + x_dest].uncolor == "< "
        Game.use_stairs("UP")
        $spawn_creatures = true
        Log.add "You go up the stairs..."
        tick = true
      end
      # --------------------------------------------------- CHEATS ----------------------------
    when "="
      blow_walls
      Game.redraw
    when "v"
      print "\nUp: "
      Dungeon.current.search_for("< ").each { |d| print "(#{d[:x]}, #{d[:y]}) " }
      print "Down: "
      Dungeon.current.search_for("> ").each { |d| print "(#{d[:x]}, #{d[:y]}) " }
      puts
    when "V"
      Dungeon.current.each_with_index do |row, y|
        row.each_with_index do |col, x|
          seen[depth] << {x: x, y: y}
        end
      end
      seen.uniq!
      Log.add "Cheat activated: Full vision."
      Game.redraw
    when '+'
      system 'clear' or system 'cls'
      Game.input(true)
      Dungeon.current.each { |row| puts row.join('') }
    when '.'
      Player.coords = Dungeon.current.search_for('> ').first.merge({depth: Player.depth})
      Game.draw
    when 't'
      LightSource.new(4, 1000, coords)
      # --------------------------------------------------- / CHEATS ---------------------------
    end

    if (x_dest != 0 || y_dest != 0)
      unless Dungeon.current[self.y + y_dest][self.x + x_dest].is_solid?
        is_creature = false
        Creature.on_board.map do |creature|
          if creature.coords == {x: self.x + x_dest, y: self.y + y_dest, depth: self.depth}
            is_creature = true
            if self.energy > 0
              loss = (rand(10) == 0 ? 1 : 0)
              self.energy -= loss
              damage = (0..100).to_a.sample > accuracy ? -1 : (strength + (-1..1).to_a.sample)
              if damage == 0
                Log.add "#{creature.colored_name} blocked your attack."
              elsif damage < 0
                Log.add "You missed #{creature.colored_name}."
              else
                creature.hit(damage, 'physical')
                Player.equipped.each do |slot, item|
                  collided_with = creature
                  eval(item.on_hit_effect) if item.respond_to?(:on_hit_effect) && item.on_hit_effect
                end
              end
            else
              Log.add("I'm out of energy!")
            end
          end
        end
        unless is_creature
          loss = (rand(30) == 0 ? 1 : 0)
          self.energy -= loss
          self.x += x_dest
          self.y += y_dest
        end
      else
        tick = false
      end
    end

    try_pickup_items('auto') if autopickup && !(@@skip_pick_up)
    pickup_drops
    standing_on_message = Game.describe(Dungeon.at(Player.coords), Player.coords)
    if standing_on_message.length > 0 && !(standing_on_message =~ /I don't know what this is./)
      $message = standing_on_message if $message && $message.length == 0
    end
    @@skip_pick_up = false
    tick
  end

  def self.use_quickbar(input)
    item = item_in_inventory_by_name(quickbar[input])
    unless item
      temp_item = Item[quickbar[input]]
      is_spell = temp_item.class == Spell
      item = temp_item if is_spell
    end

    if item
      if item.use!
        Game.tick
      end
    else
      error = quickbar[input] ? "I don't have any #{quickbar[input]}." : "Nothing is assigned to that slot."
      Log.add(error)
      Game.redraw
    end
  end

  def self.pickup_drops
    increase = 0
    $drops[Player.depth].select { |drop| drop.coords == coords }.each do |drop|
      if drop.respond_to?(:value)
        increase += drop.value
      end
      drop.pickup
    end
    Log.add("Gained #{increase} gold! (#{Player.gold})") if increase > 0
  end

  def self.try_pickup_items(method="key_press")
    items_to_pickup = Item.on_board.select { |i| i.coords == coords && (method == 'auto' ? i.auto_pickup : true) }
    if items_to_pickup.count > 0
      picked_up_items = pickup_items(items_to_pickup)
      Log.add "My inventory is full." if picked_up_items.count == 0
      self.try_pickup_items('do_again') if picked_up_items.count > 0
    else
      Log.add "Nothing to pick up." if method == 'key_press'
    end
  end

  def self.strength; raw_strength + bonuses[:strength].to_i; end
  def self.magic_power; raw_magic_power + bonuses[:magic_power].to_i; end
  def self.defense; raw_defense + bonuses[:defense].to_i; end
  def self.accuracy; raw_accuracy + bonuses[:accuracy].to_i; end
  def self.speed; (raw_speed + bonuses[:speed].to_i) / (energy > 0 ? 1 : 2); end
  def self.max_health; raw_max_health + bonuses[:max_health].to_i; end
  def self.max_mana; raw_max_mana + bonuses[:max_mana].to_i; end
  def self.max_energy; raw_max_energy + bonuses[:max_energy].to_i; end
  def self.self_regen; raw_self_regen + bonuses[:self_regen].to_i; end

  def self.bonus(stat)
    bonus_stat = 0
    equipped.each do |location, equipment|
      if equipment
        bonus_stat += equipment.method("bonus_#{stat.to_s}".to_sym).call
      end
    end
    bonus_stat
  end

  def self.bonuses
    bonus = {}
    equipped.each do |location, equipment|
      if equipment
        bonus[:strength] ||= 0; bonus[:strength] += equipment.bonus_strength.to_i
        bonus[:magic_power] ||= 0; bonus[:magic_power] += equipment.bonus_magic_power.to_i
        bonus[:defense] ||= 0; bonus[:defense] += equipment.bonus_defense.to_i
        bonus[:accuracy] ||= 0; bonus[:accuracy] += equipment.bonus_accuracy.to_i
        bonus[:speed] ||= 0; bonus[:speed] += equipment.bonus_speed.to_i
        bonus[:max_health] ||= 0; bonus[:max_health] += equipment.bonus_health.to_i
        bonus[:max_mana] ||= 0; bonus[:max_mana] += equipment.bonus_mana.to_i
        bonus[:max_energy] ||= 0; bonus[:max_energy] += equipment.bonus_energy.to_i
        bonus[:self_regen] ||= 0; bonus[:self_regen] += equipment.bonus_self_regen.to_i
      end
    end
    bonus
  end

  def self.has(item)
    if item.is_a?(String)
      Player.inventory.map(&:name).include?(item)
    else
      Player.inventory.include?(item)
    end
  end

  def self.sort_inventory!
    old_inven = self.inventory
    sorted_inven = self.inventory.sort_by(&:name)
    is_equal = true
    i = 0
    while is_equal && i < old_inven.length
      unless old_inven[i].name == sorted_inven[i].name
        is_equal = false
      end
      i += 1
    end
    if is_equal
      self.inventory = self.inventory.sort_by(&:name).reverse
    else
      self.inventory = self.inventory.sort_by(&:name)
    end
  end

  def self.swap_inventory(slot_a, slot_b, on_ground=false)
    return false unless slot_a && slot_b
    return swap_with_ground(slot_a, slot_b) if on_ground
    inven_by_array = self.inventory_by_stacks.to_a
    return false unless inven_by_array[slot_a] && inven_by_array[slot_b]
    inven_by_array[slot_a], inven_by_array[slot_b] = inven_by_array[slot_b], inven_by_array[slot_a]
    self.inventory = inven_by_array.map { |name, array_of_items| array_of_items }.flatten
    true
  end

  def self.swap_with_ground(ground_item_slot, inven_item_slot)
    ground_item_slot -= 1 # Offset since items start on 2 for the Read More
    stacks = $stack.group_by { |item| item.name }
    selected_items = stacks.to_a[ground_item_slot].last
    return false unless selected_items
    items_to_swap_from_ground = selected_items.first(selected_items.first.stack_size)
    inven_by_array = self.inventory_by_stacks.to_a
    return false unless inven_by_array[inven_item_slot] && items_to_swap_from_ground.first
    drop_many(inven_by_array[inven_item_slot].last)
    items_to_swap_from_ground.each do |item|
    end
    pickup_items(items_to_swap_from_ground, inven_item_slot)
    true
  end

  def self.pickup_items(items, position='last')
    items_picked_up = []
    items.group_by {|i| i.name }.each do |item_name, items|
      items_picked_up = []
      items.each do |item|
        if pickup_item(item)
          items_picked_up << item
        end
      end
      items_count = items_picked_up.count
      if items_count > 0
        Log.add "Picked up #{item_name}#{items_count > 1 ? " x#{items_count}" : ''}."
      end
    end
    unless position == 'last'
      swap_inventory(inventory_by_stacks.count - 1, position)
    end
    items_picked_up
  end

  def self.pickup_item(item)
    self.inventory << item
    if Player.inventory_by_stacks.count > Player.inventory_size
      self.inventory.delete(item)
      return false
    else
      item.pickup
      return true
    end
  end

  def self.inventory_by_stacks
    stacks = {}
    self.inventory.map do |item|
      next unless item
      stacks[item.name] ||= []
      item_out_of_place = true
      i = 2
      while item_out_of_place
        if stacks[item.name].length < stack_size_of(item)
          stacks[item.name] << item
          item_out_of_place = false
        else
          stacks["#{item.name} (#{i})"] ||= []
          if stacks["#{item.name} (#{i})"].length < item.stack_size
            stacks["#{item.name} (#{i})"] << item
            item_out_of_place = false
          end
          i += 1
        end
      end
    end.compact
    stacks
  end

  def self.stack_size_of(item)
    Player.equipped.each do |slot, equipment|
      if equipment.respond_to?(:contains)
        return equipment.contains == item.name ? equipment.size : item.stack_size
      end
    end
    item.stack_size
  end

  def self.item_in_inventory_by_name(name)
    self.inventory.select { |item| item.name == name }.first
  end

  def self.equippable_inventory(slot)
    self.inventory.select do |i|
      if i.respond_to?(:equipment_slot)
        i.equipment_slot == slot.to_sym
      end
    end
  end

  def self.inventory_weight
    Player.inventory.inject(0) { |sum, item| sum + item.weight }.round(3)
  end

  def self.equipped_weight
    Player.equipped.inject(0) { |sum, item| sum + (item[1] ? item[1].weight : 0) }.round(3)
  end

  def self.give(item_name)
    if item = Item[item_name]
      Player.inventory << item
      item
    end
  end

  def self.equip(item, slot=nil)
    slot ||= item.equipment_slot if item
    if Player.equipped[slot]
      Player.inventory << Player.equipped[slot]
      Player.equipped[slot] = nil
    end
    if item
      Player.inventory.delete(item)
      Player.equipped[slot] = item
      Log.add "Equipped #{item.name}."
    end
  end

  def self.lit_radius
    Player.equipped.map { |slot, item| item.is_a?(LightSource) ? item.range : 0 }.sort.last
  end

  def self.throw_item(item, direction_coords)
    Player.inventory.delete(item)

    str = Math.greater_of(Player.raw_strength, 10)
    x, y = direction_coords
    x = x > str ? str : x
    y = y > str ? str : y
    x = x < -str ? -str : x
    y = y < -str ? -str : y

    if x == 0 && y == 0
      Log.add "Dropped #{item.name}."
    else
      Log.add "Threw #{item.name}."
    end
    Projectile.new({x: Player.x + x, y: Player.y + y}, item, Player, 'physical')
  end

  def self.drop(item, show_log=true)
    Log.add "Dropped #{item.name}." if show_log
    item.drop(Player.coords)
    Player.inventory.delete(item)
    @@skip_pick_up = true
  end

  def self.drop_many(items)
    Log.add "Dropped #{items.first.name} x#{items.count}." if items.count > 0
    items.each do |item|
      drop(item, false)
    end
  end

  def self.currently_standing_on
    Item.on_board.select { |i| i.coords == coords }
  end

  def self.visibility(amount)
    self.invisibility_ticks += amount
  end

  def self.invincible?
    Player.invincibility > 0
  end

  def self.blow_walls
    px = self.x
    py = self.y
    (-1..1).each do |x|
      (-1..1).each do |y|
        not_nil = !(Dungeon.current[y + py].nil?)
        solid_block = Dungeon.current[y + py][x + px].is_solid?
        breakable = !(Dungeon.current[y + py][x + px].is_unbreakable?)
        if not_nil && solid_block && breakable
          Dungeon.current[y + py][x + px] = "  "
        end
      end
    end
  end
end
