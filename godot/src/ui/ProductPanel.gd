class_name ProductPanel
extends DialogPanel

@export_category("Buttons")
@export var unlock_btn: Button
@export var restock_btn: Button
@export var restock_batch_btn: Button
@export var place_btn: Button

@export_category("Product Info")
@export var buy_price: Label
@export var sell_price: Label
@export var unlock_price: Label
@export var icon: IconWithLock

var current_product: ProductResource

func _ready():
	super._ready()
	
	GameManager.product_unlocked.connect(func(_p): _update_buttons())
	GameManager.selected_slot.connect(func(slot: Vector2):
		if current_product:
			GameManager.set_product_for_slot(slot, current_product)
	)
	
	unlock_btn.pressed.connect(func(): 
		if current_product:
			GameManager.unlock_product(current_product)
	)
	restock_btn.pressed.connect(func():
		if current_product:
			GameManager.restock_product(current_product, 1)
	)
	restock_batch_btn.pressed.connect(func():
		if current_product:
			GameManager.restock_product(current_product, 10)
	)
	place_btn.pressed.connect(func():
		hide_panel()
		for slot in get_tree().get_nodes_in_group(SlotMarker.GROUP):
			slot.edit()
	)

func open_for(product: ProductResource):
	current_product = product
	icon.set_item(product)
	buy_price.text = "%s" % product.base_price
	sell_price.text = "%s" % product.sell_price
	unlock_price.text = "%s" % product.unlock_price
	
	_update_buttons()
	show_panel()

func _update_buttons():
	if current_product:
		var is_unlocked = GameManager.is_unlocked(current_product)
		unlock_btn.visible = not is_unlocked 
		place_btn.visible = is_unlocked
		restock_btn.visible = is_unlocked
		restock_batch_btn.visible = is_unlocked
