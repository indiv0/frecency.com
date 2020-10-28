+++
title = "Announcing: Colonize!"
date = 2015-02-01
+++
After a long hiatus on my video game development projects, I've
decided to resume my progress by starting a new game -
[*Colonize*](https://github.com/indiv0/colonize) (working
title).

The game is mostly meant to be a learning experience in roguelike
development for a friend and I, and to serve as a base for a project
we can later build upon.

Our vision for the game is a game similar to Dwarf Fortress - i.e.
a roguelike in real-time and with little user interation in the direct
actions of the characters.

Here's a breakdown of the basic idea for the game:

* Written in [Rust](http://rust-lang.org)
* Using the [tcod-rs](https://github.com/tomassedovic/tcod-rs)
  bindings for the [libtcod](https://github.com/libtcod/libtcod)
  library.
* Using the [Piston](https://github.com/PistonDevelopers/piston) game
  engine and libraries for the back-end.
* ASCII graphics to start, possibly move to a tileset
  later.
* 3D voxel map, procedurally generated, displayed in a top-down
  (i.e. birds-eye) style view (similar to dwarf-fortress) with the
  ability to scroll between layers in the Y-axis.
* Large world, loaded as cubic chunks

Currently, I've written a backend for Piston to work with libtcod,
and called it [tcod\_window](https://github.com/indiv0/tcod_window).

Using tcod\_window, following [some](http://jaredonline.svbtle.com/roguelike-tutorial-table-of-contents)
tutorials, and taking inspiration from [similar projects](https://github.com/GBGamer/roguelike-rs)
I've managed to get a basic menu rendering and an initial chunk to
load.

The current progress is summarized in this [webm](https://zippy.gfycat.com/ImpassionedOblongFlyingfox.webm).

**Update (2020-10-27):** Fixed broken libtcod link.
