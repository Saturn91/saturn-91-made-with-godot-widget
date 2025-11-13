class_name MadeWidthGodotWidget extends CenterContainer

@onready var texture_rect: TextureRect = $HBoxContainer/Preview
@onready var developer_label: Label = $HBoxContainer/Preview/MarginContainer/HBoxContainer/developer
@onready var qrcode: QRCodeRect = $HBoxContainer/QRCodeRect

var original_dev_text := ""

func _ready() -> void:
	original_dev_text = developer_label.text
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
			developer_label.text = original_dev_text.replace("#dev", MadeWithGodotSource.data.developer)

		# Update texture rect
		if texture_rect and MadeWithGodotSource.data.preview_image:
			texture_rect.texture = MadeWithGodotSource.data.preview_image

		# Update QR code to use the url field
		if qrcode and MadeWithGodotSource.data.url:
	
			# Reset QR code state to force update
			if qrcode.has_method("_clear_cache"):
				qrcode._clear_cache()
			qrcode.data = "" # Clear first to force change
			qrcode.data = MadeWithGodotSource.data.url
			if qrcode.has_method("_update_qr with"):
				qrcode._update_qr()
