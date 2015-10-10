class MagicWeapon < BaseObject # wands
  include Item

  attr_accessor :range, :type, :mana_usage

  # def fire! # Cast Spell
  #   ammo = Item[ammo_type]
  #   if Player.mana >= ammo.mana_cost
  #     Settings.ready('shoot', self, range, ammo)
  #     Player.mana -= ammo.mana_cost
  #     false
  #   else
  #     Log.add "Not enough mana."
  #     $gamemode = 'play'
  #     Game.redraw
  #     false
  #   end
  # end

  def self.generate
  end
end
