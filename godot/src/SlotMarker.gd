class_name SlotMarker
extends Marker2D

const GROUP = "SlotMarker"

@export var drop_position: Node2D
@export var stock_light: TextureButton
@onready var color_rect = $ColorRect

@export var slot_coord: Vector2

@export var out_of_stock_color := Color.RED
@export var full_stock_color := Color.GREEN
@export var half_stock_color := Color.ORANGE

var current_product: ProductResource
var latest_node

func _ready():
	add_to_group(GROUP)
	
	stock_light.pressed.connect(func(): GameManager.fill_slot(slot_coord))
	
	color_rect.mouse_entered.connect(func(): color_rect.z_index = 10)
	color_rect.mouse_exited.connect(func(): color_rect.z_index = 0)
	color_rect.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT:
			GameManager.selected_slot.emit(slot_coord)
	)
	
	GameManager.selected_slot.connect(func(_s): cancel())
	GameManager.slot_changed.connect(func(slot, product):
		if slot == slot_coord:
			current_product = product
			
			_remove_all()
			latest_node = _add_scene()
			_update_stock_color()
	)
	GameManager.slot_filled.connect(func(slot, amount):
		if slot == slot_coord:
			_update_stock_color()
	)
	GameManager.slot_sold.connect(func(slot, earned):
		if slot == slot_coord:
			_update_stock_color()
			
			latest_node.drop(drop_position.global_position.y)
			if GameManager.get_slot_amount(slot_coord) > 0:
				latest_node = _add_scene()
	)
	
	color_rect.hide()
	
func edit():
	color_rect.show()

func cancel():
	color_rect.hide()

func _remove_all():
	for c in get_children():
		if c == color_rect or c == stock_light: continue
		remove_child(c)

func _add_scene():
	var node = current_product.scene.instantiate()
	add_child(node)
	move_child(node, 0)
	return node

func _update_stock_color():
	var p = GameManager.get_slot_amount(slot_coord) / float(GameManager.items_per_slot)
	var color = half_stock_color
	if p > 0.5:
		color = full_stock_color
	elif p == 0:
		color = out_of_stock_color
	stock_light.modulate = color
