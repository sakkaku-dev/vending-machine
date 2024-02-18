class_name ProductResource
extends Resource

enum Type {
	SODA,
	SPORT,
}

@export var type := Type.SODA
@export var base_price := 3
@export var unlock_price := 100
@export var icon: Texture2D
@export var scene: PackedScene
