extends Node2D

@export var available_list: Control
@onready var sell_timer = $SellTimer

var _logger = Logger.new("Game")
var selecting_product

func _ready():
	GameManager.selected_slot.connect(func(slot: Vector2): GameManager.set_product_for_slot(slot, selecting_product))
	sell_timer.timeout.connect(func():
		var slots = GameManager.get_slots_with_available_products()
		if slots.size() > 0:
			var slot = slots.pick_random()
			GameManager.sold_in_slot(slot)
			_logger.debug("Sold product in slot %s" % slot)
	)

func _on_product_list_edit_for(product: ProductResource):
	selecting_product = product
	for slot in get_tree().get_nodes_in_group(SlotMarker.GROUP):
		slot.edit()
