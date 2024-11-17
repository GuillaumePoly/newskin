extends Node

var correct_number: String = "0488258094"
var current_entered_number: String = ""

var all_buttons: Array[String] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "#", "*"]
var phone_dict: Dictionary

var game_won: bool = false

var button_0: MeshInstance3D
var button_1: MeshInstance3D
var button_2: MeshInstance3D
var button_3: MeshInstance3D
var button_4: MeshInstance3D
var button_5: MeshInstance3D
var button_6: MeshInstance3D
var button_7: MeshInstance3D
var button_8: MeshInstance3D
var button_9: MeshInstance3D
var button_asterix: MeshInstance3D
var button_star: MeshInstance3D


const button_position_dict = {
	"0": Vector3(6.465, 1.728, -3.502),
	"1": Vector3(6.994, 3.987, -1.318),
	"2": Vector3(6.978, 4.03, -3.542),
	"3": Vector3(7, 4.08, -5.65),
	"4": Vector3(7.678, 6.22, -1.307),
	"5": Vector3(7.651, 6.256, -3.453),
	"6": Vector3(7.689, 6.349, -5.529),
	"7": Vector3(8.378, 8.313, -1.336),
	"8": Vector3(8.379, 8.321, -3.478),
	"9": Vector3(8.406, 8.351, -5.513),
	"#": Vector3(6.46, 1.797, -5.618),
	"*": Vector3(6.42, 1.518, -1.259),
}

func _ready() -> void:
	button_0 = $Button00
	button_1 = $Button01
	button_2 = $Button02
	button_3 = $Button03
	button_4 = $Button04
	button_5 = $Button05
	button_6 = $Button06
	button_7 = $Button07
	button_8 = $Button08
	button_9 = $Button09
	button_asterix = $"Button#"
	button_star = $"Button*"

	phone_dict = {
		"0": ["0", button_0],
		"1": ["1", button_1],
		"2": ["2", button_2],
		"3": ["3", button_3],
		"4": ["4", button_4],
		"5": ["5", button_5],
		"6": ["6", button_6],
		"7": ["7", button_7],
		"8": ["8", button_8],
		"9": ["9", button_9],
		"#": ["#", button_asterix],
		"*": ["*", button_star],
			}
			
	$"../PhoneBipingAndPickupPlayer".finished.connect(_on_phone_pick_up)


func handle_button_pressed(button_pressed_label: String):
	var corresponding_button_pressed_label: String = phone_dict[button_pressed_label][0]
	if game_won:
		return
	$"../ButtonPressPlayer".play()
	if corresponding_button_pressed_label == "#" or corresponding_button_pressed_label == "*":
		return
	## If correct
	if corresponding_button_pressed_label == correct_number[current_entered_number.length()]:
		print("\nGood button!")
		current_entered_number += corresponding_button_pressed_label
		print("\nCurrent Sequence: ", current_entered_number)
		pressed_good_button()
	else:
		print('\nWrong Button!')
		pressed_wrong_button()


func pressed_good_button():
	# Check if game over
	if current_entered_number == correct_number:
		print("You won the game!!")
<<<<<<< Updated upstream
		#switcher.next_scene
=======
		game_won = true
		$"../PhoneBipingAndPickupPlayer".play()
		#LevelSwitcher.next_level(5.0, Vector3.UP * .38)
>>>>>>> Stashed changes
	else:
		shuffle_numbers()


func pressed_wrong_button():
	# Reset current sequence
	current_entered_number = ""
	reset_to_initial_position()


func shuffle_numbers():
	## Shuffle Buttons
	all_buttons.shuffle()

	# Create a mapping between shuffled button labels and their original keys
	var button_array: Array = []
	for button in all_buttons:
		button_array.append(phone_dict[button])
	
	phone_dict.clear()
	
	phone_dict = {
		"0": button_array[0],
		"1": button_array[1],
		"2": button_array[2],
		"3": button_array[3],
		"4": button_array[4],
		"5": button_array[5],
		"6": button_array[6],
		"7": button_array[7],
		"8": button_array[8],
		"9": button_array[9],
		"#": button_array[10],
		"*": button_array[11],
	}
	
	move_phone_dict_button()

func reset_to_initial_position():
	print("\nReset to initial Position")
	
	phone_dict.clear()
	
	phone_dict = {
		"0": ["0", button_0],
		"1": ["1", button_1],
		"2": ["2", button_2],
		"3": ["3", button_3],
		"4": ["4", button_4],
		"5": ["5", button_5],
		"6": ["6", button_6],
		"7": ["7", button_7],
		"8": ["8", button_8],
		"9": ["9", button_9],
		"#": ["#", button_asterix],
		"*": ["*", button_star],
			}
	
	move_phone_dict_button()


func move_phone_dict_button():
	for key in phone_dict:
		phone_dict[key][1].global_position = button_position_dict[key]

func _on_phone_pick_up():
	$"../ColorRect".visible = true
