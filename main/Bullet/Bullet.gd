extends Sprite2D
class_name Bullet

var velocity: Vector2 = Vector2(1,0)
var speed: float = 1000
var look_once: bool = true

var damage: float = 0

func _physics_process(delta):
	# shoot whereever the player was looking at
	if (look_once):
		look_once = false
		look_at(get_global_mouse_position())
	
	# move the bullet
	global_position += velocity.rotated(rotation) * speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	# remove the bullet if it goes off-screen
	queue_free()

func _on_area_2d_area_entered(area):
	# take damage if it's a zombie
	if (area.is_in_group("Zombie")):
		area.take_damage(damage)
	
	queue_free()
