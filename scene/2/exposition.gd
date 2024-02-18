extends MarginContainer


#region vars
@onready var lap = $VBox/Icons/Lap
@onready var turn = $VBox/Icons/Turn
@onready var phase = $VBox/Icons/Phase
@onready var collectors = $VBox/Collectors
@onready var galleries = $VBox/Galleries

var museum = null
var collector = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	museum = input_.museum
	
	init_basic_setting()


func init_basic_setting() -> void:
	init_icons()


func init_icons() -> void:
	var input = {}
	input.type = "number"
	input.subtype = 0
	lap.set_attributes(input)
	lap.custom_minimum_size = Vector2(Global.vec.size.token * 0.5)
	
	turn.set_attributes(input)
	turn.custom_minimum_size = Vector2(Global.vec.size.token * 0.5) 
	
	input.type = "phase"
	input.subtype = Global.arr.phase.back()
	phase.set_attributes(input)
	phase.custom_minimum_size = Vector2(Global.vec.size.token * 0.5) 


func add_collector(collector_: MarginContainer) -> void:
	collector_.exposition = self
	collector_.guild.collectors.remove_child(collector_)
	collectors.add_child(collector_)


func rolls_galleries() -> void:
	reset_galleries()
	
	for _i in 3:
		add_gallery()


func reset_galleries() -> void:
	while galleries.get_child_count() > 0:
		var gallery = galleries.get_child(0)
		galleries.remove_child(gallery)
		gallery.queue_free()


func add_gallery() -> void:
	var input = {}
	input.exposition = self
	
	var gallery = Global.scene.gallery.instantiate()
	galleries.add_child(gallery)
	gallery.set_attributes(input)
#endregion


func make_art() -> void:
	collector = collectors.get_child(0)
	
	#follow_phase()
	
	for _i in 0:
		skip_all_phases()


func skip_all_phases() -> void:
	for _i in Global.arr.phase.size():
		follow_phase()


#region phase
func follow_phase() -> void:
	var index = Global.arr.phase.find(phase.subtype)
	index = (index + 1) % Global.arr.phase.size()
	
	phase.subtype = Global.arr.phase[index]
	phase.update_image()
	
	if index == 0:
		swap_collector()
	
	turn.change_number(1)
	
	if turn.get_number() == Global.arr.phase.size() * 2:
		turn.set_number(0)
		lap.change_number(1)
	
	var func_name = phase.subtype + "_" + "phase"
	call(func_name)


func growing_phase() -> void:
	collector.workshop.get_essence_from_increment()


func preparing_phase() -> void:
	collector.prepare_galleries()


func picking_phase() -> void:
	collector.pick_gallery()


func filling_phase() -> void:
	collector.workshop.get_essence_from_sacrifice()
	collector.domain.filling_of_exhibit_requirements()


func swap_collector() -> void:
	var index = (collector.get_index() + 1) % collectors.get_child_count()
	collector = collectors.get_child(index)
#endregion
