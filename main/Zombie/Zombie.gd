extends Area2D

signal killed

@onready var damage_timer = $DamageTimer

# editable zombie stats

@export_group("Zombie Stats")
@export var health: float = 25
@export var speed: float = 300
@export_group("")

var velocity: Vector2 = Vector2(1,0)

var game = null
var player = null

func _ready():
	# get the references for game scene (parent) and the player which is a child of the game scene
	game = get_parent()
	player = game.get_node("Player")

func _physics_process(delta):
	# just make sure the zombie doesn't try to crash the game
	if (game.player != null):
		# distance check to prevent zombies literally going inside the player and make them stop when the player is dead
		if (global_position.distance_to(game.player.global_position) > 25 && !game.player.is_dead):
			# you obviously chase your target while looking at them
			look_at(game.player.global_position)
			
			# run towards the brain
			global_position += velocity.rotated(rotation) * speed * delta

func take_damage(damage: float) -> void:
	health -= damage
	
	if (health <= 0):
		# emit the IM DEAD signal
		killed.emit()
		
		queue_free()

func _on_area_entered(area):
	# make sure we are touching the player
	if (area.is_in_group("Player")):
		# the timer is so the damage keeps being dealt if the zombie touches the player, not just once 
		if (damage_timer.time_left <= 0):
			damage_timer.start()
			
			# take damage at first contact and make sure the player isn't dead
			if (!player.is_dead):
				player.take_damage(10)

func _on_area_exited(area):
	# check if it's actually the player who we are not touching
	if (area.is_in_group("Player")):
		damage_timer.stop()

func _on_damage_timer_timeout():
	if (!player.is_dead):
		player.take_damage(10)
