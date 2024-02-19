extends TextureButton

@onready var texture_rect = $TextureRect
@onready var color_rect = $ColorRect
@onready var label = $Label

var product: ProductResource

func _ready():
	_update()
	GameManager.slot_changed.connect(func(_s, _p): _update())
	GameManager.slot_filled.connect(func(_s, _a): _update())
	GameManager.product_bought.connect(func(_p): _update())

func _update():
	if product and GameManager.is_unlocked(product):
		var stock = GameManager.get_stock_for(product.type)
		label.text = "%s" % stock
		label.show()
	else:
		label.hide()

func set_product(p: ProductResource):
	product = p
	texture_rect.texture = p.icon
	color_rect.visible = not GameManager.is_unlocked(product)
	_update()
