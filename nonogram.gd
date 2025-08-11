extends GridContainer
class_name Nonogram


@export var pixels: Array[Array] = [
	[0, 0, 1, 0, 0],
	[1, 0, 1, 0, 1],
	[1, 1, 1, 0, 1],
	[0, 0, 1, 0, 0],
	[1, 0, 1, 0, 1],
]
@export var NonogramSquareScene: PackedScene
@export var clues_on_top = false
var height: int
var width: int
var vertical_clues: Array[Array] = []
var horizontal_clues: Array[Array] = []
var squares: Array[Array] = []
signal solved
signal changed(pixels: Array[Array])
signal satisfied(index: int, is_row: bool)


func count_runs(data: Array[Array], i: int, row_count: bool) -> Array[int]:
	var result: Array[int] = []
	var run = 0
	for j in range(width if row_count else height):
		var row: int
		var col: int
		if row_count:
			row = i
			col = j
		else:
			row = j
			col = i
		if data[row][col] == 0:
			if run != 0:
				result.append(run)
				run = 0
		else:
			run += 1
	if run != 0:
		result.append(run)
	return result


func _init_clues() -> void:
	height = len(pixels)
	width = len(pixels[0])

	# instantiate top clues
	for col in range(width):
		vertical_clues.append(count_runs(pixels, col, false))

	# instantiate side clues
	for row in range(height):
		horizontal_clues.append(count_runs(pixels, row, true))


func get_square(row: int, col: int) -> NonogramSquare:
	return squares[row][col] as NonogramSquare


func clear_column(col: int) -> void:
	for row in range(height):
		squares[row][col].clear()


func clear_row(row: int) -> void:
	for col in range(width):
		squares[row][col].clear()


func set_column(col: int, col_pixels: Array[int]) -> void:
	assert(len(pixels) == height)
	for row in range(height):
		squares[row][col].set_on(col_pixels[row])
	if self.check_solution(get_current_solution()):
		self.emit_signal("solved")


func set_row(row: int, row_pixels: Array[int]) -> void:
	assert(len(pixels) == width)
	for col in range(width):
		squares[row][col].set_on(row_pixels[col])
	if self.check_solution(get_current_solution()):
		self.emit_signal("solved")


func set_col_lock(col: int, lock: bool) -> void:
	for row in range(0, height):
		self.get_square(row, col).update_locked(lock)


func set_row_lock(row: int, lock: bool) -> void:
	for col in range(0, width):
		get_square(row, col).update_locked(lock)


func get_current_solution() -> Array[Array]:
	var result: Array[Array] = []
	for row in range(0, height):
		result.append([])
		for col in range(0, width):
			var square = get_square(row, col)
			result[-1].append(1 if square.is_on() else 0)
	return result


func _add_vertical_clues(min_size: Vector2) -> void:
	var topleft_panel = Control.new()
	add_child(topleft_panel)
	for group in vertical_clues:
		var clues = VBoxContainer.new()
		clues.custom_minimum_size = min_size
		for clue in group:
			var label = Label.new()
			label.custom_minimum_size = min_size
			label.text = str(clue)
			clues.add_child(label)
		add_child(clues)


func _add_horizontal_clues_and_squares(min_size: Vector2) -> void:
	var row = 0
	for group in horizontal_clues:
		squares.append([])
		var clues = HBoxContainer.new()
		clues.custom_minimum_size = min_size
		for clue in group:
			var label = Label.new()
			label.custom_minimum_size = min_size
			label.text = str(clue)
			clues.add_child(label)
		add_child(clues)
		for col in range(0, width):
			var square: NonogramSquare = NonogramSquareScene.instantiate()
			square.changed.connect(on_solution_update)
			square.row = row
			square.col = col
			squares[-1].append(square)
			add_child(square)
		row += 1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_init_clues()
	columns = width + 1
	var grid_min_size = Vector2(32, 32)
	if clues_on_top:
		_add_vertical_clues(grid_min_size)
	_add_horizontal_clues_and_squares(grid_min_size)
	if not clues_on_top:
		_add_vertical_clues(grid_min_size)


func check_solution(solution: Array[Array]) -> bool:
	for row in range(self.height):
		for col in range(self.width):
			if solution[row][col] != pixels[row][col]:
				return false
	return true


func on_solution_update() -> void:
	var solution = get_current_solution()
	self.emit_signal("changed", solution)

	# Check for satisfied rows/columns
	var automarked_rows = []
	for row in range(self.height):
		var runs = count_runs(solution, row, true)
		var is_satisfied = runs.hash() == horizontal_clues[row].hash()
		if is_satisfied:
			emit_signal("satisfied", row, true)
			automarked_rows.append(row)
		for col in range(self.width):
			get_square(row, col).set_automark(is_satisfied)
	for col in range(self.width):
		var runs = count_runs(solution, col, false)
		var is_satisfied = runs.hash() == vertical_clues[col].hash()
		if is_satisfied:
			emit_signal("satisfied", col, false)
		for row in range(self.height):
			if row in automarked_rows:
				continue
			get_square(row, col).set_automark(is_satisfied)

	if self.check_solution(solution):
		self.emit_signal("solved")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
