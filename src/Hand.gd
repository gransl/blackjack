class_name Hand
extends RefCounted

var cards: Array[Card]

func add_card(card: Card) -> void:
	cards.append(card)
