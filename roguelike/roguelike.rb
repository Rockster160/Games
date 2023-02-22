# TODO
=begin
http://fantasynamegenerators.com/magic-book-names.php#.Ve3efGA_78H

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~     BUGS    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Quick walking
  Sometimes the player does not pick up items below him
  Sometimes Player doesn't stop when seen by enemy
  Sometimes Player does not 'see' around him, especially with 0 lighting, does not

When activating the map or targeting, the first frame does not show the target

Fix Sleeping menu - don't display instructions below game screen

Vision calculation is a little off. Radius 2, Player does not see (+2, +1), but sees (-2, +1) Left and Up has issues. Right and Down do not.

Collision detection of projectiles seems off

After shooting an arrow, the arrow retains it's extra damage? -> Minor, but the arrow will do much more damage when thrown.

Sometimes explosions are not shown

Targeting uses 2 clicks -> Only for casting spells with auto-targeting

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~     TODO    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Greatly reduce magic damage, scale magic damage with magic power
Allow purchase of items to increase defense and power

Character Experience/levels
Scaling for enemies
Enemy special abilities?

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   FUNCTION  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Have a ground item that displays a message but cannot be picked up

if player doesn't move, do not change vision calculations
  Would it be faster to calculate the changed coordinates?
  Map the coords of all items on current level, calculate distance to player, if in range, then try to do vision
    ^^ Is that faster than already having the vision calculations and mapping through?

Create a base object class that everything else inherits from.
  Has coords, pickup, drop actions, etc.

refactor heal/hurt sources to objects instead of strings

dodged/blocked only when necessary. Some items (magic spells) won't do damage on collision, but should show a status effect.
"{} has been poisoned/burned/etc"

Save data
  At startup, request user to select a load file or to create a new one.

Should be able to select specific item from Inventory stacks if the items are different in any way. (Torches)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   FEATURES  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
More advanced books have more spells
Able to transcribe scrolls into books if the element matches

Ranged enemies

Build the town to buy/sell stuff.

Allow Player to level up and increase stats
Have skill levels for different types of weapons
Incorporate two handed weapons
(2-handed weapons grant speed reduction if there is an item in the other hand)

Add different default keyboard layouts

Add knockback, slow, and stun spells

Add holes that 'fall' to the next floor

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

How many lines?
>> run in irb.
Dir["./*"].inject(0) {|count, path| count + %x{wc -l < "#{path}"}.to_i}

=end

# require 'pry-rails' # TODO Remove this!

require 'io/console'
require './monkey_patches.rb'
require './evals.rb'
require './key_bindings.rb'
require './input.rb'
require './log.rb'

require './gold.rb'
require './gems.rb'
require './item.rb'
require './light_source.rb'
require './visual_effect.rb'
require './dot_effect.rb'
require './consumable.rb'
require './projectile.rb'
require './equipment.rb'
require './melee_weapon.rb'
require './static_item.rb'
require './ranged_weapon.rb'
require './magic_weapon.rb'
require './spell_book.rb'
require './spell.rb'

require './creature.rb'
require './player.rb'

require './game.rb'
require './settings.rb'
require './dungeon.rb'
require './visible.rb'

seed = 40.times.map {|a| (rand_seed ||= Random.new_seed.to_s)[a] ? rand_seed[a] : 1}.join.to_i
Game.start(seed)

# Player.equipped[:back] = Item["Quiver"]
Player.equipped[:off_hand] = Item['Torch']
# Player.equipped[:main_hand] = Item['Fire Sword']
# Player.inventory << Item['Standard Bow']
# Player.inventory << Item['Book of Fire']
# Player.inventory << Item['Amulet of Power']
# 5.times { Player.inventory << Item['Scroll of Flash'] }
# 99.times { Player.inventory << Item['Arrow'] }
5.times { Player.inventory << Item['Torch'] }
Player.quickbar = ["Standard Bow", "Bread Scrap",  "Bread Chunk", "Book of Fire", "Fire Blast", "Summon Stone", "Torch", nil, 'Scroll of Flash']
# Player.invincibility = 999999999

system 'clear' or system 'cls'
Game.draw

while(true)
  if $gamemode == 'sleep' || $gamemode == 'auto-pilot'
    if eval($auto_pilot_condition)
      if Player.sleeping
        Player.sleeping = false
        Log.add "You have awoken."
      end
      $gamemode = 'play'
      Game.redraw
    else
      Game.tick(false)
    end
  else
    input = Input.read_single_key
    if input
      $milli_tick = Time.now.to_f
      Settings.receive(input)
      if $skip == 0 && Player.try_action(input)
        Game.tick
      else
        $skip -= 1
        $skip = $skip < 0 ? 0 : $skip
      end
    end
  end
end
