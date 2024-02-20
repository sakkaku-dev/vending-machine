extends TextureButton

@onready var texture_rect = $TextureRect
@onready var label = $Label

var product: ProductResource

func _ready():
	_update()
	GameManager.stock_changed.connect(func(_p, _diff): _update())
	GameManager.product_unlocked.connect(func(_p): _update())

func _update():
	if product and GameManager.is_unlocked(product):
		var stock = GameManager.get_stock_for(product.type)
		label.text = "%s" % stock
		label.show()
	else:
		label.hide()

func set_product(p: ProductResource):
	product = p
	texture_rect.set_item(p)
	_update()
