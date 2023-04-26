extends Area2D

signal dead

# saving a reference of bullet scene for easy duplicating
@onready var bullet_scene: PackedScene = preload("res://Bullet/Bullet.tscn")

@onready var sprite: AnimatedSprite2D = $AnimatedSprite
@onready var firerate: Timer = $Firerate
@onready var bullet_pos: Marker2D = $BulletPosition

# editable stats
@export_group("Player Stats")
@export var health: float = 100
@export var speed: float = 200
@export_group("")

const damage_pistol = 15
const damage_smg = 7.5

# the only weapons avaiable
enum weapons {
	PISTOL,
	SMG
}

var game = null
var damage: float = damage_pistol
var weapon: weapons = weapons.PISTOL
var velocity: Vector2i = Vector2i.ZERO

var is_dead: bool = false

func _enter_tree():
	# add a reference to game scene and let the game scene know the player is here
	game = get_parent()
	game.player = self

	spawn_player()
	
func _exit_tree():
	# player is gone, so is the reference for him in the game scene
	get_parent().player = null
	
func spawn_player() -> void:
	show()
	
	# ressurect the player
	is_dead = false
	health = 100
	weapon = weapons.PISTOL

	global_position = game.get_node("PlayerSpawn").global_position

func draw_weapon() -> void:
	if (weapon == weapons.PISTOL):
		damage = damage_pistol
		firerate.wait_time = 0.5
		sprite.animation = "pistol"
	else:
		damage = damage_smg
		firerate.wait_time = 0.2
		sprite.animation = "smg"	
		
func get_input() -> void:
	if (Input.is_action_just_pressed("pistol")):
		weapon = weapons.PISTOL
	elif (Input.is_action_just_pressed("smg")):
		weapon = weapons.SMG
	
	if (Input.is_action_pressed("shoot")):
		# don't try to shoot more often than you're supposed to
		if (firerate.time_left <= 0):
			firerate.start()
			
			# create the bullet and add it to the right spot in the game scene
			var bullet = bullet_scene.instantiate()
			game.get_node("Bullets").add_child(bullet)
			
			# set the bullet's damage and position
			bullet.damage = damage
			bullet.global_position = bullet_pos.global_position	
		
func move_player(delta: float) -> void:
	# fun movement code which looks complicated
	velocity.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	velocity.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))

	# look at whereever player's mouse is facing
	look_at(get_global_mouse_position())
	
	# move the player
	global_position += velocity * speed * delta	

func boundaries_check() -> void:
	# simple checks preventing player from escaping the visible area
	
	if (global_position.x < 0):
		global_position.x = 0
	elif (global_position.x > 1280):
		global_position.x = 1280
	
	if (global_position.y < 0):
		global_position.y = 0
	elif (global_position.y > 720):
		global_position.y = 720
		
func take_damage(zombie_damage: float) -> void:
	health -= zombie_damage
	
	if (health <= 0):
		# oh no, i'm dead!
		dead.emit()
		
		is_dead = true
		hide()

func _physics_process(delta):
	# this is where all the magic happens
	
	if (!is_dead):
		draw_weapon()
		get_input()
		
		move_player(delta)
		
		boundaries_check()

