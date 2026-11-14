class_name DateQuestions
extends RefCounted
## Builds the questions for one date.
##
## In every question one cat has forgotten something about the other cat,
## and the player has to pick the right answer out of three.
## Other scripts use it with: DateQuestions.make_questions(cat_a, cat_b)

## Extra wrong answers that no cat has, so there are always enough to pick from.
const EXTRA_LIKES := ["cardboard boxes", "sunny windows", "long walks"]
const EXTRA_TRAITS := ["Brave", "Messy", "Curious"]


## Returns four questions: two about each cat, taking turns.
## Each question is a Dictionary with:
##   "about":   "a" or "b" - which cat the question is about
##   "text":    the question shown to the player
##   "options": three answers in random order
##   "correct": the right answer
static func make_questions(cat_a: Dictionary, cat_b: Dictionary) -> Array:
	var about_b: Array = _questions_about(cat_b, cat_a, "b")
	var about_a: Array = _questions_about(cat_a, cat_b, "a")
	return [about_b[0], about_a[0], about_b[1], about_a[1]]


## Makes the two questions about one cat: one on a like, one on a trait.
static func _questions_about(cat: Dictionary, forgetful_cat: Dictionary, about: String) -> Array:
	var like_question: Dictionary = _make_question(
		cat, about, "likes", EXTRA_LIKES,
		"%s forgot what %s likes. Remind %s:" % [forgetful_cat["name"], cat["name"], forgetful_cat["name"]]
	)
	var trait_question: Dictionary = _make_question(
		cat, about, "traits", EXTRA_TRAITS,
		"%s forgot: what is %s like? Remind %s:" % [forgetful_cat["name"], cat["name"], forgetful_cat["name"]]
	)
	var questions: Array = [like_question, trait_question]
	questions.shuffle()  # random order, so the like question is not always first
	return questions


## Makes one question. "key" is "likes" or "traits" - which list of the cat to use.
static func _make_question(cat: Dictionary, about: String, key: String, extras: Array, text: String) -> Dictionary:
	# The right answer: one random entry from the cat's own list.
	var correct: String = cat[key].pick_random()

	# The wrong answers: everything the OTHER cats have that this cat does not,
	# plus the extras. Two of them are picked at random.
	var wrong_pool: Array = extras.duplicate()
	for other_cat in CatData.CATS:
		for item in other_cat[key]:
			if not cat[key].has(item) and not wrong_pool.has(item):
				wrong_pool.append(item)
	wrong_pool.shuffle()

	var options: Array = [correct, wrong_pool[0], wrong_pool[1]]
	options.shuffle()

	return {"about": about, "text": text, "options": options, "correct": correct}
