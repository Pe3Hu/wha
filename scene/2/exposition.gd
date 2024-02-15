extends MarginContainer


#region vars
@onready var collectors = $VBox/Collectors
@onready var galleries = $VBox/Galleries

var museum = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	museum = input_.museum
	
	init_basic_setting()


func init_basic_setting() -> void:
	rolls_galleries()


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


func add_collector(collector_: MarginContainer) -> void:
	collector_.exposition = self
	collector_.guild.collectors.remove_child(collector_)
	collectors.add_child(collector_)


func make_art() -> void:
	var collector = collectors.get_child(0)
	
	#for _i in galleries.get_child_count():
		#collector.pick_gallery()
		#pass
	
	for gallery in galleries.get_children():
		collector.score_gallery(gallery)
#endregion
