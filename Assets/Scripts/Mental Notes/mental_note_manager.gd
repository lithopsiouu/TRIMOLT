class_name MentalMentalNoteManager
extends Node

## Contains variables that are used by [MentalNote] and [MentalQuestion] classes.
## Also creates [MentalNote] and [MentalQuestion] classes.

var starting_notes_dict = {
	"percy just got 5 phones": [Vector2(randi_range(-200, 200), randi_range(-200, 200))],
	"percy has been broke": [Vector2(randi_range(-200, 200), randi_range(-200, 200))],
	"hi percy": [Vector2(randi_range(-200, 200), randi_range(-200, 200))],
	"percy smells bad": [Vector2(randi_range(-200, 200), randi_range(-200, 200))],
}

var _mouse_hovering_areas: Array = []

var _nodes: Array = []

var note_container: Node
var question_container: Node
var connection_container: Node

func _ready() -> void:
	initialize_categories()
	
	create_initial_nodes()
	
	create_question("sooo much", Vector2(0, 0))
	
	pair_node(get_node_in_array_by_content("percy just got 5 phones", _nodes), get_node_in_array_by_content("percy has been broke", _nodes))

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("Mental_Map_Node_Grab"):
		if _mouse_hovering_areas.size() <= 0:
			return
		
		if _mouse_hovering_areas[-1] == null:
			return
		
		_mouse_hovering_areas[-1].set_following_mouse(true)
		_mouse_hovering_areas[-1].get_parent().move_child(_mouse_hovering_areas[-1], -1)

## Creates containers for each type of [MentalNode].
func initialize_categories() -> void:
	note_container = Node.new()
	question_container = Node.new()
	connection_container = Node.new()
	add_child(note_container)
	add_child(question_container)
	add_child(connection_container)
	note_container.name = "mental_note_container"
	question_container.name = "mental_questions_container"
	connection_container.name = "mental_connection_container"

func create_initial_nodes() -> void:
	for i in starting_notes_dict:
		create_note(i, starting_notes_dict[i][0])

## Creates a [MentalNote] and sets the ID, content, and tags.
func create_note(content: String, pos: Vector2 = Vector2.ZERO, tags: Array = [MentalNodeData.TAGS[0]]) -> void:
	var note = MentalNote.new()
	note_container.add_child(note)
	note.name = content
	note.position = pos
	
	mental_node_setup(note, _nodes, content, tags)

## Creates a [MentalQuestion] and sets the ID, content, and tags.
func create_question(content: String, pos: Vector2 = Vector2.ZERO, tags: Array = [MentalNodeData.TAGS[0]]) -> void:
	var question = MentalQuestion.new()
	question_container.add_child(question)
	question.name = content
	question.position = pos
	
	mental_node_setup(question, _nodes, content, tags)


## Creates a [MentalConnection], sets the ID, content, and tags, and destroys the [MentalNote] and [MentalQuestion] pair.
func create_connection(content: String, pos: Vector2 = Vector2.ZERO, tags: Array = [MentalNodeData.TAGS[0]]) -> void:
	var connection = MentalConnection.new()
	connection_container.add_child(connection)
	connection.name = content
	
	mental_node_setup(connection, _nodes, content, tags)

## Adds a node pair to the [param node] and optionally sets the pair for the [param node_pair].
func pair_node(node, node_pair, pair_both: bool = true):
	if node == null:
		return
	node.append_ID_pair(node_pair.get_ID())
	
	print(node, node.get_ID())
	print(node_pair, node_pair.get_ID())
	
	if pair_both:
		node_pair.append_ID_pair(node.get_ID())

func get_node_in_array_by_content(content: String, array: Array):
	for item in array:
		if content == item.get_content():
			return item
	return null

## Deletes a pair of [MentalNode]s.
func destroy_pair(node1, node2) -> void:
	create_connection("percy stole fones")
	remove_mouse_hovering_areas(node1)
	remove_mouse_hovering_areas(node2)
	print("destroying ", node1)
	node1.queue_free()
	print("destroying ", node2)
	node2.queue_free()

## Sets the content of a given mental node.
func mental_node_setup(node, array: Array, content: String, tags: Array):
	if array.find(node) == -1:
		array.append(node)
	
	node.set_ID(array.find(node))
	node.set_content(content)
	node.set_tags(tags)
	
	node.mouse_over.connect(insert_mouse_hovering_areas)
	node.mouse_off.connect(remove_mouse_hovering_areas)
	node.connected.connect(destroy_pair)

func insert_mouse_hovering_areas(node):
	_mouse_hovering_areas.insert(0, node)

func remove_mouse_hovering_areas(node):
	_mouse_hovering_areas.erase(node)

## Returns a tag if [param tag_name] is in [param TAGS], otherwise returns [code]""[/code].
func get_tag_from_name(tag_name: String) -> String:
	tag_name = tag_name.to_lower()
	var found_tag: String = ""
	for tag in MentalNodeData.TAGS:
		if tag_name == tag:
			found_tag = tag
	return found_tag
