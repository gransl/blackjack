class_name CardAssets
extends RefCounted

static var suit_names = {
	Card.Suit.CLUBS: "clubs",
	Card.Suit.DIAMONDS: "diamonds",
	Card.Suit.HEARTS: "hearts",
	Card.Suit.SPADES: "spades"
}

static var rank_names = {
	Card.Rank.TWO: "02",
	Card.Rank.THREE: "03",
	Card.Rank.FOUR: "04",
	Card.Rank.FIVE: "05",
	Card.Rank.SIX: "06",
	Card.Rank.SEVEN: "07",
	Card.Rank.EIGHT: "08",
	Card.Rank.NINE: "09",
	Card.Rank.TEN: "10",
	Card.Rank.JACK: "J",
	Card.Rank.QUEEN: "Q",
	Card.Rank.KING: "K",
	Card.Rank.ACE: "A"
}

static func get_texture_path(card: Card) -> String:
	var path: String = "res://assets/cards/largeCards/card_%s_%s.png" % [suit_names.get(card.suit), rank_names.get(card.rank)]
	# debug
	# print(path)
	return path

static func card_back_path() -> String:
	return "res://assets/cards/largeCards/card_back.png"

static func empty_card_path() -> String:
	return "res://assets/cards/largeCards/card_empty.png"
