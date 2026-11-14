extends Node
## Remembers things while the player moves between screens.
##
## This script is registered as an autoload named "GameState"
## (Project Settings > Globals), so Godot loads it once at startup
## and every screen can read and change the same values,
## for example: GameState.cat_a = some_cat

## A cat "loved" a date if its mood is at least this high when the date ends.
## The date screen and the result screen both use this number.
const LOVED_IT_MOOD := 60

## How much XP the player needs for each new level.
const XP_PER_LEVEL := 100

## How long two cats need a break from each other after a failed date,
## in seconds. 600 seconds = 10 minutes. Use a small number while testing.
const COOLDOWN_SECONDS := 600

## The two cats the player picked. Empty until a pair is chosen.
var cat_a: Dictionary = {}
var cat_b: Dictionary = {}

## Result of the last date: "Great", "Okay" or "Failed". Empty before any date.
var last_outcome: String = ""

## How the last date ended: each cat's mood (0 to 100) and the player's score.
var mood_a: int = 0
var mood_b: int = 0
var score: int = 0

## Pairs that are on a break after a failed date.
## Each entry is "pair name: the moment the break ends", for example
## "Biscuit+Mochi": 734.5 (seconds since the game was started).
var cooldown_ends: Dictionary = {}

## Rewards the player has collected so far.
var treats: int = 0
var xp: int = 0


## The player's level: level 1 at the start, one more for every 100 XP.
func get_level() -> int:
	# Dividing two whole numbers drops the remainder: 250 / 100 gives 2.
	@warning_ignore("integer_division")
	return 1 + xp / XP_PER_LEVEL


## Starts the break for a pair after a failed date.
func start_cooldown(cat_a: Dictionary, cat_b: Dictionary) -> void:
	cooldown_ends[_pair_key(cat_a, cat_b)] = _seconds_now() + COOLDOWN_SECONDS


## How many seconds of break a pair still has. 0 means they can be matched.
func cooldown_seconds_left(cat_a: Dictionary, cat_b: Dictionary) -> int:
	var key: String = _pair_key(cat_a, cat_b)
	if not cooldown_ends.has(key):
		return 0
	return maxi(0, ceili(cooldown_ends[key] - _seconds_now()))


## Writes a number of seconds as minutes and seconds: 572 becomes "9:32".
func format_time(seconds: int) -> String:
	@warning_ignore("integer_division")
	return "%d:%02d" % [seconds / 60, seconds % 60]


## One name for a pair, the same whichever cat was picked first:
## Mochi + Biscuit and Biscuit + Mochi both give "Biscuit+Mochi".
func _pair_key(cat_a: Dictionary, cat_b: Dictionary) -> String:
	var names: Array = [cat_a["name"], cat_b["name"]]
	names.sort()
	return "%s+%s" % [names[0], names[1]]


## Seconds since the game was started.
func _seconds_now() -> float:
	return Time.get_ticks_msec() / 1000.0
