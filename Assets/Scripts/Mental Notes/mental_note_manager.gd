class_name MentalMentalNoteManager
extends Node

## Contains variables that are used by [MentalNote] and [MentalQuestion] classes.
## Also creates [MentalNote] and [MentalQuestion] classes.

const TAGS: Array[String] = [
	"unsorted",
	"me",
	"drew"
]

var _notes: Array = []
var _questions: Array = []
var _connections: Array = []

var notes: Node
var questions: Node
var connections: Node

func _ready() -> void:
	initialize_categories()
	
	create_note("bababa")
	create_note("poooop")

func initialize_categories() -> void:
	notes = Node.new()
	questions = Node.new()
	connections = Node.new()
	add_child(notes)
	add_child(questions)
	add_child(connections)
	notes.name = "mental_notes"
	questions.name = "mental_questions"
	connections.name = "mental_connections"

## Creates a [MentalNote] and sets the ID, content, and tags.
func create_note(content: String, tags: Array = [TAGS[0]]) -> void:
	var note = MentalNote.new()
	notes.add_child(note)
	note.name = content
	
	_notes.append(note)
	
	note.set_ID(_notes.find(note))
	note.set_content(content)
	note.set_tags(tags)

## Creates a [MentalQuestion] and sets the ID, content, and tags.
func create_question(content: String, tags: Array = [TAGS[0]]) -> void:
	var question = MentalQuestion.new()
	questions.add_child(question)
	question.name = content
	
	_questions.append(question)
	
	question.set_ID(_questions.find(question))
	question.set_content(content)
	question.set_tags(tags)

## Creates a [MentalConnection], sets the ID, content, and tags, and destroys the [MentalNote] and [MentalQuestion] pair.
func create_connection(content: String, tags: Array = [TAGS[0]]) -> void:
	var connection = MentalQuestion.new()
	connections.add_child(connection)
	connection.name = content
	
	_connections.append(connection)
	
	connection.set_ID(_connections.find(connection))
	connection.set_content(content)
	connection.set_tags(tags)

## Deletes a paired [MentalNote] and [MentalQuestion].
func destroy_pair() -> void:
	pass

## Returns a tag if [param tag_name] is in [param TAGS], otherwise returns [code]""[/code].
func get_tag_from_name(tag_name: String) -> String:
	tag_name = tag_name.to_lower()
	var found_tag: String = ""
	for tag in TAGS:
		if tag_name == tag:
			found_tag = tag
	return found_tag
