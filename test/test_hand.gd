extends GdUnitTestSuite

var test_hand: Hand

func before_test() -> void:
	test_hand = Hand.new()

func test_init_hand_empty() -> void:
	assert_array(test_hand.cards).is_empty()

func test_add_card() -> void:
	var test_card: Card = Card.new(Card.Suit.HEARTS, Card.Rank.TWO)
	test_hand.add_card(test_card)
	assert_array(test_hand.cards).has_size(1)
	assert_array(test_hand.cards).contains([test_card])
