extends MarginContainer


@onready var cradle = $HBox/Cradle
@onready var wildlands = $HBox/Wildlands


func _ready() -> void:
	var input = {}
	input.sketch = self
	cradle.set_attributes(input)
	wildlands.set_attributes(input)
	
	var exposition = wildlands.museums.get_child(0).expositions.get_child(0)
	
	for guild in cradle.guilds.get_children():
		var collector = guild.collectors.get_child(0)
		exposition.add_collector(collector)
