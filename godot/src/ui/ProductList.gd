extends Control

signal edit_for(product: ProductResource)

@export var item_scene: PackedScene
@export var buy_confirm_dialog: ConfirmationDialog

var confirming_product

func _ready():
	_update()
	
	buy_confirm_dialog.canceled.connect(func():
		buy_confirm_dialog.hide()
		confirming_product = null
	)
	buy_confirm_dialog.confirmed.connect(func():
		if confirming_product:
			GameManager.buy_product(confirming_product)
	)

func _update():
	for c in get_children():
		remove_child(c)
	
	for p in GameManager.available_products:
		var item = item_scene.instantiate() as TextureButton
		add_child(item)
		item.pressed.connect(func():
			if GameManager.is_unlocked(p):
				edit_for.emit(p)
			else:
				confirming_product = p
				buy_confirm_dialog.dialog_text = "Buy %s for %s coins?" % [p.get_product_name(), p.unlock_price]
				buy_confirm_dialog.show()
		)
		item.set_product(p)
