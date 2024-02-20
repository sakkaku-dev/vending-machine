class_name DialogPanel
extends Control

signal opening()
signal hiding()

@export var overlay: ColorRect
@export var container: Control
@export var close_btn: BaseButton

func _ready():
	hide()
	close_btn.pressed.connect(func(): hide_panel())

func show_panel():
	opening.emit()
	var tw = create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	overlay.modulate = Color.TRANSPARENT
	tw.tween_property(overlay, "modulate", Color.WHITE, 0.5)

	container.position = Vector2(container.size.x, 0)
	tw.tween_property(container, "position", Vector2.ZERO, 0.5)
	
	show()

func hide_panel():
	hiding.emit()
	
	var tw = create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(overlay, "modulate", Color.TRANSPARENT, 0.5)
	tw.tween_property(container, "position", Vector2(container.size.x, 0), 0.5)
	await tw.finished
	hide()
