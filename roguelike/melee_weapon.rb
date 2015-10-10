class MeleeWeapon < BaseObject
  include Item
  
  attr_accessor :equipment_slot, :bonus_strength, :bonus_defense, :bonus_accuracy, :bonus_speed, :bonus_health, :bonus_mana, :bonus_energy, :bonus_self_regen, :bonus_magic_power

  def self.generate
    new({
      name: 'Excalibur',
      icon: '†',
      equipment_slot: :main_hand,
      color: :light_yellow,
      weight: 12,
      bonus_health: 50,
      bonus_mana: 50,
      bonus_strength: 10,
      bonus_self_regen: 10
    })
    new({
      name: 'Rusty Dagger',
      icon: '†',
      equipment_slot: :main_hand,
      weight: 4,
      bonus_strength: 1
    })
    new({
      name: 'Fire Sword',
      icon: '†',
      color: :red,
      equipment_slot: :main_hand,
      weight: 4,
      bonus_strength: 1,
      on_hit_effect: Evals.new_dot(5, 2, 'fire', false)
    })
  end
end
