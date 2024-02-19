extends Node2D

@export var available_list: Control
@onready var sell_timer = $SellTimer

func _ready():
	sell_timer.timeout.connect(func():
		var slots = GameManager.get_slots_with_available_products()
		if slots.size() > 0:
			var slot = slots.pick_random()
			GameManager.sold_in_slot(slot)
	)
