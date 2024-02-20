class_name UpgradeResource
extends Resource

enum Type {
	AUTO_REFILL,
	AUTO_RESTOCK,
}

@export var type := Type.AUTO_REFILL
@export var description := "It does something. A worth upgrade to buy"
@export var price := 200
@export var icon: Texture2D

func get_upgrade_name():
	return Type.keys()[type]
