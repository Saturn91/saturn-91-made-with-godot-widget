class_name MadeWidthGodotWidget extends Control

@onready var texture_rect: TextureRect = $Preview
@onready var developer_label: Label = $Developer

func _ready() -> void:
	update_ui()

func _process(delta: float) -> void:
	# Check if new data is available
	if MadeWithGodotSource.has_new_data:
		update_ui()
		MadeWithGodotSource.acknowledge_new_data()

func update_ui() -> void:
	if MadeWithGodotSource.data:
		# Update developer label
		if developer_label:
			developer_label.text = MadeWithGodotSource.data.developer
		
		# Update texture rect
		if texture_rect and MadeWithGodotSource.data.preview_image:
			texture_rect.texture = MadeWithGodotSource.data.preview_image
