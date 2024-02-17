extends Node


@onready var sketch = $Sketch


func _ready() -> void:
	#datas.sort_custom(func(a, b): return a.value < b.value)
	#012 description
	#Global.rng.randomize()
	#var random = Global.rng.randi_range(0, 1)
	pass


func _input(event) -> void:
	if event is InputEventKey:
		match event.keycode:
			KEY_1:
				if event.is_pressed() && !event.is_echo():
					sketch.wildlands.museums.get_child(0).expositions.get_child(0).skip_all_phases()
			KEY_SPACE:
				if event.is_pressed() && !event.is_echo():
					sketch.wildlands.museums.get_child(0).expositions.get_child(0).follow_phase()#collectors.get_child(0).prepare_galleries()


func _process(delta_) -> void:
	$FPS.text = str(Engine.get_frames_per_second())


