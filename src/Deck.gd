class_name Deck
extends RefCounted

var cards: Array[Card]

# Creates a deck and shuffles it
func _init() -> void:
	for 	suit in Card.Suit.values():
		for rank in Card.Rank.values():
			cards.append(Card.new(suit,rank))
	cards.shuffle()

func is_empty() -> bool:
	return cards.is_empty()
	
func deal_card() -> Card:
	return cards.pop_back()
