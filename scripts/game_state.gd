extends Node
## Remembers things while the player moves between screens.
##
## This script is registered as an autoload named "GameState"
## (Project Settings > Globals), so Godot loads it once at startup
## and every screen can read and change the same values,
## for example: GameState.cat_a = some_cat

## The two cats the player picked. Empty until a pair is chosen.
var cat_a: Dictionary = {}
var cat_b: Dictionary = {}

## Result of the last date: "Great", "Okay" or "Failed". Empty before any date.
var last_outcome: String = ""

## How the last date ended: each cat's mood (0 to 100) and the player's score.
var mood_a: int = 0
var mood_b: int = 0
var score: int = 0

## Rewards the player has collected so far.
var treats: int = 0
var xp: int = 0
