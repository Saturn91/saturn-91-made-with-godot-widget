class_name MadeWidthGodotWidget extends CenterContainer

@onready var texture_rect: TextureRect = $PanelContainer/HBoxContainer/Preview
@onready var developer_label: Label = $PanelContainer/HBoxContainer/Preview/MarginContainer/HBoxContainer/developer
@onready var qrcode: QRCodeRect = $PanelContainer/HBoxContainer/QRCodeRect
@onready var loadingBg: ColorRect = $PanelContainer/LoadingBg
@onready var loadingLabel: Label = $PanelContainer/LoadingLabel

var original_dev_text := ""

# Animation state for loading dots
var _loading_anim_time := 0.0
var _loading_dot_state := 0
const _LOADING_DOTS = [".", "..", "..."]
var _loading_base_text := ""

func _ready() -> void:
	original_dev_text = developer_label.text
	_loading_base_text = loadingLabel.text.strip_edges()
	update_ui()

func _process(delta: float) -> void:
	if MadeWithGodotSource.is_fetching:
		if not loadingBg.visible:
			loadingBg.show()
			loadingLabel.show()
		# Animate loading dots
		_loading_anim_time += delta
		if _loading_anim_time >= 0.5:
			_loading_anim_time = 0.0
			_loading_dot_state = (_loading_dot_state + 1) % _LOADING_DOTS.size()
			loadingLabel.text = _loading_base_text + _LOADING_DOTS[_loading_dot_state]
	else:
		if loadingBg.visible:
			loadingBg.hide()
			loadingLabel.hide()
		# Reset animation state
		_loading_anim_time = 0.0
		_loading_dot_state = 0
		loadingLabel.text = _loading_base_text + _LOADING_DOTS[0]

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
