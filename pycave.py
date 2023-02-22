import random
import numpy as np

def display_cave(matrix):
    for i in range(matrix.shape[0]):
        for j in range(matrix.shape[1]):
            if matrix[i][j] == BIOME1:
                char = "#"
            elif matrix[i][j] == BIOME2:
                char = ":"
            else:
                char = "."
            print(char, end='')
        print()




shape = (42,42)
BIOME1 = 0
BIOME2 = 1
BIOME3 = 2
fill_prob1 = 0.3
fill_prob2 = 0.6

new_map = np.ones(shape)
for i in range(shape[0]):
    for j in range(shape[1]):
        choice = random.uniform(0, 1)
        if choice < fill_prob1:
            new_map[i][j] = BIOME1
        elif choice < fill_prob2:
            new_map[i][j] =  BIOME2
        else:
            new_map[i][j] = BIOME3

# run for 6 generations
generations = 6
for generation in range(generations):
    for i in range(shape[0]):
        for j in range(shape[1]):
            # get the number of walls 1 away from each index
            submap = new_map[max(i-1, 0):min(i+2, new_map.shape[0]),max(j-1, 0):min(j+2, new_map.shape[1])]
            wallcount_1away = len(np.where(submap.flatten() == BIOME1)[0])

            # get the number of walls 2 away from each index
            submap = new_map[max(i-2, 0):min(i+3, new_map.shape[0]),max(j-2, 0):min(j+3, new_map.shape[1])]
            wallcount_2away = len(np.where(submap.flatten() == BIOME1)[0])

            # this consolidates walls
            # for first five generations build a scaffolding of walls
            if generation < 5:
                # if looking 1 away in all directions you see 5 or more walls
                # consolidate this point into a wall, if that doesnt happpen
                # and if looking 2 away in all directions you see less than
                # 7 walls, add a wall, this consolidates and adds walls
                if wallcount_1away >= 5 or wallcount_2away <= 7:
                    new_map[i][j] = BIOME1
                else:
                    new_map[i][j] = BIOME2
            # this consolidates open space, fills in standalone walls,
            # after generation 5 consolidate walls and increase walking space
            # if there are more than 5 walls nearby make that point a wall,
            # otherwise add a floor
            else:
                # if looking 1 away in all direction you see 5 walls
                # consolidate this point into a wall,
                if wallcount_1away >= 5:
                    new_map[i][j] = BIOME1
                else:
                    new_map[i][j] = BIOME2

display_cave(new_map)
