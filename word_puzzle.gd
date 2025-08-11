extends Control
class_name WordPuzzle


@export var NonogramScene: PackedScene
@export var EditableWordScene: PackedScene
@export var answer: String
@export var horizontal: bool = true
var alphabet: Array[String] = []
var container: Container
var editable_word: EditableWord
var nonogram: Nonogram
signal solved

# fixed indices:
# 10101 - 21
# 11101 - 29
# 10111 - 23
# 11011 - 27
# evil indices: 1, 2, 4, 8, 16


func setup_alphabet() -> void:
	alphabet.resize(32)
	alphabet.fill(null)
	alphabet[21] = "r"
	alphabet[23] = "s"
	alphabet[27] = "t"
	alphabet[29] = "l"
	alphabet[1] = "a"
	alphabet[2] = "e"
	alphabet[4] = "i"
	alphabet[8] = "o"
	alphabet[16] = "u"
	var remaining = "abcdefghijklmnopqrstuvwxyz"
	var letter_idx = 0
	var alphabet_idx = 1
	while letter_idx < len(remaining):
		if remaining[letter_idx] in alphabet:
			letter_idx += 1
			continue
		if alphabet[alphabet_idx] == "":
			alphabet[alphabet_idx] = remaining[letter_idx]
			letter_idx += 1
		alphabet_idx += 1


func int_to_binary_digits(n: int) -> Array[int]:
	var digits: Array[int] = []
	while n > 0:
		digits.push_front(n & 1)
		n = n >> 1
	for i in range(5 - len(digits)):
		digits.push_front(0)
	return digits


func binary_digits_to_int(digits: Array[int]) -> int:
	var result = 0
	for i in range(len(digits)):
		result += digits[len(digits) - i - 1] << i
	return result


func letter_to_binary_digits(letter: String) -> Array[int]:
	var n = alphabet.find(letter.to_lower())
	assert(n != -1, "couldn't find letter: " + letter)
	return int_to_binary_digits(n)


func binary_digits_to_letter(digits: Array[int]) -> String:
	assert(len(digits) == 5)
	var index = binary_digits_to_int(digits)
	return alphabet[index]


func word_to_pixels(s: String) -> Array[Array]:
	var result: Array[Array] = []
	for i in range(s.length()):
		result.append(letter_to_binary_digits(s[i]))
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


func on_delete(index: int) -> void:
	if horizontal:
		nonogram.clear_column(index)
	else:
		nonogram.clear_row(index)


func on_letter(letter: String, index: int) -> void:
	var pixels = letter_to_binary_digits(letter)
	if horizontal:
		nonogram.set_column(index, pixels)
	else:
		nonogram.set_row(index, pixels)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_alphabet()
	print(alphabet)
	nonogram = NonogramScene.instantiate()
	nonogram.pixels = word_to_pixels(answer)
	nonogram.satisfied.connect(on_satisfied)
	nonogram.solved.connect(on_solved)

	editable_word = EditableWordScene.instantiate()
	editable_word.length = len(answer)
	editable_word.letter.connect(on_letter)
	editable_word.delete.connect(on_delete)

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
