class_name ProductPanel
extends Control

@export var overlay: ColorRect
@export var container: Control

@export_category("Buttons")
@export var unlock_btn: Button
@export var restock_btn: Button
@export var restock_batch_btn: Button
@export var place_btn: Button
@export var close_btn: BaseButton

@export_category("Product Info")
@export var buy_price: Label
@export var sell_price: Label
@export var unlock_price: Label
@export var icon: IconWithLock

var current_product: ProductResource

func _ready():
	hide()
	
	GameManager.product_unlocked.connect(func(_p): _update_buttons())
	GameManager.selected_slot.connect(func(slot: Vector2):
		if current_product:
			GameManager.set_product_for_slot(slot, current_product)
	)
	
	close_btn.pressed.connect(func(): _hide_panel())
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
		_hide_panel()
		for slot in get_tree().get_nodes_in_group(SlotMarker.GROUP):
			slot.edit()
	)

func open_for(product: ProductResource):
	current_product = product
	icon.set_product(product)
	buy_price.text = "%s" % product.base_price
	sell_price.text = "%s" % product.sell_price
	unlock_price.text = "%s" % product.unlock_price
	
	_update_buttons()
	_show_panel()

func _update_buttons():
	if current_product:
		var is_unlocked = GameManager.is_unlocked(current_product)
		unlock_btn.visible = not is_unlocked 
		place_btn.visible = is_unlocked
		restock_btn.visible = is_unlocked
		restock_batch_btn.visible = is_unlocked

func _show_panel():
	var tw = create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	overlay.modulate = Color.TRANSPARENT
	tw.tween_property(overlay, "modulate", Color.WHITE, 0.5)

	container.position = Vector2(container.size.x, 0)
	tw.tween_property(container, "position", Vector2.ZERO, 0.5)
	
	show()

func _hide_panel():
	var tw = create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(overlay, "modulate", Color.TRANSPARENT, 0.5)
	tw.tween_property(container, "position", Vector2(container.size.x, 0), 0.5)
	await tw.finished
	hide()
