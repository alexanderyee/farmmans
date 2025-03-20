extends AudioStreamPlayer2D

# Constants
# there should be a .wav file(s) for each of these actions in assets/sfx/player
const filename_prefixes = ["till"]

var player_action_sfx_dict = {}
var regex = RegEx.new()
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	preload_player_sfx()
	
	stream = AudioStreamPolyphonic.new()
	max_polyphony = 32
	
func play_player_action(action: String) -> void:
	if !playing:
		play()
	
	var action_string = action.to_lower()
	var polyphonic := get_stream_playback()
	if player_action_sfx_dict.has(action_string):
		var action_sfx_list: Array = player_action_sfx_dict[action_string]
		var action_sfx_filepath: String = action_sfx_list[rng.randi_range(0, action_sfx_list.size() - 1)]
		var sfx_to_play = load(action_sfx_filepath)
		polyphonic.play_stream(sfx_to_play)
		
func preload_player_sfx() -> void:
	var filepath := "res://assets/sfx/player/"
	var dir := DirAccess.open(filepath)
	var matching_files := []
	
	if dir:
		var files = dir.get_files()
		for file in files:
			for filename_prefix in filename_prefixes:
				var pattern = filename_prefix + ".*\\.wav$"
				regex.compile(pattern)
				var result = regex.search(file)
				if result:
					if filename_prefix in player_action_sfx_dict:
						player_action_sfx_dict[filename_prefix].append(filepath + file)
					else:
						player_action_sfx_dict[filename_prefix] = [filepath + file]
		print("playersfx loaded")
	else:
		push_error("Path: " + filepath + " not found! Not able to load playersfx")
