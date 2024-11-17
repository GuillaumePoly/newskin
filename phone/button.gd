extends CollisionObject3D

@onready var parent: Node3D = get_parent() 
@onready var phone_logic: Node = get_tree().root.get_node("PhoneScene/PhoneLogic")

var is_hovered: bool = false
var original_position: Vector3
var tween: Tween 

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	original_position = parent.global_position


func _on_mouse_entered():
	is_hovered = true


func _on_mouse_exited():
	is_hovered = false


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if is_hovered:
					phone_logic.handle_button_pressed(str(parent.name)[-1])
					play_press_animation()


func play_press_animation():
	if tween:
		tween.kill()
	
	tween = get_tree().create_tween()

	#add_child(tween)  # Add it to the current node

	var pressed_position = original_position
	pressed_position.x -= 2  # Adjust the x-offset for the "press" effect

	# Animate the button moving to the pressed position and back to original
	tween.tween_property(parent, "global_position", pressed_position, 0.1)
	tween.tween_property(parent, "global_position", original_position, 0.1)

	tween.play()  # Start the animation
