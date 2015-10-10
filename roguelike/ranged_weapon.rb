class RangedWeapon < BaseObject
  include Item

  attr_accessor :range, :destroy_on_collision_with, :on_hit_effect, :on_hit_damage, :collided_action, :projectile_speed, :is_thrown, :ammo_type, :shoot_damage
  attr_accessor :equipment_slot, :bonus_strength, :bonus_defense, :bonus_accuracy, :bonus_speed, :bonus_health, :bonus_mana, :bonus_energy, :bonus_self_regen, :bonus_magic_power

  def fire!
    if is_thrown
      Settings.ready('throw', self, self.range)
    else
      if Player.has(ammo_type)
        ammo = Player.item_in_inventory_by_name(ammo_type)
        ammo.on_hit_damage = Item[ammo_type].on_hit_damage + (self.shoot_damage || 0)
        ammo.range = (Item[ammo_type].range || 0) + (self.range || 0)
        Settings.ready('shoot', ammo, ammo.range, Player.item_in_inventory_by_name(ammo_type))
      else
        Log.add "Out of ammo. Need more #{ammo_type}."
      end
    end
    false
  end

  def self.generate
    generate_projectiles
    generate_weapons
  end

  def self.generate_projectiles
    new({
      name: 'Arrow',
      icon: '-',
      color: :white,
      destroy_on_collision_with: 'P C',
      stack_size: 15,
      range: 20,
      projectile_speed: 80,
      on_hit_damage: 3,
      is_thrown: true,
      weight: 0.3,
      description: "This is an arrow"
    })
  end

  def self.generate_weapons
    new({
      name: 'Standard Bow',
      icon: '}',
      ammo_type: 'Arrow',
      color: :white,
      range: 10,
      shoot_damage: 5,
      is_thrown: false,
      weight: 3
    })
  end
end
