extends DialogPanel

@export var list_container: Control
@export var list_item_scene: PackedScene

func _ready():
	super._ready()
	
	for u in GameManager.available_upgrades:
		var item = list_item_scene.instantiate()
		list_container.add_child(item)
		item.set_upgrade(u)
