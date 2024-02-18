extends Node

signal available_products_changed()
signal selected_slot(slot: Vector2)

signal slot_changed(slot, product)
signal slot_filled(slot, amount)
signal slot_sold(slot, earned_money)

var available_products: Array[ProductResource] = [
	preload("res://src/products/soda.tres"),
	preload("res://src/products/sport.tres")
]

var _unlocked_products = [ProductResource.Type.SODA]

var resell_increase := 1.5
var items_per_slot := 5
var money = 0
var stock = {
	ProductResource.Type.SODA: 100
}
var slot_product = {}
var slot_amount = {}

var _logger = Logger.new("GameManager")

func _ready():
	for slot in get_tree().get_nodes_in_group(SlotMarker.GROUP):
		slot_product[slot.slot_coord] = null
		slot_amount[slot.slot_coord] = 0

func get_stock_for(type: ProductResource.Type):
	return stock[type] if type in stock else 0

func get_slot_amount(slot: Vector2):
	return slot_amount[slot] if slot in slot_amount else 0

func _reset_slot(slot: Vector2):
	var current_amount = get_slot_amount(slot)
	if current_amount > 0:
		var prev_product = slot_product[slot]
		if prev_product:
			stock[prev_product.type] += current_amount
		
		slot_amount[slot] -= current_amount
		if slot_amount[slot] != 0:
			_logger.warn("Changed product for slot %s, but amount was not reset to zero: %s" % [slot, slot_amount[slot]])
	
	slot_product[slot] = null

func is_unlocked(p: ProductResource):
	return p.type in _unlocked_products

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
	_reset_slot(slot)
	slot_product[slot] = product
	slot_amount[slot] = 0
	fill_slot(slot)
	GameManager.slot_changed.emit(slot, product)

func sold_in_slot(slot: Vector2):
	var product = slot_product[slot]
	slot_amount[slot] -= 1
	
	var earned = ceil(product.base_price * resell_increase)
	money += earned
	
	_logger.debug("Sold %s in slot %s and earned %s coins" % [product.type, slot, earned])
	GameManager.slot_sold.emit(slot, earned)

func get_slots_with_available_products():
	var result = []
	
	for slot in slot_product:
		if slot_product[slot] == null: continue
		if slot in slot_amount and slot_amount[slot] <= 0: continue
		result.append(slot)
	
	return result