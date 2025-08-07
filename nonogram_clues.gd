extends Container


enum TopOrSide {
	TOP,
	SIDE
}


@export var top_or_side: TopOrSide


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func update_clues(new_clues: Array[Array]) -> void:
	for group in new_clues:
		var group_container: Container
		if top_or_side == TopOrSide.TOP:
			group_container = VBoxContainer.new()
		else:
			group_container = HBoxContainer.new()
		self.add_child(group_container)
		for clue in group:
			var label = Label.new()
			label.text = str(clue)
			group_container.add_child(label)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
