class_name MadeWithGodotSource extends Node

@export var debug: bool = false
@export var data_source = "https://raw.githubusercontent.com/Saturn91/Saturn91MadeWithGodotData"

static var success: bool = false
static var error: String = ""
static var data: MadeWithGodotDTO
static var has_new_data: bool = false

const FALLBACK_RESOURCE_PATH = "res://addons/made_with_godot/resources/made_with_godot_fall_back.tres"

var http_request: HTTPRequest
var index_data: Dictionary = {}
var is_fetching: bool = false

func _ready() -> void:
	load_fallback_data()
	fetch_data()

func fetch_data() -> void:
	if is_fetching:
		if debug:
			print("MadeWithGodotDataSource: Already fetching data")
		return
	
	is_fetching = true
	success = false
	error = ""
	
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_index_request_completed)
	
	if debug:
		print("MadeWithGodotDataSource: Starting data fetch")
	
	var request_error = http_request.request(data_source + "/refs/heads/master/_index.cfg")
	if request_error != OK:
		error = "Failed to start HTTP request: " + str(request_error)
		is_fetching = false
		http_request.queue_free()
		if debug:
			print("MadeWithGodotDataSource: " + error)

func _on_index_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		error = "HTTP request failed with result: " + str(result)
		is_fetching = false
		http_request.queue_free()
		if debug:
			print("MadeWithGodotDataSource: " + error)
		return
	
	if response_code != 200:
		error = "HTTP request returned code: " + str(response_code)
		is_fetching = false
		http_request.queue_free()
		if debug:
			print("MadeWithGodotDataSource: " + error)
		return
	
	var config = ConfigFile.new()
	var content = body.get_string_from_utf8()
	var lines = content.split("\n")
	if lines.size() > 0:
		lines.remove_at(0)  # Remove the first line (comment)
	content = "\n".join(lines)
	var parse_error = config.parse(content)
	
	if parse_error != OK:
		error = "Failed to parse config file: " + str(parse_error)
		is_fetching = false
		http_request.queue_free()
		if debug:
			print("MadeWithGodotDataSource: " + error)
		return
	
	index_data = {}
	for section in config.get_sections():
		index_data[section] = {}
		for key in config.get_section_keys(section):
			index_data[section][key] = config.get_value(section, key)
	
	if debug:
		print("MadeWithGodotDataSource: Index data loaded successfully")
	
	if index_data.has("index") and index_data["index"].has("file_count"):
		var file_count = int(index_data["index"]["file_count"])
		var random_index = randi() % file_count + 1  # Random between 1 and file_count
		var file_number = random_index - 1  # n = index - 1
		var file_url = data_source + "/refs/heads/master/file_%d.cfg" % file_number
		
		fetch_file(file_url)
	else:
		error = "Could not find file_count in index data"
		is_fetching = false
		http_request.queue_free()
		if debug:
			print("MadeWithGodotDataSource: " + error)

func fetch_file(url: String) -> void:
	http_request.request_completed.disconnect(_on_index_request_completed)
	http_request.request_completed.connect(_on_file_request_completed)
	
	var request_error = http_request.request(url)
	if request_error != OK:
		error = "Failed to start HTTP request for file: " + str(request_error)
		is_fetching = false
		http_request.queue_free()
		if debug:
			print("MadeWithGodotDataSource: " + error)

func _on_file_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		error = "File request failed with result: " + str(result)
		is_fetching = false
		http_request.queue_free()
		if debug:
			print("MadeWithGodotDataSource: " + error)
		return
	
	if response_code != 200:
		error = "File request returned code: " + str(response_code)
		is_fetching = false
		http_request.queue_free()
		if debug:
			print("MadeWithGodotDataSource: " + error)
		return
	
	# Parse the config file (skip first line which is a comment)
	var config = ConfigFile.new()
	var content = body.get_string_from_utf8()
	var lines = (content.split("\n") as Array[String]).filter(func(line): return !line.begins_with("#"))
	content = "\n".join(lines)
	var parse_error = config.parse(content)
	
	if parse_error != OK:
		error = "Failed to parse file config: " + str(parse_error)
		is_fetching = false
		http_request.queue_free()
		if debug:
			print("MadeWithGodotDataSource: " + error)
		return
	
	var file_data: Dictionary = {}
	for section in config.get_sections():
		file_data[section] = {}
		for key in config.get_section_keys(section):
			file_data[section][key] = config.get_value(section, key)
	
	# Pick a random link from the data
	var link_keys = file_data.keys()
	if link_keys.size() > 0:
		var random_link_key = link_keys[randi() % link_keys.size()]
		var selected_link = file_data[random_link_key]
		
		data = MadeWithGodotDTO.new()
		data.url = selected_link.get("url", "")
		data.developer = selected_link.get("developer", "")
		data.dev_link = selected_link.get("dev_link", "")
		
		# Fetch the preview image
		if selected_link.has("preview_image"):
			fetch_image(selected_link["preview_image"])
		else:
			success = true
			has_new_data = true
			is_fetching = false
			http_request.queue_free()
			if debug:
				print("MadeWithGodotDataSource: Data loaded successfully (no image)")
	else:
		error = "No links found in file data"
		is_fetching = false
		http_request.queue_free()
		if debug:
			print("MadeWithGodotDataSource: " + error)

func fetch_image(url: String) -> void:
	http_request.request_completed.disconnect(_on_file_request_completed)
	http_request.request_completed.connect(_on_image_request_completed)
	
	var request_error = http_request.request(url)
	if request_error != OK:
		error = "Failed to start HTTP request for image: " + str(request_error)
		is_fetching = false
		http_request.queue_free()
		if debug:
			print("MadeWithGodotDataSource: " + error)

func _on_image_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		error = "Image request failed with result: " + str(result)
		is_fetching = false
		http_request.queue_free()
		if debug:
			print("MadeWithGodotDataSource: " + error)
		return
	
	if response_code != 200:
		error = "Image request returned code: " + str(response_code)
		is_fetching = false
		http_request.queue_free()
		if debug:
			print("MadeWithGodotDataSource: " + error)
		return
	
	var image = Image.new()
	var load_error: Error
	
	# Try to load as different formats
	if body.slice(0, 3) == PackedByteArray([0xFF, 0xD8, 0xFF]):
		load_error = image.load_jpg_from_buffer(body)
	elif body.slice(0, 8) == PackedByteArray([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]):
		load_error = image.load_png_from_buffer(body)
	else:
		# Try PNG first, then JPG
		load_error = image.load_png_from_buffer(body)
		if load_error != OK:
			load_error = image.load_jpg_from_buffer(body)
	
	if load_error != OK:
		error = "Failed to load image: " + str(load_error)
		is_fetching = false
		http_request.queue_free()
		if debug:
			print("MadeWithGodotDataSource: " + error)
		return
	
	var texture = ImageTexture.create_from_image(image)
	data.preview_image = texture
	
	success = true
	has_new_data = true
	is_fetching = false
	http_request.queue_free()
	
	if debug:
		print("MadeWithGodotDataSource: Data loaded successfully with image")

func load_fallback_data() -> void:
	var fallback_resource = load(FALLBACK_RESOURCE_PATH)
	if fallback_resource and fallback_resource is MadeWithGodotDTO:
		data = fallback_resource.duplicate()
		if debug:
			print("MadeWithGodotDataSource: Fallback data loaded")
	else:
		data = MadeWithGodotDTO.new()
		if debug:
			print("MadeWithGodotDataSource: Created empty fallback data")

func retry_fetch() -> void:
	if debug:
		print("MadeWithGodotDataSource: Retrying data fetch")
	fetch_data()

static func acknowledge_new_data() -> void:
	has_new_data = false
