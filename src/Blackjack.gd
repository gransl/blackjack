class_name Blackjack
extends Node

# Node References
@onready var dealer_hand_container: HBoxContainer = $GameLayer/GameTable/DealerArea/CenterContainer/DealerHand
@onready var player_hand_container: HBoxContainer = $GameLayer/GameTable/PlayerArea/CenterContainer/PlayerHand
@onready var dealer_total_label: Label = $GameLayer/GameTable/DealerArea/DealerTotal
@onready var player_total_label: Label = $GameLayer/GameTable/PlayerArea/PlayerTotal
@onready var game_message: Label = $GameLayer/GameTable/GameMessageMarginContainer/GameMessage
@onready var hit_button: Button = $GameLayer/GameTable/ActionBarMarginContainer/ActionBar/Hit
@onready var stand_button: Button = $GameLayer/GameTable/ActionBarMarginContainer/ActionBar/Stand
@onready var settings_button: Button = $GameLayer/SettingsButtonMarginContainer/SettingsButton
@onready var settings_layer: CanvasLayer = $SettingsLayer
@onready var settings_menu: Control = $SettingsLayer/SettingsMenu
@onready var game_layer: CanvasLayer = $GameLayer

# Game State
var deck: Deck
var player_hand: BlackjackHand
var dealer_hand: BlackjackHand
var dealer_hidden_card: TextureRect
var is_game_over: bool
enum WinReason {BUST, SCORE, BLACKJACK}

func _input(event: InputEvent) -> void:
	if settings_menu.visible:
		return
	if event.is_action_pressed("Hit"):
		if not is_game_over:
			_on_hit_pressed()
	elif event.is_action_pressed("Stand"):
		if not is_game_over:
			_on_stand_pressed()
	elif event.is_action_pressed("New Game"):
		_on_new_game_pressed()
	elif event.is_action_pressed("Settings"):
		print("GAME saw Settings, menu visible: ", settings_menu.visible)
		_on_settings_button_pressed()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_new_round()
		
func start_new_round() -> void:
	is_game_over = false
	game_message.text = ""
	enable_play_buttons()
	
	# clear old cards
	for child in player_hand_container.get_children():
		child.queue_free()
	for child in dealer_hand_container.get_children():
		child.queue_free()
	
	# Deal Hands
	deck = Deck.new()
	player_hand = BlackjackHand.new()
	dealer_hand = BlackjackHand.new()
	for i in range(2):
		player_hand.add_card(deck.deal_card())
		dealer_hand.add_card(deck.deal_card())
		
	# display face up cards cards
	display_card(CardAssets.get_texture_path(player_hand.cards[0]), player_hand_container)
	display_card(CardAssets.get_texture_path(dealer_hand.cards[0]), dealer_hand_container)
	display_card(CardAssets.get_texture_path(player_hand.cards[1]), player_hand_container)
	
	# create dealer face down card (maybe display_card should return container?)
	dealer_hidden_card = TextureRect.new()
	dealer_hidden_card.texture = load(CardAssets.card_back_path())
	dealer_hand_container.add_child(dealer_hidden_card)
	
	#debug statements	
	for card in dealer_hand.cards:
		print("Dealer Card: ", Card.Rank.keys()[card.rank], " of ", Card.Suit.keys()[card.suit])
	print("Dealer Total: ", dealer_hand.get_total())
	for card in player_hand.cards:
		print("Player Card: ", Card.Rank.keys()[card.rank], " of ", Card.Suit.keys()[card.suit])
	print("Player Total: ", player_hand.get_total())
	print("")
	
	# check blackjack win conditions
	if (player_hand.get_total() == 21):
		if (dealer_hand.get_total() == 21):
			display_dealer_hidden_card()
			push()
		else:
			player_wins(WinReason.BLACKJACK)
	elif (dealer_hand.get_total() == 21):
		display_dealer_hidden_card()
		dealer_wins(WinReason.BLACKJACK)
	 
	# Update Labels
	if (!is_game_over):
		player_total_label.text = "Player Total: %s" % str(player_hand.get_total())
		dealer_total_label.text = "Dealer Total: " 

# TODO: revisit if this should be in this class...
func display_card(path:String, container: HBoxContainer) -> void:
	# create a TextureRect
	var card_texture = TextureRect.new()
	# load the correct texture
	card_texture.texture = load(path)
	# update texture properties
	#card_texture.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	# card_texture.custom_minimum_size = Vector2(110, 110)
	# add it to the container
	container.add_child(card_texture)

func _on_hit_pressed() -> void:
	# Deal Card
	var new_card = deck.deal_card()
	player_hand.add_card(new_card)
	
	# TODO: Show new card in UI
	display_card(CardAssets.get_texture_path(new_card), player_hand_container)
	
	# Check player score
	if (is_bust(player_hand.get_total())): # Over 21, Bust
		dealer_wins(WinReason.BUST)
	elif (player_hand.get_total() == 21): # Exactly 21, player auto-stands
		_on_stand_pressed()
	else: # Under 21, play continues 
		player_total_label.text = "Player Total: %s" % str(player_hand.get_total())

func _on_stand_pressed() -> void:
	disable_play_buttons()
	
	# Display dealers current hand
	display_dealer_hidden_card()
	dealer_total_label.text = "Dealer Score: " + str(dealer_hand.get_total())
	
	while (dealer_hand.get_total() < 17):
		print("Deck size: ", deck.cards.size())
		var new_card = deck.deal_card()
		dealer_hand.add_card(new_card)
		display_card(CardAssets.get_texture_path(new_card), dealer_hand_container)
		dealer_total_label.text = "Dealer Total: " + str(dealer_hand.get_total())
		
	# Game over, declare winner
	if (is_bust(dealer_hand.get_total())): # Dealer busts, Player wins
		player_wins(WinReason.BUST)
	elif (dealer_hand.get_total() < player_hand.get_total()): # Player wins by high score
		player_wins(WinReason.SCORE)
	elif (dealer_hand.get_total() > player_hand.get_total()): # Dealer wins by high score
		dealer_wins(WinReason.SCORE)
	else: # Push
		push()
	
func is_bust(hand_total: int) -> bool:
	return hand_total > 21

func player_wins(reason: WinReason) -> void:
	game_over()
	game_message.text = "PLAYER WINS!"
	if reason == WinReason.BUST:
		dealer_total_label.text = "Dealer Total: " + str(dealer_hand.get_total()) + " | BUST!"
		player_total_label.text = "Player Total: " + str(player_hand.get_total())
	elif reason == WinReason.SCORE:
		dealer_total_label.text = "Dealer Total: " + str(dealer_hand.get_total())
		player_total_label.text = "Player Total: " + str(player_hand.get_total())
	elif reason == WinReason.BLACKJACK: 
		dealer_total_label.text = "Dealer Total: "
		player_total_label.text = "Player Total: " + str(player_hand.get_total()) + " | BLACKJACK!"
	else:
		game_message.text = "Error: Unknown Player Win Condition!"
		

func dealer_wins(reason: WinReason) -> void:
	game_over()
	game_message.text = "DEALER WINS!"
	if reason == WinReason.BUST:
		dealer_total_label.text = "Dealer Total: "
		player_total_label.text = "Player Total: " + str(player_hand.get_total()) + " | BUST!"
	elif reason == WinReason.SCORE:
		dealer_total_label.text = "Dealer Total: " + str(dealer_hand.get_total())
		player_total_label.text = "Player Total: " + str(player_hand.get_total())
	elif reason == WinReason.BLACKJACK: 
		dealer_total_label.text = "Dealer Total: " + str(dealer_hand.get_total()) + " | BLACKJACK!"
		player_total_label.text = "Player Total: " + str(player_hand.get_total())
	else:
		game_message.text = "Error: Unknown Dealer Win Condition!"
	
func push(is_blackjack: bool = false):
	game_over()
	game_message.text = "PUSH!"
	if is_blackjack:
		dealer_total_label.text = "Dealer Total: BLACKJACK!"
		player_total_label.text = "Player Total: BLACKJACK!"
	else:
		dealer_total_label.text = "Dealer Total: " + str(dealer_hand.get_total())
		player_total_label.text = "Player Total: " + str(player_hand.get_total())

func display_dealer_hidden_card() -> void:
	dealer_hidden_card.texture = load(CardAssets.get_texture_path(dealer_hand.cards[1]))

func game_over() -> void:
	is_game_over = true;
	disable_play_buttons()

func disable_play_buttons() -> void:
	hit_button.disabled = true
	stand_button.disabled = true

func enable_play_buttons() -> void:
	hit_button.disabled = false
	stand_button.disabled = false
	
func _on_new_game_pressed() -> void:
	start_new_round()

func _on_settings_button_pressed() -> void:
	print("opening menu, visible was: ", settings_menu.visible)
	settings_menu.visible = true
