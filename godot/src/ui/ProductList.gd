extends Control

signal edit_for(product: ProductResource)

@export var item_scene: PackedScene

func _ready():
	_update()

func _update():
	for c in get_children():
		remove_child(c)
	
	for p in GameManager.available_products:
		var item = item_scene.instantiate() as TextureButton
		add_child(item)
		item.pressed.connect(func(): edit_for.emit(p))
		item.set_product(p)
