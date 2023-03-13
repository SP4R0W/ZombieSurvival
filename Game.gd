extends Node2D

@onready var zombie_scene: PackedScene = preload("res://Zombie/Zombie.tscn")
@onready var zombie_spawn_location: PathFollow2D = $ZombiePath/SpawnLocation

var player = null

var wave: int = 1

var zombies_max: int = 10
var zombies_spawned: int = 0
var zombies_present: int = 0

var killed: int = 0

func restart_game():
	# reset the values
	wave = 1
	killed = 0
	
	# remove all zombies from previous game session if they exist
	for node in get_children():
		if (node.is_in_group("Zombie")):
			node.queue_free()
	
	# revive the player
	get_node("Player").spawn_player()
	

func spawn_zombie() -> void:
	# don't spawn more zombies in a wave than you're supposed to
	if (zombies_spawned == zombies_max):
		return
	
	zombies_spawned += 1
	zombies_present += 1
	
	# create a zombie 
	var zombie = zombie_scene.instantiate()
	
	# give the zombie a random position
	zombie_spawn_location.progress_ratio = randf()
	
	zombie.global_position = zombie_spawn_location.global_position
	zombie.connect("killed",killed_zombie)
	
	add_child(zombie)

func next_wave():
	# make the next wave a bit harder
	wave += 1
	zombies_max += 5
	$Spawn.wait_time *= 0.95

func killed_zombie():
	killed += 1
	zombies_present -= 1
	
	# give the player a short break when the wave has been cleared out then start another
	if (zombies_present == 0 && zombies_spawned == zombies_max):
		await get_tree().create_timer(2.5).timeout
		
		next_wave()
