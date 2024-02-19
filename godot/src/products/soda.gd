extends Node2D

@onready var sprite_2d = $Sprite2D

func drop(final_pos_y: float):
	var tw = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(sprite_2d, "scale", Vector2(1.1, 1.1), 0.5)
	
	tw.tween_property(self, "position:y", final_pos_y, 0.5).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(sprite_2d, "rotation", PI/2, 0.25).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(sprite_2d, "scale", Vector2(0.8, 1), 0.5).set_ease(Tween.EASE_OUT)
	
	await tw.finished
	queue_free()
