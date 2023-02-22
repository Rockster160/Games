# In order to unpoint, we just mix up the dimension
execute as @s[predicate=lifeform_analyzer:in_overworld] run execute in minecraft:overworld run data modify storage lifeform_analyzer:calibrate_slot Item merge value {tag: {LodestoneDimension: "minecraft:the_nether"}}
execute as @s[predicate=lifeform_analyzer:in_the_nether] run execute in minecraft:overworld run data modify storage lifeform_analyzer:calibrate_slot Item merge value {tag: {LodestoneDimension: "minecraft:the_end"}}
execute as @s[predicate=lifeform_analyzer:in_the_end] run execute in minecraft:overworld run data modify storage lifeform_analyzer:calibrate_slot Item merge value {tag: {LodestoneDimension: "minecraft:overworld"}}

execute in minecraft:overworld run data modify storage lifeform_analyzer:calibrate_slot Item.tag.LodestonePos.X set value 0
execute in minecraft:overworld run data modify storage lifeform_analyzer:calibrate_slot Item.tag.LodestonePos.Y set value 0
execute in minecraft:overworld run data modify storage lifeform_analyzer:calibrate_slot Item.tag.LodestonePos.Z set value 0

execute in minecraft:overworld run data modify storage lifeform_analyzer:calibrate_slot Item.Slot set value 0b

execute in minecraft:overworld run data modify block 0 0 0 Items append from storage lifeform_analyzer:calibrate_slot Item
