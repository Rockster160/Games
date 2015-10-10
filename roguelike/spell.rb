class Spell < BaseObject
  include Item

  attr_accessor :range, :destroy_on_collision_with, :on_hit_effect, :on_hit_damage, :collided_action, :projectile_speed, :is_thrown, :ammo_type, :shoot_damage
  attr_accessor :mana_cost, :is_projectile, :non_projectile_script, :type
  
  def cast!(needs_verify=false)
    if needs_verify
      unless Player.inventory.select { |item| item.class == SpellBook }.map { |books| books.castable_spells }.flatten.include?(self.name)
        Log.add "I can't cast this spell"
        $gamemode = 'play'
        return false
      end
    end
    if Player.mana >= mana_cost
      if is_projectile
        Settings.ready('cast', self, self.range)
      else
        Settings.ready_cast(self, self.range)
      end
    else
      Log.add "Not enough Mana."
      $gamemode = 'play'
    end
    Game.redraw unless needs_verify
    false
  end

  def self.generate
    new({
      name: 'Fire Blast',
      icon: 'o',
      color: :light_red,
      destroy_on_collision_with: 'a',
      range: 10,
      is_projectile: true,
      type: 'fire',
      projectile_speed: 20,
      on_hit_damage: 0,
      collided_action: Evals.explode(1, 20, 'fire'),
      mana_cost: 5
    })
    new({
      name: 'Fire Ball',
      icon: 'o',
      color: :light_red,
      destroy_on_collision_with: 'a',
      range: 10,
      is_projectile: true,
      type: 'fire',
      projectile_speed: 20,
      on_hit_damage: 0,
      collided_action: Evals.explode(0, 10, 'fire'),
      mana_cost: 3
    })
    new({
      name: 'Poison Blast',
      icon: 'o',
      color: :light_green,
      destroy_on_collision_with: 'a',
      range: 10,
      is_projectile: true,
      type: 'poison',
      projectile_speed: 20,
      on_hit_damage: 0,
      collided_action: Evals.new_dot(5, 2, 'poison'),
      mana_cost: 2
    })
  end
end
