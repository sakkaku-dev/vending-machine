class_name SlotAmount
extends TextureButton

@export var slot_marker: SlotMarker
@export var out_of_stock_color := Color.RED
@export var full_stock_color := Color.GREEN
@export var half_stock_color := Color.ORANGE

func _ready():
	pressed.connect(func(): GameManager.fill_slot(slot_marker.slot_coord))
	GameManager.slot_filled.connect(func(slot, _x):
		if slot_marker.slot_coord == slot:
			_update_stock_color()
	)
	GameManager.slot_sold.connect(func(slot, _x):
		if slot_marker.slot_coord == slot:
			_update_stock_color()
	)
	GameManager.slot_changed.connect(func(slot, _x):
		if slot_marker.slot_coord == slot:
			_update_stock_color()
	)

func _update_stock_color():
	var p = GameManager.get_slot_amount(slot_marker.slot_coord) / float(GameManager.items_per_slot)
	var color = half_stock_color
	if p > 0.5:
		color = full_stock_color
	elif p == 0:
		color = out_of_stock_color
	modulate = color
