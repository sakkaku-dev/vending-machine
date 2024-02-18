extends Node2D

@export var items_per_slot := 5

@export var available_list: Control

var resell_increase := 1.5
var money = 0
var stock = {
	ProductResource.Type.SODA: 100
}
var slot_product = {
	Vector2.ZERO: null
}
var slot_amount = {
	Vector2.ZERO: 0
}

var _logger = Logger.new("Game")
var selecting_product

func _ready():
	GameManager.selected_slot.connect(func(slot: Vector2): set_product_for_slot(slot, selecting_product))

func fill_slot(slot: Vector2):
	var product = slot_product[slot]
	if product == null:
		_logger.info("Slot %s has no product assigned" % slot)
		return
	
	if stock[product.type] <= 0:
		_logger.info("Slot %s product %s is out of stock" % [slot, ProductResource.Type.keys()[product.type]])
		return

	var current_amount = slot_amount[slot]
	var fill_amount = items_per_slot - current_amount
	
	stock[product.type] -= fill_amount
	slot_amount[slot] += fill_amount
	GameManager.slot_filled.emit(slot, fill_amount)

func set_product_for_slot(slot: Vector2, product: ProductResource):
	var current_amount = slot_amount[slot]
	if current_amount > 0:
		var prev_product = slot_product[slot]
		if prev_product:
			stock[prev_product.type] += current_amount
		
		slot_amount[slot] -= current_amount
		if slot_amount[slot] != 0:
			_logger.warn("Changed product for slot %s, but amount was not reset to zero: %s" % [slot, slot_amount[slot]])
	
	slot_product[slot] = product
	GameManager.slot_changed.emit(slot, product)
	
func sold_in_slot(slot: Vector2):
	var product = slot_product[slot]
	slot_amount[slot] -= 1
	
	var earned = ceil(product.base_price * resell_increase)
	money += earned
	
	_logger.debug("Sold %s in slot %s and earned %s coins" % [product.type, slot, earned])
	GameManager.slot_sold.emit(slot, earned)

func _on_product_list_edit_for(product: ProductResource):
	selecting_product = product
	for slot in get_tree().get_nodes_in_group(SlotMarker.GROUP):
		slot.edit()
