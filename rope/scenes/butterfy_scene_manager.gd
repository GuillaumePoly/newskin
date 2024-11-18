extends Node3D

class_name butterfy_scene_manager
static var counter: int
static var endpos: Vector3


static func removeButt():
	if counter > 1:
		counter -= 1
	else:
		LevelSwitcher.next_level(5.0,endpos)
