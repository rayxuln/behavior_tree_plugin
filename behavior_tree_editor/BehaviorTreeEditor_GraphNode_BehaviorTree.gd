tool
extends GraphNode

export(String) var type_string = "UnkownType"
export(String) var node_name = "Unkown"

var has_ready = false

func BehaviorTreeEditorGraphNode():
	pass

func _ready():
	update_name()

func _process(delta):
	if not has_ready:
		notification(NOTIFICATION_READY)
		has_ready = true

# ---------- custom methods ------
func update_name():
	title = node_name + "(" + type_string + ")"

# ---------- signals -------------
func _on_LineEdit_text_changed(new_text):
	node_name = new_text 
	update_name()
