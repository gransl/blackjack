extends GdUnitTestSuite

var test_deck: Deck

func before_test() -> void:
	test_deck = Deck.new()
	
func test_init_creates_deck() -> void:
	assert_object(test_deck.cards).is_not_null()

func test_init_creates_52_card_deck() -> void:
	assert_array(test_deck.cards).has_size(52)
	
func test_deal_card() -> void:
	var test_dealt_card: Card = test_deck.deal_card()
	assert_object(test_dealt_card).is_not_null()
	assert_array(test_deck.cards).has_size(51)

func test_is_empty_method() -> void:
	assert_bool(test_deck.is_empty()).is_false()
	for i in range(52):
		test_deck.deal_card()
	assert_bool(test_deck.is_empty()).is_true()
	
func test_this_one_fails() -> void:
	assert_array(test_deck).is_empty()
