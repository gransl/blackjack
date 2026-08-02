class_name BlackjackHand
extends Hand

var rank_values = {
	Card.Rank.TWO: 2,
	Card.Rank.THREE: 3,
	Card.Rank.FOUR: 4,
	Card.Rank.FIVE: 5,
	Card.Rank.SIX: 6,
	Card.Rank.SEVEN: 7,
	Card.Rank.EIGHT: 8,
	Card.Rank.NINE: 9, 
	Card.Rank.TEN: 10,
	Card.Rank.JACK: 10,
	Card.Rank.QUEEN: 10,
	Card.Rank.KING: 10,
	Card.Rank.ACE: 11
}

func get_total(debug: bool = false) -> int:
	var total = 0
	var ace_count = 0
	if (debug):
		print()
		print("DEBUG MODE:")
	for card in cards:
		if debug:
			print("SUM CARDS")
		total += rank_values.get(card.rank)
		if card.rank == Card.Rank.ACE:
			ace_count += 1
		if debug:
			print("Card: ", Card.Rank.keys()[card.rank], " of ", Card.Suit.keys()[card.suit])
			print("Total: " + str(total))
			print("Ace Count: " + str(ace_count))
	if (debug):
			print("ACE ADJUSTMENT")
	while total > 21 and ace_count > 0:
		total -= 10
		ace_count -= 1
		if debug:
			print("Total: " + str(total))
			print("Ace Count: " + str(ace_count))
	if debug:
		print("Final Total: " + str(total))
		print()
	return total
