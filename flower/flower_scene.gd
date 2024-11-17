extends Node3D

@onready var flower: Flower = $Flower

func _on_flower_petal_fallen() -> void:
	if flower.petal_amount == flower.petals_fallen.size():
		LevelSwitcher.next_level(5.0, Vector3.UP * .38)
