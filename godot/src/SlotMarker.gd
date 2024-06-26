class_name SlotMarker
extends Marker2D

const GROUP = "SlotMarker"

@export var icon: Sprite2D
@export var drop_position: Node2D
@onready var color_rect = $ColorRect

@export var slot_coord: Vector2

var current_product: ProductResource
var latest_node

func _ready():
	add_to_group(GROUP)
	icon.hide()
	
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
			
			if latest_node:
				latest_node.queue_free()
				latest_node = null
			
			icon.texture = product.icon
			icon.show()
			
			if GameManager.get_slot_amount(slot_coord) > 0:
				latest_node = _add_scene()
	)
	GameManager.slot_filled.connect(func(slot, amount):
		if slot == slot_coord:
			if latest_node == null:
				latest_node = _add_scene()
	)
	GameManager.slot_sold.connect(func(slot, earned):
		if slot == slot_coord:
			latest_node.drop(drop_position.global_position.y)
			if GameManager.get_slot_amount(slot_coord) > 0:
				latest_node = _add_scene()
			else:
				latest_node = null
	)
	
	color_rect.hide()
	
func edit():
	color_rect.show()

func cancel():
	color_rect.hide()

func _remove_all():
	for c in get_children():
		if c == color_rect or c == icon or c == drop_position: continue
		remove_child(c)

func _add_scene():
	var node = current_product.scene.instantiate()
	add_child(node)
	move_child(node, 0)
	return node
