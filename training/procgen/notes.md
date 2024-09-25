# Procedural Generation / Dungeon Walker

Create a "walker" that can meander around an area and carve out rooms as it goes.
The walker should not be confined to any specific space and can roam any direction.

Have definable parameters for customizing how large a dungeon will come out.
  - room size
  - walk length
  - turn frequency
  - room count

To do this we need some way to track which coordinates are spaces and which are walls.
Let's just track the spaces and then fill the rest with walls later.

Start the walker and have it track it's coordinate.
Blow up the starting room by creating a rectangle of desired size centered on the walker and add all of those points to your store.

Have the walker choose a random cardinal direction and walk that way. You can normalize the walk length by randomizing using a bell curve.
We can also allow the walker to change directions to make turns and generate more maze-like tunnels.

Upon arrival, explode the next room. Add this to your list as well.

After the max rooms have been hit, take your store of coordinates and find the least and greatest X and Y values and create a grid around it.
