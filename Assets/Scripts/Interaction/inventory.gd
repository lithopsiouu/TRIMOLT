class_name Inventory extends Node

## Inventory that holds items. 

var items: Array[Item] = []

func add_item(item: Item) -> void:
	items.append(item)

func remove_item(item: Item) -> void:
	items.erase(item)

func drop_item(item: Item, position: Vector3) -> void:
	item.disable(false)
	item.global_position = position
	item.rotation_degrees = Vector3(0, randf_range(-180, 180), 0)
	remove_item(item)
