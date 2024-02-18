extends Label

func _ready():
	_update()
	GameManager.slot_sold.connect(func(_slot, _earned): _update())

func _update():
	text = "%s coins" % GameManager.money
