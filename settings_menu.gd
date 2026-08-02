extends Control

signal menu_closed

@onready var hit_button: Button = $Panel/VBoxContainer/HitRow/HitButton
@onready var stand_button: Button = $Panel/VBoxContainer/StandRow/StandButton
@onready var new_game_button: Button = $Panel/VBoxContainer/NewGameRow/NewGameButton
@onready var close_button: Button = $Panel/VBoxContainer/CloseButtonMarginContainer/CloseButton
@onready var settings_menu: Control = $"."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hit_button.grab_focus()
	reset_button_text("Hit")
	reset_button_text("Stand")
	reset_button_text("New Game")

# Rebinding actions
var action_to_rebind: String = ""

func _on_hit_button_pressed() -> void:
	action_to_rebind = "Hit"
	hit_button.text = "Press a key..."
	hit_button.modulate = Color.YELLOW

func _on_stand_button_pressed() -> void:
	action_to_rebind = "Stand"
	stand_button.text = "Press a key..."
	stand_button.modulate = Color.YELLOW

func _on_new_game_button_pressed() -> void:
	action_to_rebind = "New Game"
	new_game_button.text = "Press a key..."
	new_game_button.modulate = Color.YELLOW
	
func _input(event: InputEvent) -> void:
	if action_to_rebind != "" and event is InputEventKey:
		InputMap.action_erase_events(action_to_rebind)
		InputMap.action_add_event(action_to_rebind, event)
		reset_button_text(action_to_rebind)
		action_to_rebind = ""
		get_viewport().set_input_as_handled()

func reset_button_text(action:String) -> void:
	if (action == "Hit"):
		var hit_button_events = InputMap.action_get_events("Hit")
		if hit_button_events.size() > 0:
			hit_button.text = hit_button_events[0].as_text().trim_suffix(" - Physical")
		else:
			hit_button.text = "n/a"
		hit_button.modulate = Color.WHITE
	elif (action == "Stand"):
		var stand_button_events = InputMap.action_get_events("Stand")
		if stand_button_events.size() > 0:
			stand_button.text = stand_button_events[0].as_text().trim_suffix(" - Physical")
		else:
			stand_button.text = "n/a"
		stand_button.modulate = Color.WHITE
	elif (action == "New Game"):
		var new_game_button_events = InputMap.action_get_events("New Game")
		if new_game_button_events.size() > 0:
			new_game_button.text = new_game_button_events[0].as_text().trim_suffix(" - Physical")
		else:
			new_game_button.text = "n/a"
		new_game_button.modulate = Color.WHITE

func _on_close_button_pressed() -> void:
	visible = false
	menu_closed.emit()
