extends Node

enum Upgrades {
	AUTO_REFILL,
	AUTO_RESTOCK,
}

signal available_products_changed()
signal selected_slot(slot: Vector2)

signal slot_changed(slot, product)
signal slot_filled(slot, amount)
signal slot_sold(slot, earned_money)

signal stock_changed(p, diff)
signal money_changed(diff)
signal product_unlocked(p)
signal upgrade_unlocked(u)

var available_products: Array[ProductResource] = [
	preload("res://src/products/soda.tres"),
	preload("res://src/products/sport.tres"),
]
var available_upgrades: Array[UpgradeResource] = [
	preload("res://src/upgrades/AutoRefill.tres"),
	preload("res://src/upgrades/AutoRestock.tres"),
]

var _unlocked_products: Array[ProductResource.Type]= [ProductResource.Type.SODA]
var _unlocked_upgrades: Array[Upgrades] = []

var items_per_slot := 5
var money = 0:
	set(v):
		var diff = v - money
		money = v
		money_changed.emit(diff)

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
			_add_to_stock(prev_product.type, current_amount)
		
		slot_amount[slot] -= current_amount
		if slot_amount[slot] != 0:
			_logger.warn("Changed product for slot %s, but amount was not reset to zero: %s" % [slot, slot_amount[slot]])
	
	slot_product[slot] = null

func is_unlocked(i):
	if i is UpgradeResource:
		return i.type in _unlocked_upgrades
	elif i is ProductResource:
		return i.type in _unlocked_products
	return false

func unlock_upgrade(u: UpgradeResource):
	if u.type in _unlocked_upgrades:
		_logger.warn("Upgrade %s is already unlocked. No need to buy it again." % [u.get_upgrade_name()])
		return
	if money < u.price:
		_logger.warn("Cannot unlock upgrade %s. Price is %s, but only %s coins available." % [u.get_upgrade_name(), u.price, money])
		return
		
	self.money -= u.price
	_unlocked_upgrades.append(u.type)
	upgrade_unlocked.emit(u)
	

func unlock_product(p: ProductResource):
	if p.type in _unlocked_products:
		_logger.warn("Product %s is already unlocked. No need to buy it again." % [p.get_product_name()])
		return
	if money < p.unlock_price:
		_logger.warn("Cannot unlock product %s. Price is %s, but only %s coins available." % [p.get_product_name(), p.unlock_price, money])
		return
	
	self.money -= p.unlock_price
	_unlocked_products.append(p.type)
	product_unlocked.emit(p)

func restock_product(p: ProductResource, amount: int = 1):
	if not p.type in _unlocked_products:
		_logger.warn("Product %s is not unlocked. Cannot restock it." % [p.get_product_name()])
		return
		
	var total_price = p.base_price * amount
	if money < total_price:
		_logger.warn("Cannot restock product %s. Price is %s, but only %s coins available." % [p.get_product_name(), p.base_price, money])
		return
	
	self.money -= total_price
	_add_to_stock(p.type, amount)

func fill_slot(slot: Vector2):
	if not slot in slot_product:
		_logger.info("Slot %s has no product assigned" % slot)
		return
	
	var product = slot_product[slot]
	if get_stock_for(product.type) <= 0:
		_logger.info("Slot %s product %s is out of stock" % [slot, ProductResource.Type.keys()[product.type]])
		return

	var current_amount = slot_amount[slot]
	var fill_amount = items_per_slot - current_amount
	
	var stock_amount = stock[product.type]
	var actual_fill = min(stock_amount, fill_amount)
	
	_add_to_stock(product.type, -actual_fill)
	slot_amount[slot] += actual_fill
	GameManager.slot_filled.emit(slot, actual_fill)

func _add_to_stock(type: ProductResource.Type, amount: int):
	if not type in stock:
		stock[type] = 0
	
	stock[type] += amount
	stock_changed.emit(type, amount)

func set_product_for_slot(slot: Vector2, product: ProductResource):
	if not is_unlocked(product):
		_logger.warn("Cannot set product %s to slot %s. It's not unlocked yet" % [product.type, slot])
		return
	
	_reset_slot(slot)
	slot_product[slot] = product
	slot_amount[slot] = 0
	GameManager.slot_changed.emit(slot, product)
	
	fill_slot(slot)

func sold_in_slot(slot: Vector2):
	var product = slot_product[slot]
	slot_amount[slot] -= 1
	
	var earned = product.sell_price
	self.money += earned
	
	_logger.debug("Sold %s in slot %s and earned %s coins" % [product.type, slot, earned])
	GameManager.slot_sold.emit(slot, earned)

func get_slots_with_available_products():
	var result = []
	
	for slot in slot_product:
		if slot_product[slot] == null: continue
		if slot in slot_amount and slot_amount[slot] <= 0: continue
		result.append(slot)
	
	return result
