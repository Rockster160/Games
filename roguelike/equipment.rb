class Equipment < BaseObject
  include Item

  attr_accessor :equipment_slot, :is_equipped, :bonus_strength, :bonus_defense, :bonus_accuracy, :bonus_speed, :bonus_health, :bonus_mana, :bonus_energy, :bonus_self_regen, :bonus_magic_power
  attr_accessor :contains, :size # Contains an item (Quiver contains Arrow), size is how many

  def self.generate
    new({
      name: 'Quiver',
      icon: '=',
      contains: 'Arrow',
      size: 99,
      equipment_slot: :back,
      color: :green,
      weight: 6
    })
  end
end
