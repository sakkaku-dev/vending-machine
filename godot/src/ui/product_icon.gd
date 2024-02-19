extends TextureButton

@onready var texture_rect = $TextureRect
@onready var color_rect = $ColorRect
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
		color_rect.visible = false
		label.show()
	else:
		label.hide()
		color_rect.visible = true

func set_product(p: ProductResource):
	product = p
	texture_rect.texture = p.icon
	_update()
