extends Control

@onready var wave_label: Label = $CanvasLayer/TopPanel/HBoxContainer/Wave
@onready var score_label: Label = $CanvasLayer/TopPanel/HBoxContainer/Score
@onready var health_label: Label = $CanvasLayer/TopPanel/HBoxContainer/Health

@onready var reset_panel: PanelContainer = $CanvasLayer/ResetPanel
@onready var dead_score_label: Label = $CanvasLayer/ResetPanel/VBoxContainer/DeadScoreLabel
@onready var dead_wave_label: Label = $CanvasLayer/ResetPanel/VBoxContainer/DeadWaveLabel

var game

func _ready():
	game = get_parent()
	game.get_node("Player").connect("dead",show_reset)
	reset_panel.hide()
	
func _process(_delta):
	wave_label.text = "Wave: " + str(game.wave)
	score_label.text = "Score: " + str(game.killed)
	health_label.text = "Health: " + str(game.get_node("Player").health)

func show_reset() -> void:
	reset_panel.show()
	dead_score_label.text = "Your score is: " + str(game.killed)
	dead_wave_label.text = "You survived till wave:  " + str(game.wave)


func _on_restart_button_pressed():
	game.restart_game()
	reset_panel.hide()
