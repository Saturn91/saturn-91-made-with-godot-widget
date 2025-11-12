class_name MadeWidthGodotWidget extends Control

const INDEX_URL = "https://raw.githubusercontent.com/Saturn91/Saturn91MadeWithGodotData/refs/heads/master/_index.cfg"

var index_data: Dictionary = {}
var http_request: HTTPRequest

var selected_link: Dictionary

@onready var texture_rect: TextureRect = $Preview
@onready var developer_label: Label = $Developer

func _ready() -> void:
	fetch_index_data()

func fetch_index_data() -> void:
	# Create HTTPRequest node
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_index_request_completed)
	
	# Make the request
	var error = http_request.request(INDEX_URL)
	if error != OK:
		push_error("MadeWithGodotWidget: Failed to start HTTP request: " + str(error))

func _on_index_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("MadeWithGodotWidget: HTTP request failed with result: " + str(result))
		return
	
	if response_code != 200:
		push_error("MadeWithGodotWidget: HTTP request returned code: " + str(response_code))
		return
	
	# Parse the config file (skip first line which is a comment)
	var config = ConfigFile.new()
	var content = body.get_string_from_utf8()
	var lines = content.split("\n")
	if lines.size() > 0:
		lines.remove_at(0)  # Remove the first line (comment)
	content = "\n".join(lines)
	var error = config.parse(content)
	
	if error != OK:
		push_error("MadeWithGodotWidget: Failed to parse config file: " + str(error))
		return
	
	# Convert to dictionary
	index_data = {}
	for section in config.get_sections():
		index_data[section] = {}
		for key in config.get_section_keys(section):
			index_data[section][key] = config.get_value(section, key)
	
	# Fetch a random file based on file_count
	if index_data.has("index") and index_data["index"].has("file_count"):
		var file_count = int(index_data["index"]["file_count"])
		var random_index = randi() % file_count + 1  # Random between 1 and file_count
		var file_number = random_index - 1  # n = index - 1
		var file_url = "https://raw.githubusercontent.com/Saturn91/Saturn91MadeWithGodotData/refs/heads/master/file_%d.cfg" % file_number
		
		fetch_file(file_url)
	else:
		push_error("MadeWithGodotWidget: Could not find file_count in index data")
		http_request.queue_free()

func fetch_file(url: String) -> void:
	# Reuse the existing HTTPRequest
	http_request.request_completed.disconnect(_on_index_request_completed)
	http_request.request_completed.connect(_on_file_request_completed)
	
	var error = http_request.request(url)
	if error != OK:
		push_error("MadeWithGodotWidget: Failed to start HTTP request for file: " + str(error))
		http_request.queue_free()

func _on_file_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("MadeWithGodotWidget: HTTP request failed with result: " + str(result))
		http_request.queue_free()
		return
	
	if response_code != 200:
		push_error("MadeWithGodotWidget: HTTP request returned code: " + str(response_code))
		http_request.queue_free()
		return
	
	# Parse the config file (skip first line which is a comment)
	var config = ConfigFile.new()
	var content = body.get_string_from_utf8()
	var lines = (content.split("\n") as Array[String]).filter(func(line): return !line.begins_with("#"))
	content = "\n".join(lines)
	var error = config.parse(content)
	
	if error != OK:
		push_error("MadeWithGodotWidget: Failed to parse config file: " + str(error))
		http_request.queue_free()
		return
	
	# Convert to dictionary
	var file_data: Dictionary = {}
	for section in config.get_sections():
		file_data[section] = {}
		for key in config.get_section_keys(section):
			file_data[section][key] = config.get_value(section, key)
	
	# Pick a random link from the data
	var link_keys = file_data.keys()
	if link_keys.size() > 0:
		var random_link_key = link_keys[randi() % link_keys.size()]
		selected_link = file_data[random_link_key]
		
		# Set developer label
		if developer_label and selected_link.has("developer"):
			developer_label.text = selected_link["developer"]
		
		# Fetch the preview image
		if selected_link.has("preview_image"):
			fetch_image(selected_link["preview_image"])
		else:
			http_request.queue_free()
	else:
		push_error("MadeWithGodotWidget: No links found in file data")
		http_request.queue_free()

func fetch_image(url: String) -> void:
	# Reuse the existing HTTPRequest
	http_request.request_completed.disconnect(_on_file_request_completed)
	http_request.request_completed.connect(_on_image_request_completed)
	
	var error = http_request.request(url)
	if error != OK:
		push_error("MadeWithGodotWidget: Failed to start HTTP request for image: " + str(error))
		http_request.queue_free()

func _on_image_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("MadeWithGodotWidget: Image request failed with result: " + str(result))
		http_request.queue_free()
		return
	
	if response_code != 200:
		push_error("MadeWithGodotWidget: Image request returned code: " + str(response_code))
		http_request.queue_free()
		return
	
	# Create image from buffer
	var image = Image.new()
	var error: Error
	
	# Try to load as different formats
	if body.slice(0, 3) == PackedByteArray([0xFF, 0xD8, 0xFF]):
		error = image.load_jpg_from_buffer(body)
	elif body.slice(0, 8) == PackedByteArray([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]):
		error = image.load_png_from_buffer(body)
	else:
		# Try PNG first, then JPG
		error = image.load_png_from_buffer(body)
		if error != OK:
			error = image.load_jpg_from_buffer(body)
	
	if error != OK:
		push_error("MadeWithGodotWidget: Failed to load image: " + str(error))
		http_request.queue_free()
		return
	
	# Create texture and set it
	var texture = ImageTexture.create_from_image(image)
	if texture_rect:
		texture_rect.texture = texture
	
	# Clean up
	http_request.queue_free()
