# Conways-Game-of-Life---The-Musical
A Godot project that uses Conway's Game of Life to generate terrible, terrible music.

This project takes the basic rules of "Conway's Game of Life" and adds an extra ruleset over the top.
If a cell is alive, it is eligable to play a note on the piano. The note it plays is determined by how many "living" neighbours it has.
any amount of neighbours between 1 and 7 lets the cell try to play a note, but it won't always get to play it.
There are 3 audio emitters in the project, so if one is already playing a note, it will try the second, then the third.

That ruleset on it's own provided pretty boring stuff, so I added a timer that will create "filler" by playing the last note picked on either the first or second audio player.

Currently, this application only supports C-Major, but at some point I'll start adding more scales along with the ability to select them.

# How to use
1. Either build from source or download the release
2. Run it in godot or run CGOL.exe
3. Use your mouse to draw on the white square
4. Press play

# Other buttons
* The "Step" button allows you to go through it "step-by-step" instead of automatically playing.
* The "Stop" button emails me your browser history. Not really, it just stops the game.
* The "Reset" button clears the play area.
* The "Speed" parameter changes how quickly the simulation runs - smaller numbers = faster sim.

# Credits
* Most of the stuff: Rhyffraff
* Godot: The people that done made the Godot engine
* Piano: A guy on Reddit by the name of u/SingleInfinity - Thanks, you saved me heaps of time.
