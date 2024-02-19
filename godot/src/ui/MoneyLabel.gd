extends Label

func _ready():
	_update()
	GameManager.money_changed.connect(func(_diff): _update())

func _update():
	text = "%s" % GameManager.money
