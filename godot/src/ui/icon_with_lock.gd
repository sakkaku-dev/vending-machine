class_name IconWithLock
extends TextureRect

@onready var color_rect = $ColorRect

var item

func _ready():
	GameManager.product_unlocked.connect(func(_p): _update())
	GameManager.upgrade_unlocked.connect(func(_u): _update())

func _update():
	if item:
		color_rect.visible = not GameManager.is_unlocked(item)

func set_item(p):
	item = p
	texture = p.icon
	_update()
