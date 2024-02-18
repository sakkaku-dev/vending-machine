extends TextureButton

#signal edit_for(product)

@onready var texture_rect = $TextureRect

var tw: Tween
#var product: ProductResource

func _ready():
	pass
	#mouse_entered.connect(func(): _move(Vector2.LEFT * 3))
	#mouse_exited.connect(func(): _move(Vector2.ZERO))
	#pressed.connect(func(): edit_for.emit(product.type))

func _move(delta: Vector2):
	if tw and tw.is_running():
		tw.kill()
	
	tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(texture_rect, "position", delta, 0.5)

func set_icon(icon: Texture2D):
	texture_rect.texture = icon
