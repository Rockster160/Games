Oct 15, 2015 v0.0.60
Reduced gold value of drops and findings
Changed the way the slimes decide to split
Slimes now drop the amount of slime balls equal to their strength/size
Fixed game-crashing bug caused when trying to look at a slime in any targeting menu.
Player no longer picks up all of the items he dropped if he performs an activity in the same spot
Fixed Map jumping to the top of the screen when exiting the read more menu
Added skeletons, which come back to life if their corpse is left on the ground
Made enemies weaker, so they scale slower
Fixed bug making Slimes way too strong
  Slimes now balance their strength with newly spawned slimes
Fixed Gold not picking up when Quick walking
Fixed Items not getting thrown
Added a Boss
  First boss is an extra powerful Slime.
  Down Staircase does not appear until the boss has been defeated.
Fixed creature color being set improperly.
Fixed the Map viewing of objects and creatures being incorrect

Oct 14, 2015 v0.0.59
Added type, mana, and range for spells when casting them
Can now 'Read More' on Spell in the SpellBook/Amulets
'Read More' only shows stats when it's equipment and shows spells if it can cast spells
Added Descriptions for Items
Items can now reference a specific item instead of instantiating a new item each time.
When placing a solid object, light sources update their lighting values

Oct 13, 2015 v0.0.58
Refactored Class methods to be easier to read/write
Added Berserk mode for the Player
  Going berserk costs 1 energy per tick
  Gains 50% strength
  Gains 3 speed
  Lasts a certain amount of time or until the Player runs out of energy.
Added a berserk potion and spell
Player can now 'quick-walk'
  Quick walk by holding shift and clicking a direction
  Quick walk will go for 10 spaces or until you hit a wall or get seen by an enemy
Non-projectile spells can now be cast
  Spells without range will automatically be cast on the Player
  Spells with range will automatically open in the Targeting menu
Added a range indicator to the targeting menu

Oct 12, 2015 v0.0.57
Bonuses are made to be faster in code
Added a Maze level every 5 levels

Oct 7, 2015 v0.0.56
Fixed bug that caused Torches to be destroyed unexpectedly.
Torches have a light of at least 1 until they burn out.
Equipment Items can now be added to the Quick bar.
Light Sources show their duration and range where other items show their specs
Added a description for Torches
Torches no longer get picked up automatically

Oct 6, 2015 v0.0.55
Renamed 'Right' and 'Left' hands to 'Main' and 'Off' Hands.
Added Light Sources that diminish over time
Light Sources can be held, lighting an area around the player.
Light Sources can be placed on the ground, lighting the area on the ground
Items and enemies are only revealed if they are both within light AND within a certain radius of the player

Oct 5, 2015, v0.0.54
Refactored damage to factor in defense
  * Defense only works against physical damage. If other types of damage is done (magic) then specific resistances will come into play instead.

Oct 4, 2015 v0.0.53
Creatures now have birth times, which are used to control the timing of the motion.
  Prevents similar creatures from moving at the same time.

Oct 3, 2015 v.0.0.52
Refactored the way items on the board are drawn
Renamed selection methods to be more clear
Refactored Flashing
  * Flashing now can only jump to where a player has previously seen.
    - (This will avoid accidentally flashing into holes that cannot be escaped from)
  * Flashing will always succeed
   - Will jump to the furthest possible location based on range, previously seen open spaces, walls, and enemies

Oct 2, 2015 v0.0.51
Refactored Coords hashes. Should see no effect in game.

Oct 1, 2015 v0.0.50
User can now modify the keybindings in the keybindings ('K' by default) menu

Sept 30, 2015 v.0.0.49
Selecting items that are on the ground works better now.
Swapping items from the ground now places those items in the swapped position
Fixed Scrolling on menus with Selectable options
Scrolling also now wraps based on the last item in the list instead of the full screen

Sept 29, 2015 v0.0.48
If a Players inventory is full, or auto-pickup is off, he can view the items on the ground and select which to pick up
Many bugs, as a lot of code was lost...
Created a new Dungeon type that will appear on every 10th level.

Sept 26, 2015 v0.0.47
Refactored the way items on the ground are described.
Player describes items that he is standing on.

Sept 15, 2015 v0.0.46
Creatures can prioritize target objects over others, and have different vision ranges for each.
Made modifications to Slime spawning, made more efficient and less Slime over load
Fixed canceling a spell still using the mana
Creature Names are now at the end of the log when receiving damage
Previous menus visited are now stored and programmatically determined when pressing 'back' so no more strange redirects.
Added functionality to 'read more' about items in the Equipment screens
Fixed the range on Arrows not being long enough.

Sept 14, 2015 v0.0.45
Added Slimes
* Slimes multiply slowly over time
* Slimes drop Slime Balls.
  * Slime balls currently do nothing for the player
* Other Slimes can pick up Slime Balls to gain health and strength.
* Slimes are attracted to Slime Balls and will prioritize them over attacking the player
Updated Creature spawning. Creatures spawn based on level
Finally fixed issue with speeds being messed up.
Added StaticItems, which upon being used, usually don't do anything.
Fixed bug with dropping a stack of items
Added the Change Log

Sept 13, 2015 v0.0.44
SpellBooks now contain Spells.
* Using a spell book shows the spells that can be used, then selected to use
* Adding a Spellbook to the Quickbar will Open the book
* Spells can be selected using SPACE to add them to the Quickbar as a shortcut
* Spells can be sorted the same way the inventory is
Refactored targeting again to be even more scalable
Refactored Dungeons
* Adjusted by parameter entry.
* Default dungeon has more tunnel noise, so tunnels aren't perfectly straight any more.
* Dungeons change based on level
Reduced Player vision

Sept 11, 2015 v0.0.43
Projectiles can do increased damage when fired by a different weapon
Refactored DOT's
* Simplified Scripts
* Made more Scalable

Sept 9, 2015 v0.0.42
Added Gems every 10 levels that permanently increase the Play stats
Resurrect Player with full health
Resurrection now grants temporary invincibility
Added Bread Chunks, which restore more health than bread scraps
Creatures should no longer spawn within 10 spaces of player
Fixed dots trying to damage walls
Refactored weapons and items to be generated by their specific classes instead of being handled by the module.
Added Containers, which can modify the amount of items can be stacked in each stack
* Quiver, changes Arrow stacks from 15 -> 99
Player automatically drops all overflow items in inventory
If standing on items, pressing 'r' will show all items on the ground.


Sept 6, 2015 v0.0.41
Fixed evals ticking incorrectly
Removed Attack Speed. Everything Attacks at the speed it runs.
Modified Creature stats to better reflect the creature type.
Renamed 'raw' damage to 'physical' damage
If a projectile has an on-hit-damage, that is used. Otherwise it does damage based on speed/distance
Reduced Player stats further to resemble early game
Minimum throwing distance created

Sept 1, 2015 v0.0.40
Created a Menu that shows the Player's current Stats

Aug 28, 2015 v0.0.39
Weapons can now have on-hit effects, causing a sword to be poison tipped or do fire damage over time.
Added indicators in menus to let the player know they can jump to positions in the menu by hitting the respective numbers

Aug 25, 2015 v0.0.38
Reafactored the way evals work, they are now stored in a class, which is called. Makes code MUCH cleaner
Added DOT's, damage-over-time, so Creatures can be burned/poisoned
Assigned Id's to Creatures so they can be individually selected
Refactored damage to have a type (fire, poison, physical, etc.)
Quickbar will display the ammo it uses

Aug 23, 2015 v0.0.37
Created effects that come from explosions that show up for a tick and then disappear
Made GUI corners a little more pretty

Aug 22, 2015 v0.0.36
Inventory can now be sorted by swapping items or clicking a sort alphabetically button
's' exits menus if not otherwise used
Fixed bug breaking spells
Player cannot use non-consumables if they are out of energy


Aug 21, 2015 v0.0.35
Fixed another ticking bug with consuming Items
Made Creatures not scale speed based on level, only strength
Added the ability to resurrect the Player if they have an item that allows them to do so.

Aug 18, 2015 v0.0.34
Projectiles have sources, speed, damage, ammo
* Uses ammo to fire
Created Bow and arrow
Fixed bug where Unstable Teleportation would randomly land the Player in an inescapable place
Created Spells that fire like arrows but have effects on landing
* Spellbooks use mana
Added the functionality to 'read more' about Items
Made message from projectiles make more sense and work properly

Aug 13, 2015 v0.0.33
Began the work on Ranged Weapons

Aug 11, 2015 v0.0.32
Fixed spells skipping

Aug 10, 2015 v0.0.31
Fixed bug where Targeting items got broken
Made Targeting more scalable for the future
Targeting now has a max distance that an item can travel

Aug 9, 2015 v0.0.30
Creatures can drop bread scraps
Gold now has depth, so it isn't displayed on every level
Made the Quickbar functional
* User can assign items to the Quick bar through the Inventory menu
* User can use the items by hitting the respective number
Managed logs better by not spamming.
* If multiple Logs are added in the same tick, they are combined and given a multiplier


Aug 8, 2015 v0.0.29
Creatures now randomly change their minds about the direction they are moving.
* This fixes bug where they continue to try get to a place they can't get.
Fixed more bugs with ticking at inappropriate times.

Aug 4, 2015 v0.0.28
Cleaned up test code
Added the ability to hit Backspace to move up the menu stack

Aug 3, 2015 v0.0.27
Fixed bug caused by throwing an object and then Exploring

Aug 2, 2015 v0.0.26
Player can now drop items, or a full stack of items
Created Projectiles/throwable items

June 9, 2015 v0.0.25
Refactored items to inherit from the Item Module.
* Removed duplicated method from all inheritable classes
Items are now stackable, with customizable stack sizes
Player can only hold a certain amount of items
Fixed Inventory bug

June 8, 2015 v0.0.24
Scripts added to Consumables
* Added Scroll of Teleportation, which teleports the user to a random open position on the map.
* Bread of Invisibility, makes the player invisible for a short time.
Added the Resting mechanic. A Player can be passive for a time period they specify and automatically awake in danger


June 5, 2015 v0.0.23
Fixed bug where Gold was being placed on top of unbreakable walls
Fixed crash if there was no gold on the current map
Fixed crash when trying to use/consume an item that couldn't be used/consumed

June 4, 2015 v0.0.22
Added Consumable Items, which can be consumed to apply a custom effect
Fixed bugs in menus
* Having an item in inventory that wasn't equippable caused a crash
* Ticks were happening at the wrong times

May 28, 2015 v0.0.21
When selecting equipment, the change in stats is shown.
You can 'read more' on an item to see the details about it.
Monkey patched Math and added Math-y stuff to it (Line function and distance function)

May 27, 2015 v0.0.20
Player can now 'read more' on certain areas, specifically in the Explore method to see what items are in a stack
Cleaned up Player code
Game no longer automatically ends when the Player dies. Instead, a death screen is shown.
* The player can then see the Logs, and their inventory, etc.
Some menus are selectable. Hitting 's' creates a selector used to choose an item

May 26, 2015 v0.0.19
Bonus stats from item are now actually applied
Items can be equipped through the UI.
Added Accuracy for the Player/Creatures, which affects if they hit their attack or not.
Convention: When opening menu's, use SHIFT+key
Cleaned up the Settings file


May 25, 2015 v0.0.18
Completed the Explore function.
* Fixed lots of bugs with it, made it more efficient
Player now has raw stats and bonus stats and does damage based on the combination of them.
Fixed Logs from saying you dealt 0 damage. Instead, show missed/dodged

May 21, 2015 v0.0.17
Added an Explorer method, where the Player can scroll around the map and see everything they've previously mapped out.
* Shows the current screen, so the Player does not see locations of items or Creatures

May 21, 2015 v0.0.16
Built a log page that allows the Player to view and scroll through all of the logs in a separate screen.
Converted Keys into variables that can be called and modified at a later time
Refactored Menus to be more expandable
Created a word wrap method to prevent words from overflowing off the screen in the case of long text.
Created a basic help menu
Input is now passed through the Player and Settings functions.
Alert the Player via logs when they are low on any of their stats.
Add a killed by message to the Log

May 20, 2015 v0.0.15
A basic message can no be shown at the top of the screen, which will also show basic status that doesn't need to be logged.
Moved Viewport widths and heights into Constants to reduce magic numbers
Added the ability to make the Player invisible, which prevents monsters from seeing the Player, although they will still attack if they run into the Player
Added a Settings file which will controls menus/inventory
Fixed colors on backgrounds messing the logs up.

May 19, 2015 v0.0.14
Added Item classes
* Equipment will be worn items that passively grant the player bonus stats. These won't take space in the inventory, but will add to overall weight
* Magic Weapons will be Scrolls, SpellBooks, Wands, Staves, and anything of the sort
* Melee Weapons will be equipped like equipment
* Ranged Weapons will sit in the inventory and need to be used when desired.
Added basic stats to Items that will be inherited to all Items.
Added a way to generate items
Player will eventually be able to disable auto-pickup of items, added a key to manually pick them up.

May 19, 2015 v0.0.13
Added Vision to Creatures
Added Gold
Creatures drop gold when they die
Refactored the way the Player is called
Began the structure to add items

Apr 25, 2015 v0.0.12
Player now has energy/hunger, which depletes over time
The player cannot fight unless he has energy

Apr 25, 2015 v0.0.11
Added attack speed, run speed, and strength for creatures
Creatures are now generated by their icon being passed in the new method
Creatures now spawn every 20 ticks, as long as there is not an excess of them
Dungeon is now regenerated until a dungeon with stairs is completed
Added a quick bar to the player, so the player can use items without opening the inventory
Creatures now avoid standing on each other, and instead treat other creatures as see-through walls.

Apr 25, 2015 v0.0.10
Creatures always try to move to the player if it's in range
Made Player have a reasonable amount of health

Apr 25, 2015 v0.0.9
Refactored Logs to only need the string, and handles the rest automatically
Visibility calculations now take radius into account instead of being hard coded.
Colors are now by symbol instead of crazy numbers

Apr 24, 2015 v0.0.8
Fighting has been completed
* Player can die
* Monsters can die
* Player deals damage to monsters by running into them
* Monsters damage Player by running into it
* The game will close when the Player has been killed.
10 monsters are now spawned on every level
Logs are now timestamped at the tick they happened.

Apr 24, 2015, v0.0.7
Added Creatures to the game!
* Creatures have health, speed, an icon, and other options.
* Creatures have verbs that are randomly selected when attacking
* Creatures will be able to wander (randomly move around), charge (run towards the player), and retreat (run away from the player), although only wander has been done.
Player is now a self-referencing class to make calling it easier.
10 creatures are spawned at the beginning of the game.

Apr 24, 2015 v0.0.6
Added a testing method in order to make sure stairs are drawn in every dungeon.
Hopefully fixed the stairs being deleted... Still
The game now calculates the average fps based on the past 50 frames, shown in debugging tools

Apr 23, 2015 v0.0.5
Hopefully Fixed bug causing Stairs not to be generated on some levels
Added Game logs, which will display basic information in the game such as damage and items
Added an actual GUI with stat bars that display the user's health, energy, mana, and gold.
* Bars change color based on how high they are. As they get low, the colors change to reflect it.
Player vision is now actually based on the Player vision instead of a magic number
Added basic stats and stat modifiers for the player.
Made the game look less flashy by calculating the entire board before clearing the old one and redrawing.
Made modifications to the Dungeon generation: Rooms are smaller, tunnels are longer.

Apr 23, 2015 v0.0.4
Added Stairs, which keep track of relative positions on the previous floor in order to place the Player appropriately
Added more debugging tools, added a visual border around the edge of the viewport.
Fixed a bug where the viewport doesn't work very well in corners.
Modified the dungeon generation so that the hallways are shorter and straighter

Apr 22, 2015 v0.0.3
Set width and height values so the game fits in a set view port and is centered around the player at all times.
Calculates the FPS every frame and displays it in the debugging tools, which are shown below the game screen

Apr 22, 2015 v0.0.2
Extracted files that call each other to run the game on a single call.
Added unbreakable walls around the edge of the map to prevent the player escaping.
Created the 'Game' file which will handle all of the functionality of the game running.
Added a depth value to the Player
Modified the way the Player accepts movement keys
The dungeons are now stored in a massive array where the index is depth of the floor
Added a debugger, allowing walls to be 'blown away' or deleted around the player.
The Roguelike file will be used to run the game loop, track to do list, and set up the initial environment
Made the Vision function more efficient

Apr 21, 2015 v0.0.1
Built the beginning of the Roguelike Game.
This was all done over time, specifically the dungeon generation, vision, and tracked information
Generates Mazes:
* Mazes consist of 3 files, Dungeon, Arena, Walker
  Dungeon: The Controller for creating Dungeons. Will accept Parameters to specify any types of variations that may exist.
  * Controls the Walker, which cuts out hallways.
  * Bashes down rooms when necessary.
  * Places Stairs
  Arena: The 'skeleton' of the Dungeon. Basically a hash (to allow infinite expansion in any direction) that converts itself to an array/string to be used by the game
  Walker: Walkers are generated by the dungeon and wander around randomly but with some direction. They last a certain distance and then die off.
Accepts input. Uses raw, live/multi-threading, cooked input.
* Stops the input being shown to the terminal
* Allows the game to read the input without the user hitting ENTER
* Reads the entire input instead of each individual character, allows special keys (such as the arrow keys) to be used
Created the Player, and the player can move.
Wrote a vision library that draws a line to every point in a circle and determines what can be seen based on the line
Built the basic game
* Game tracks where the player has seen and what the player can currently see
