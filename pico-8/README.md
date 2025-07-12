So far I've got:

 * Robots chase the nearest (player|ghost)
 * Robots face left or right depending on which way they're moving.
 * When robots collide, they die and leave a pile of junk.
   * Likewise when a robot collides with junk.
 * The player can move orthogonally.
 * The robots can move orthogonally or diagonally.
 * The player can teleport.
 * Teleporting also involves time travel.
   * A ghost appears at the player's most recent start position.
   * Start position: either at the start of the game or after teleporting.
 * When all the robots are gone, the player wins, and does a little dance.
 * When a robot reaches the player, the player loses, and leaves a corpse.
 * When a robot reaches a ghost, the ghost vanishes.
 * Score displayed: # of robots destroyed.
 * When all the robots are gone, start a new level.
   * More robots.
 * Fix the logic that prevents the player from teleporting onto a robot.
 * Make the corpse more visible (animation on death).
 * Show an animation for teleporting.

Open questions:

 * Should the robots reset when time resets after a teleport?
   * Experimented on branch experiment/robots-reset
   * Answer seems to be no; it's frustrating having work lost on teleport.
