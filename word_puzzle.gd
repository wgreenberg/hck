extends Control

@export var NonogramScene: PackedScene
@export var EditableWordScene: PackedScene
@export var answer: String
@export var alphabet: String = "abcdefghijklmnopqrstuvwxyz\".,! "
@export var horizontal: bool = true
var container: Container


func to_binary_digits(n: int) -> Array[int]:
	var digits: Array[int] = []
	while n > 0:
		digits.push_front(n & 1)
		n = n >> 1
	for i in range(5 - len(digits)):
		digits.push_front(0)
	return digits


func word_to_pixels(s: String) -> Array[Array]:
	var result: Array[Array] = []
	for i in range(s.length()):
		var n = alphabet.find(s[i].to_lower())
		assert(n != -1, "couldn't find letter: " + s[i])
		result.append(to_binary_digits(n + 1))
	if horizontal:
		return transpose(result)
	return result


func transpose(pixels: Array[Array]) -> Array[Array]:
	var height = len(pixels)
	var width = len(pixels[0])
	var result: Array[Array] = []
	for col in range(width):
		result.append([])
		for row in range(height):
			result[-1].append(pixels[row][col])
	return result


func on_solved() -> void:
	print("nice")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var nonogram: Nonogram = NonogramScene.instantiate()
	nonogram.pixels = word_to_pixels(answer)
	nonogram.solved.connect(on_solved)

	var editable_word: EditableWord = EditableWordScene.instantiate()
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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
