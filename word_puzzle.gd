extends Control

@export var NonogramScene: PackedScene
@export var EditableWordScene: PackedScene
@export var answer: String
@export var alphabet: String = "abcdefghijklmnopqrstuvwxyz\".,! "
@export var horizontal: bool = true
var container: Container
var editable_word: EditableWord
var nonogram: Nonogram
signal solved


func int_to_binary_digits(n: int) -> Array[int]:
	var digits: Array[int] = []
	while n > 0:
		digits.push_front(n & 1)
		n = n >> 1
	for i in range(5 - len(digits)):
		digits.push_front(0)
	return digits


func binary_digits_to_int(digits: Array[int]) -> int:
	var result = -1
	for i in range(len(digits)):
		result += digits[len(digits) - i - 1] << i
	return result


func word_to_pixels(s: String) -> Array[Array]:
	var result: Array[Array] = []
	for i in range(s.length()):
		var n = alphabet.find(s[i].to_lower())
		assert(n != -1, "couldn't find letter: " + s[i])
		result.append(int_to_binary_digits(n + 1))
	if horizontal:
		return transpose(result)
	return result


func binary_digits_to_letter(digits: Array[int]) -> String:
	assert(len(digits) == 5)
	var index = binary_digits_to_int(digits)
	return alphabet[index]


func transpose(pixels: Array[Array]) -> Array[Array]:
	var height = len(pixels)
	var width = len(pixels[0])
	var result: Array[Array] = []
	for col in range(width):
		result.append([])
		for row in range(height):
			result[-1].append(pixels[row][col])
	return result


func on_satisfied(index: int, is_row: bool) -> void:
	if horizontal and is_row:
		return
	elif not horizontal and not is_row:
		return
	var pixels: Array[int] = []
	var solution = nonogram.get_current_solution()
	for row in nonogram.height:
		for col in nonogram.width:
			if is_row and row == index:
				pixels.append(solution[row][col])
			elif not is_row and col == index:
				pixels.append(solution[row][col])
	var letter = binary_digits_to_letter(pixels)
	editable_word.set_letter(index, letter)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	nonogram = NonogramScene.instantiate()
	nonogram.pixels = word_to_pixels(answer)
	nonogram.satisfied.connect(on_satisfied)
	nonogram.solved.connect(on_solved)

	editable_word = EditableWordScene.instantiate()
	editable_word.length = len(answer)

	if horizontal:
		container = VBoxContainer.new()
		container.add_child(editable_word)
		container.add_child(nonogram)
	else:
		container = HBoxContainer.new()
		container.add_child(editable_word)
		container.add_child(nonogram)
	add_child(container)


func on_solved() -> void:
	emit_signal("solved")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
