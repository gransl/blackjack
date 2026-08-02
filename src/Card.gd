class_name Card
extends RefCounted

enum Rank {TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT,
 			NINE, TEN, JACK, QUEEN, KING, ACE}

enum Suit {CLUBS, DIAMONDS, HEARTS, SPADES}

var rank: Rank
var suit: Suit

# Called when the node enters the scene tree for the first time.
func _init(s: Suit, r: Rank) -> void:
	suit = s
	rank = r
