
extends CollisionObject3D

@onready var parent: Node3D = get_parent() 
@onready var phone_logic: Node = get_tree().root.get_node("PhoneScene/PhoneLogic")

var is_hovered: bool = false

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


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
