class_name MentalNode
extends Node

## A [MentalNode] that is used by [MentalNote] and [MentalQuestion] classes.

var tags: Array = []
var content: String = ""
var _ID: int = -1
var ID_pair: int = -1 ## ID of other [MentalNode] that will create a [MentalConnection].


## Returns an [Array] of [param tags].
func get_tags() -> Array:
	return tags

## Sets [param tags].
func set_tags(new_tags: Array) -> void:
	tags = new_tags

## Appends [new_tags] to [tags].
func append_tags(new_tags: Array) -> void:
	tags.append_array(new_tags)


## Returns [param content].
func get_content() -> String:
	return content

## Sets [param content].
func set_content(new_content: String) -> void:
	content = new_content


## Returns [param _ID].
func get_ID() -> int:
	return _ID

## Sets [param _ID].
func set_ID(new_ID: int) -> void:
	_ID = new_ID


## Returns [param ID_pair].
func get_ID_pair() -> int:
	return ID_pair

## Sets [param ID_pair].
func set_ID_pair(new_ID_pair: int) -> void:
	ID_pair = new_ID_pair
