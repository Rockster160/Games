# @a[predicate=lifeform_analyzer:holding_lfa]

execute at @s run execute unless entity @e[predicate=lifeform_analyzer:is_hostile,distance=..20] run title @s actionbar [{"text": "No danger detected.", "color": "white"}]
execute as @a[predicate=lifeform_analyzer:mainhand_lfa,predicate=lifeform_analyzer:mainhand_lfa_pointing] at @s unless entity @e[predicate=lifeform_analyzer:is_hostile,distance=..20] run function lifeform_analyzer:src/unpoint_compass_mainhand
execute as @a[predicate=lifeform_analyzer:offhand_lfa,predicate=lifeform_analyzer:offhand_lfa_pointing] at @s unless entity @e[predicate=lifeform_analyzer:is_hostile,distance=..20] run function lifeform_analyzer:src/unpoint_compass_offhand

execute at @s run execute if entity @e[predicate=lifeform_analyzer:is_hostile,distance=..20] run title @s actionbar [{"selector": "@e[predicate=lifeform_analyzer:is_hostile,distance=..20,limit=1,sort=nearest]", "color":"dark_red"}, {"text": " detected nearby!", "color": "white"}]
execute as @a[predicate=lifeform_analyzer:mainhand_lfa] at @s if entity @e[predicate=lifeform_analyzer:is_hostile,distance=..20] run function lifeform_analyzer:src/point_compass_mainhand
execute as @a[predicate=lifeform_analyzer:offhand_lfa] at @s if entity @e[predicate=lifeform_analyzer:is_hostile,distance=..20] run function lifeform_analyzer:src/point_compass_offhand
