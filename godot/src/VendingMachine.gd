extends Node2D

@export var first_slot: Node2D

@onready var slots: Dictionary = {
	Vector2.ZERO: first_slot
}

func get_slots():
	return slots

