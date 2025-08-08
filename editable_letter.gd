extends Button
class_name EditableLetter


@export var index: int
var focused = false
var mouseover = false
var label: Label


func set_letter(event: InputEventKey) -> void:
	var typed_letter = OS.get_keycode_string(event.physical_keycode)
	label.text = str(typed_letter)


func clear_letter() -> void:
	label.text = ''


func set_focused(new_focused: bool) -> void:
	focused = new_focused
	if focused:
		grab_focus()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label = Label.new()
	add_child(label)
	custom_minimum_size = Vector2(32, 32)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
