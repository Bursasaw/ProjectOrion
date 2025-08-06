extends Node
class_name UITheme

# UI Theme System - Centralized theming for consistent UI design
# Provides colors, fonts, styles, and animations for all UI components

signal theme_changed(new_theme_name: String)
signal color_scheme_updated(scheme_name: String)

# Theme Configuration
var current_theme: String = "default"
var current_color_scheme: String = "standard"

# Color Schemes
var color_schemes: Dictionary = {
	"standard": {
		"primary": Color("#2C3E50"),      # Dark blue-gray
		"secondary": Color("#34495E"),    # Lighter blue-gray
		"accent": Color("#3498DB"),       # Bright blue
		"success": Color("#27AE60"),      # Green
		"warning": Color("#F39C12"),      # Orange
		"error": Color("#E74C3C"),        # Red
		"background": Color("#ECF0F1"),   # Light gray
		"surface": Color("#FFFFFF"),      # White
		"text_primary": Color("#2C3E50"), # Dark text
		"text_secondary": Color("#7F8C8D"), # Gray text
		"text_inverse": Color("#FFFFFF"), # White text
		"border": Color("#BDC3C7"),       # Light border
		"shadow": Color("#000000", 0.1),  # Subtle shadow
		"highlight": Color("#3498DB", 0.2), # Highlight overlay
		"disabled": Color("#BDC3C7"),     # Disabled state
		"ai_aggressive": Color("#E74C3C"), # AI aggressive state
		"ai_defensive": Color("#27AE60"),  # AI defensive state
		"ai_calm": Color("#3498DB"),      # AI calm state
		"ai_angry": Color("#F39C12"),     # AI angry state
		"ai_desperate": Color("#8E44AD"), # AI desperate state
		"ai_confident": Color("#F1C40F")  # AI confident state
	},
	"dark": {
		"primary": Color("#1A1A1A"),      # Dark background
		"secondary": Color("#2D2D2D"),    # Darker surface
		"accent": Color("#4A9EFF"),       # Bright blue
		"success": Color("#2ECC71"),      # Green
		"warning": Color("#F39C12"),      # Orange
		"error": Color("#E74C3C"),        # Red
		"background": Color("#0F0F0F"),   # Very dark
		"surface": Color("#1A1A1A"),      # Dark surface
		"text_primary": Color("#FFFFFF"), # White text
		"text_secondary": Color("#B0B0B0"), # Light gray text
		"text_inverse": Color("#000000"), # Black text
		"border": Color("#404040"),       # Dark border
		"shadow": Color("#000000", 0.3),  # Dark shadow
		"highlight": Color("#4A9EFF", 0.2), # Highlight overlay
		"disabled": Color("#404040"),     # Disabled state
		"ai_aggressive": Color("#E74C3C"), # AI aggressive state
		"ai_defensive": Color("#27AE60"),  # AI defensive state
		"ai_calm": Color("#3498DB"),      # AI calm state
		"ai_angry": Color("#F39C12"),     # AI angry state
		"ai_desperate": Color("#8E44AD"), # AI desperate state
		"ai_confident": Color("#F1C40F")  # AI confident state
	},
	"high_contrast": {
		"primary": Color("#000000"),      # Black
		"secondary": Color("#FFFFFF"),    # White
		"accent": Color("#FFFF00"),       # Bright yellow
		"success": Color("#00FF00"),      # Bright green
		"warning": Color("#FF8000"),      # Bright orange
		"error": Color("#FF0000"),        # Bright red
		"background": Color("#FFFFFF"),   # White background
		"surface": Color("#F0F0F0"),      # Light surface
		"text_primary": Color("#000000"), # Black text
		"text_secondary": Color("#333333"), # Dark gray text
		"text_inverse": Color("#FFFFFF"), # White text
		"border": Color("#000000"),       # Black border
		"shadow": Color("#000000", 0.5),  # Strong shadow
		"highlight": Color("#FFFF00", 0.3), # Highlight overlay
		"disabled": Color("#CCCCCC"),     # Disabled state
		"ai_aggressive": Color("#FF0000"), # AI aggressive state
		"ai_defensive": Color("#00FF00"),  # AI defensive state
		"ai_calm": Color("#0000FF"),      # AI calm state
		"ai_angry": Color("#FF8000"),     # AI angry state
		"ai_desperate": Color("#8000FF"), # AI desperate state
		"ai_confident": Color("#FFFF00")  # AI confident state
	}
}

# Typography
var font_sizes: Dictionary = {
	"tiny": 10,
	"small": 12,
	"medium": 16,
	"large": 20,
	"huge": 24,
	"title": 32,
	"header": 28
}

var font_weights: Dictionary = {
	"light": 300,
	"normal": 400,
	"medium": 500,
	"bold": 700,
	"heavy": 900
}

# Spacing and Layout
var spacing: Dictionary = {
	"xs": 4,
	"sm": 8,
	"md": 16,
	"lg": 24,
	"xl": 32,
	"xxl": 48
}

var border_radius: Dictionary = {
	"none": 0,
	"sm": 4,
	"md": 8,
	"lg": 12,
	"xl": 16,
	"full": 999
}

# Animation Durations
var animation_durations: Dictionary = {
	"instant": 0.0,
	"fast": 0.1,
	"normal": 0.2,
	"slow": 0.3,
	"very_slow": 0.5
}

# Animation Easing
var easing_functions: Dictionary = {
	"linear": Tween.EASE_IN_OUT,
	"ease_in": Tween.EASE_IN,
	"ease_out": Tween.EASE_OUT,
	"ease_in_out": Tween.EASE_IN_OUT,
	"bounce": Tween.TRANS_BOUNCE,
	"elastic": Tween.TRANS_ELASTIC
}

func _ready():
	"""Initialize the UI theme system"""
	print("UITheme: Initialized with theme: %s" % current_theme)
	load_theme_settings()

func get_color(color_name: String) -> Color:
	"""Get a color from the current color scheme"""
	if color_schemes.has(current_color_scheme):
		var scheme = color_schemes[current_color_scheme]
		if scheme.has(color_name):
			return scheme[color_name]
	
	# Fallback to standard scheme
	if color_schemes.has("standard"):
		var standard = color_schemes["standard"]
		if standard.has(color_name):
			return standard[color_name]
	
	# Ultimate fallback
	return Color.WHITE

func get_font_size(size_name: String) -> int:
	"""Get a font size"""
	return font_sizes.get(size_name, 16)

func get_font_weight(weight_name: String) -> int:
	"""Get a font weight"""
	return font_weights.get(weight_name, 400)

func get_spacing(spacing_name: String) -> int:
	"""Get a spacing value"""
	return spacing.get(spacing_name, 16)

func get_border_radius(radius_name: String) -> int:
	"""Get a border radius value"""
	return border_radius.get(radius_name, 8)

func get_animation_duration(duration_name: String) -> float:
	"""Get an animation duration"""
	return animation_durations.get(duration_name, 0.2)

func get_easing_function(easing_name: String) -> int:
	"""Get an easing function"""
	return easing_functions.get(easing_name, Tween.EASE_IN_OUT)

func set_color_scheme(scheme_name: String):
	"""Set the current color scheme"""
	if color_schemes.has(scheme_name):
		current_color_scheme = scheme_name
		color_scheme_updated.emit(scheme_name)
		print("UITheme: Color scheme changed to %s" % scheme_name)
	else:
		print("UITheme: Warning - Unknown color scheme: %s" % scheme_name)

func set_theme(theme_name: String):
	"""Set the current theme"""
	current_theme = theme_name
	theme_changed.emit(theme_name)
	print("UITheme: Theme changed to %s" % theme_name)

func get_ai_emotion_color(emotion: String) -> Color:
	"""Get the color for an AI emotional state"""
	var color_name = "ai_" + emotion.to_lower()
	return get_color(color_name)

func create_button_style() -> StyleBoxFlat:
	"""Create a standard button style"""
	var style = StyleBoxFlat.new()
	style.bg_color = get_color("primary")
	style.border_color = get_color("border")
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = get_border_radius("md")
	style.corner_radius_top_right = get_border_radius("md")
	style.corner_radius_bottom_left = get_border_radius("md")
	style.corner_radius_bottom_right = get_border_radius("md")
	style.shadow_color = get_color("shadow")
	style.shadow_size = 2
	style.shadow_offset = Vector2(0, 2)
	return style

func create_panel_style() -> StyleBoxFlat:
	"""Create a standard panel style"""
	var style = StyleBoxFlat.new()
	style.bg_color = get_color("surface")
	style.border_color = get_color("border")
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = get_border_radius("md")
	style.corner_radius_top_right = get_border_radius("md")
	style.corner_radius_bottom_left = get_border_radius("md")
	style.corner_radius_bottom_right = get_border_radius("md")
	style.shadow_color = get_color("shadow")
	style.shadow_size = 4
	style.shadow_offset = Vector2(0, 4)
	return style

func create_input_style() -> StyleBoxFlat:
	"""Create a standard input field style"""
	var style = StyleBoxFlat.new()
	style.bg_color = get_color("background")
	style.border_color = get_color("border")
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = get_border_radius("sm")
	style.corner_radius_top_right = get_border_radius("sm")
	style.corner_radius_bottom_left = get_border_radius("sm")
	style.corner_radius_bottom_right = get_border_radius("sm")
	return style

func create_highlight_style() -> StyleBoxFlat:
	"""Create a highlight style for selections"""
	var style = StyleBoxFlat.new()
	style.bg_color = get_color("highlight")
	style.corner_radius_top_left = get_border_radius("sm")
	style.corner_radius_top_right = get_border_radius("sm")
	style.corner_radius_bottom_left = get_border_radius("sm")
	style.corner_radius_bottom_right = get_border_radius("sm")
	return style

func apply_theme_to_control(control: Control):
	"""Apply the current theme to a control"""
	if control is Button:
		control.add_theme_stylebox_override("normal", create_button_style())
		control.add_theme_color_override("font_color", get_color("text_inverse"))
		control.add_theme_font_size_override("font_size", get_font_size("medium"))
	elif control is Panel:
		control.add_theme_stylebox_override("panel", create_panel_style())
	elif control is LineEdit:
		control.add_theme_stylebox_override("normal", create_input_style())
		control.add_theme_color_override("font_color", get_color("text_primary"))
		control.add_theme_font_size_override("font_size", get_font_size("medium"))

func create_animation_tween(node: Control) -> Tween:
	"""Create a tween for animations"""
	var tween = node.create_tween()
	tween.set_ease(get_easing_function("ease_out"))
	tween.set_trans(Tween.TRANS_QUAD)
	return tween

func animate_fade_in(node: Control, duration: float = 0.2):
	"""Animate a control fading in"""
	if not node or not node.get_tree():
		return
	node.modulate.a = 0.0
	var tween = create_animation_tween(node)
	tween.tween_property(node, "modulate:a", 1.0, duration)

func animate_fade_out(node: Control, duration: float = 0.2):
	"""Animate a control fading out"""
	if not node or not node.get_tree():
		return
	var tween = create_animation_tween(node)
	tween.tween_property(node, "modulate:a", 0.0, duration)

func animate_slide_in(node: Control, direction: Vector2, duration: float = 0.3):
	"""Animate a control sliding in from a direction"""
	if not node or not node.get_tree():
		return
	var start_pos = node.position + direction * 100
	var end_pos = node.position
	
	node.position = start_pos
	node.modulate.a = 0.0
	
	var tween = create_animation_tween(node)
	tween.parallel().tween_property(node, "position", end_pos, duration)
	tween.parallel().tween_property(node, "modulate:a", 1.0, duration)

func load_theme_settings():
	"""Load theme settings from save system"""
	var save_system = get_node_or_null("/root/SaveSystem")
	if save_system:
		var settings = save_system.load_settings()
		if settings.has("ui_theme"):
			set_theme(settings["ui_theme"])
		if settings.has("color_scheme"):
			set_color_scheme(settings["color_scheme"])

func save_theme_settings():
	"""Save theme settings to save system"""
	var save_system = get_node_or_null("/root/SaveSystem")
	if save_system:
		var settings = {
			"ui_theme": current_theme,
			"color_scheme": current_color_scheme
		}
		save_system.save_settings(settings) 
