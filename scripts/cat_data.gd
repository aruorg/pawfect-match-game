class_name CatData
extends RefCounted
## The list of all cats in the game.
##
## Each cat is a Dictionary (a set of "key: value" pairs).
## The values are placeholders taken from the design canvas.
## "faces" says which way the cat looks in its picture ("left" or "right"),
## so screens can mirror it when it should look the other way.
## Other scripts read the list with: CatData.CATS

const CATS := [
	{
		"name": "Mochi",
		"age": 14,
		"personality": "Calm, loves long naps",
		"traits": ["Lazy", "Foodie", "Shy"],
		"likes": ["fish", "quiet places"],
		"willingness": 70,
		"image": "res://assets/cats/mochi.png",
		"faces": "left",
	},
	{
		"name": "Biscuit",
		"age": 11,
		"personality": "Playful show-off",
		"traits": ["Energetic", "Chatty", "Foodie"],
		"likes": ["fish", "loud music"],
		"willingness": 40,
		"image": "res://assets/cats/biscuit.png",
		"faces": "left",
	},
	{
		"name": "Pepper",
		"age": 9,
		"personality": "Grumpy but sweet",
		"traits": ["Shy", "Tidy", "Bookish"],
		"likes": ["books", "rainy days"],
		"willingness": 55,
		"image": "res://assets/cats/pepper.png",
		"faces": "right",
	},
]
