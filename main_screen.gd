extends Control


@export var WordPuzzleScene: PackedScene
var word_puzzle: WordPuzzle
var word_list = [
	"kangaroo",
	"reliable",
	"cottage",
	"circumstance",
	"situation",
	"franchise",
	"elevate",
	"abstract",
	"bucket",
	"compose",
	"architect",
	"nominate",
	"spread",
	"advice",
	"alarm",
	"publicity",
	"plagiarize",
]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	word_puzzle = WordPuzzleScene.instantiate()
	word_puzzle.answer = word_list.pick_random()
	print(word_puzzle.answer)
	word_puzzle.solved.connect(on_solved)
	add_child(word_puzzle)

	$TextureButton.pressed.connect(reset)
	$TextureButton.visible = false


func on_solved() -> void:
	$TextureButton.visible = true


func reset() -> void:
	get_tree().reload_current_scene()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
