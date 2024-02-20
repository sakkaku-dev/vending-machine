extends TextureButton

@export var texture_rect: IconWithLock
@export var title: Label
@export var desc: Label
@export var overlay: Control

var upgrade: UpgradeResource

func _ready():
	overlay.hide()
	mouse_entered.connect(func(): overlay.show())
	mouse_exited.connect(func(): overlay.hide())
	
	pressed.connect(func(): GameManager.unlock_upgrade(upgrade))

func set_upgrade(u: UpgradeResource):
	upgrade = u
	texture_rect.set_item(u)
	title.text = "%s (%s)" % [u.get_upgrade_name(), u.price]
	desc.text = u.description

