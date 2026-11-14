class_name Compatibility
extends RefCounted
## Works out how well two cats fit together.
##
## The rule: start at 3 hearts, add 1 for every trait or like the cats share,
## take away 1 for every clash, and keep the result between 0 and 5.
## Other scripts use it with: Compatibility.check(cat_a, cat_b)

const START_HEARTS := 3
const MAX_HEARTS := 5

## Pairs of opposite traits. If one cat has the first trait and the other cat
## has the second (or the other way round), that counts as one clash.
const CLASHES := [
	["Lazy", "Energetic"],
	["Shy", "Chatty"],
]


## Compares two cats and returns a Dictionary with three entries:
##   "hearts":  a number from 0 to 5
##   "shared":  a list of texts, for example ["Foodie", "Likes fish"]
##   "clashes": a list of texts, for example ["Lazy vs Energetic"]
static func check(cat_a: Dictionary, cat_b: Dictionary) -> Dictionary:
	var shared: Array = []
	for trait_name in cat_a["traits"]:
		if cat_b["traits"].has(trait_name):
			shared.append(trait_name)
	for like in cat_a["likes"]:
		if cat_b["likes"].has(like):
			shared.append("Likes " + like)

	var clashes: Array = []
	for pair in CLASHES:
		var first: String = pair[0]
		var second: String = pair[1]
		# The text always names cat A's trait first.
		if cat_a["traits"].has(first) and cat_b["traits"].has(second):
			clashes.append("%s vs %s" % [first, second])
		elif cat_a["traits"].has(second) and cat_b["traits"].has(first):
			clashes.append("%s vs %s" % [second, first])

	# clampi() keeps the number inside the range 0 to MAX_HEARTS.
	var hearts: int = clampi(START_HEARTS + shared.size() - clashes.size(), 0, MAX_HEARTS)

	return {"hearts": hearts, "shared": shared, "clashes": clashes}
