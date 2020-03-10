# Quantum Tetris GoDot Code
## Introduction
Welcome to Quantum Tetris! We built the project using Godot v3.1.1. To look at the project in GoDot, import the project.godot file with the GoDot console. 

## General 

### GoDot and the Heroku Server

Most of the game's functionality can be found in the various scripts and scene files (see below). However, we were unable to implement a quantum simulator in GoDot, so the game connects to a server to compute probabilities and determine base states for superposition pieces. Make sure you are able to access the internet when you play the game to access quantum features!

### General Notes

Moving pieces are children of the main scene, while locked pieces are set as tiles in a GridMap.

The probabilites of pieces being one state or another are precomputed when the piece is created.  This information information is stored in a set of global lists along with similar information for H and X gates. 

## Structure
GoDot is split into scenes which describe the objects in each segment of the game. Scene files hold information like the position and material properties of an object. 

Each scene file comes with an attached script (.gd extension).

Most of our code is in the main.gd script. It is split into the following sections:
* Creating the queue of pieces with additional queues for associated information (handle_backlist, handle_powerups_backlist, random_piece, applyH, applyX).
* Creating pieces without relying on the server for information in case pieces are not generated quickly enough (abort). 
* Starting, ending and resetting the game (ready, new_game, game_over, reset_button, clear_lists). 
* Handling input and processing each frame (\_unhandled_input, \process_new_action, etc.).
* Connecting to and recieving information from the server for Quantum probabilities (various).
* Passing information for piece movement and locking (various). 
* Graphics and animations (various).
* Visualizing piece probabilities (visualize, draw_red_line, draw_probabilities, etc.).
* Managing the tutorial (various).

Certain functions to move and lock pieces into the GridMap can be found in Tetromino.gd and GridMap.gd. Several tutorial functions, along with the tutorial text, can be found in tutorial.gd.


## Credits
Our game code and graphics are based on TETRIS3000! You can find the original game here.

[Downloads](https://github.com/adrienmalin/TETRIS3000/releases)

[Play in browser](https://adrienmalin.github.io/TETRIS3000/web/TETRIS3000.html) (Firefox recommanded)

