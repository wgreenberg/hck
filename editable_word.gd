extends BoxContainer
class_name EditableWord


enum EditableWordState {
	Inactive,
	Focused,
}


@export var length: int
@export var horizontal: bool = true
@export var EditableLetterScene: PackedScene
var letter_container: Container
var letters: Array[String] = []
var letter_buttons: Array[Button] = []

var mouseover_letter: EditableLetter = null
var focused_button_index: int = -1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if horizontal:
		letter_container = HBoxContainer.new()
	else:
		letter_container = VBoxContainer.new()
	add_child(letter_container)

	for i in range(length):
		var editable_letter = EditableLetterScene.instantiate()
		editable_letter.index = i
		editable_letter.mouse_entered.connect(func(): _on_mouse_entered(i))
		letters.append('')
		letter_buttons.append(editable_letter)
		letter_container.add_child(editable_letter)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if mouseover_letter != null:
			focused_button_index = mouseover_letter.index
		else:
			focused_button_index = -1
	if focused_button_index == -1:
		return
	var focused_letter: EditableLetter = letter_buttons[focused_button_index]
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_ESCAPE:
			clear_focus()
		elif event.keycode == KEY_DELETE or event.keycode == KEY_BACKSPACE:
			focused_letter.clear_letter()
			focus_prev_letter()
		elif event.keycode >= KEY_A and event.keycode <= KEY_Z:

			focused_letter.set_letter(event)
			focus_next_letter()


func clear_focus() -> void:
	focused_button_index = -1
	update_focus()


func update_focus() -> void:
	for i in range(len(letter_buttons)):
		letter_buttons[i].set_focused(i == focused_button_index)


func focus_next_letter() -> void:
	focused_button_index = wrapi(focused_button_index + 1, 0, len(letters))
	update_focus()


func focus_prev_letter() -> void:
	focused_button_index = wrapi(focused_button_index - 1, 0, len(letters))
	update_focus()


func _on_mouse_exited() -> void:
	mouseover_letter = null


func _on_mouse_entered(i: int) -> void:
	mouseover_letter = letter_buttons[i]


func _update_from_state() -> void:
	if self.state == EditableWordState.Inactive:
		for button in letter_buttons:
			pass
	else:
		for i in range(len(letter_buttons)):
			var letter = letter_buttons[i]
			pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
