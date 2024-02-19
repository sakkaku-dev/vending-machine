class_name IconWithLock
extends TextureRect

@onready var color_rect = $ColorRect

var product: ProductResource

func _ready():
	GameManager.product_unlocked.connect(func(_p): _update())

func _update():
	if product:
		color_rect.visible = not GameManager.is_unlocked(product)

func set_product(p: ProductResource):
	product = p
	texture = p.icon
	_update()
