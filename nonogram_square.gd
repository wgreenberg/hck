extends TextureButton
class_name NonogramSquare


enum SquareState {
	On,
	Off,
	Marked,
	AutoMarked
}


@export var row: int
@export var col: int
@export var locked_in: bool = false
@export var state: SquareState = SquareState.Off
@export var tex_on: Texture2D
@export var tex_off: Texture2D
@export var tex_marked: Texture2D
signal changed


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.texture_normal = tex_off
	self.gui_input.connect(handle_input)


func handle_input(event: InputEvent):
	if self.locked_in:
		return
	if event is InputEventMouseButton and event.is_released():
		var old_state = self.state
		if event.button_index == MOUSE_BUTTON_LEFT:
			self.on_click()
		else:
			self.on_right_click()
		var new_state = self.state

		if old_state == SquareState.On:
			if new_state in [SquareState.Off, SquareState.Marked]:
				self.emit_signal("changed")
		elif new_state == SquareState.On:
			self.emit_signal("changed")


func is_on() -> bool:
	return self.state == SquareState.On


func update_locked(new_locked: bool) -> void:
	self.locked_in = new_locked


func update_state(new_state: SquareState) -> void:
	self.state = new_state
	if self.state == SquareState.Off:
		self.texture_normal = tex_off
	elif self.state in [SquareState.Marked, SquareState.AutoMarked]:
		self.texture_normal = tex_marked
	else:
		self.texture_normal = tex_on


func clear() -> void:
	self.update_state(SquareState.Off)


func set_on(on: int) -> void:
	if on == 0:
		self.update_state(SquareState.AutoMarked)
	else:
		self.update_state(SquareState.On)


func set_automark(automark: bool) -> void:
	if automark and self.state == SquareState.Off:
		self.update_state(SquareState.AutoMarked)
	elif not automark and self.state == SquareState.AutoMarked:
		self.update_state(SquareState.Off)


func on_click() -> void:
	if self.state == SquareState.Off:
		self.update_state(SquareState.On)
	else:
		self.update_state(SquareState.Off)


func on_right_click() -> void:
	if self.state in [SquareState.Marked, SquareState.AutoMarked]:
		self.update_state(SquareState.Off)
	else:
		self.update_state(SquareState.Marked)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
