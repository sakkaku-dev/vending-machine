class_name SlotMarker
extends Marker2D

const GROUP = "SlotMarker"

@onready var color_rect = $ColorRect

@export var slot_coord: Vector2

var current_product: ProductResource

func _ready():
	add_to_group(GROUP)
	
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
			
			for c in get_children():
				if c == color_rect: continue
				remove_child(c)
			
			var node = current_product.scene.instantiate()
			add_child(node)
	)
	
	color_rect.hide()
	
func edit():
	color_rect.show()

func cancel():
	color_rect.hide()
