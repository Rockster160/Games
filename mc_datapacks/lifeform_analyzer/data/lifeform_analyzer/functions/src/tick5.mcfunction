execute as @a[predicate=lifeform_analyzer:mainhand_lfa] run function lifeform_analyzer:src/check_hostiles
execute as @a[predicate=lifeform_analyzer:offhand_lfa] run function lifeform_analyzer:src/check_hostiles

schedule function lifeform_analyzer:src/tick5 5t
