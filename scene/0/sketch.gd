extends MarginContainer


@onready var cradle = $HBox/Cradle
@onready var wildlands = $HBox/Wildlands


func _ready() -> void:
	var input = {}
	input.sketch = self
	cradle.set_attributes(input)
	wildlands.set_attributes(input)
