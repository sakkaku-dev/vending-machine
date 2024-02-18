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
