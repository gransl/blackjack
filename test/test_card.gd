extends GdUnitTestSuite

func test_init_assigns_suit_and_rank() -> void:
	var card : Card = Card.new(Card.Suit.SPADES, Card.Rank.ACE)
	assert_int(card.suit).is_equal(Card.Suit.SPADES)
	assert_int(card.rank).is_equal(Card.Rank.ACE)
