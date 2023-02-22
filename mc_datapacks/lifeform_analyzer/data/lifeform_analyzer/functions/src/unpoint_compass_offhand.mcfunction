# First, we copy the item to a storage.
execute in minecraft:overworld run data modify storage lifeform_analyzer:calibrate_slot Item set from entity @s Inventory[{Slot: -106b}]

# Modify the compass in the box
execute as @s at @s run function lifeform_analyzer:src/unpoint_compass

# Then, we move the shulker box item back to the player's inventory.
execute if entity @s[predicate=lifeform_analyzer:offhand_lfa] run execute in minecraft:overworld run item replace entity @s weapon.offhand from block 0 0 0 container.0
data remove block 0 0 0 Items
