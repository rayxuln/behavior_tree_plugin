tool
extends GraphNode

var editor
var resource
var resource_data

onready var script_data:BehaviorTreeScriptDataResource = BehaviorTreeScriptDataResource.new()

func _on_type_string_get():
	if resource:
		return resource.node_type_to_string(resource_data["type"])
	return "UnkownType"
func _on_node_name_get():
	if resource_data:
		return resource_data["name"]
	return "Unkown"

var has_ready = false

func BehaviorTreeEditorGraphNode():
	pass

func _ready():
	if resource_data:
		$HBoxContainer/LineEdit.text = resource_data["name"]
	update_name()
	
	script_data.graph_node = self
	
	$HBoxContainer2/ConcurrentModeOptionButton.clear()
	$HBoxContainer2/ConcurrentModeOptionButton.add_item("And", 0)
	$HBoxContainer2/ConcurrentModeOptionButton.add_item("Or", 1)
	
	$HBoxContainer3/ConditionModeOptionButton.clear()
	$HBoxContainer3/ConditionModeOptionButton.add_item("All", 0)
	$HBoxContainer3/ConditionModeOptionButton.add_item("Any", 1)
	
	
	update_concurrent_mode_option_button()
	update_condition_mode_option_button()

func _process(delta):
	if not has_ready:
		notification(NOTIFICATION_READY)
		has_ready = true

# ---------- custom methods ------
func update_name():
	title = _on_node_name_get() + "(" + _on_type_string_get() + ")"

func update_concurrent_mode_option_button():
	if resource_data:
		$HBoxContainer2/ConcurrentModeOptionButton.selected = resource_data["concurrent_mode"]

func update_condition_mode_option_button():
	if resource_data:
		$HBoxContainer3/ConditionModeOptionButton.selected = resource_data["condition_mode"]

func disconnect_to_others():
	var e:GraphEdit = get_parent()
	#{ from_port: 0, from: "GraphNode name 0", to_port: 1, to: "GraphNode name 1" }.
	for c in e.get_connection_list():
		if c["from"] == name:
			e.disconnect_node(c["from"], c["from_port"], c["to"], c["to_port"])
		if c["to"] == name:
			e.disconnect_node(c["from"], c["from_port"], c["to"], c["to_port"])

# ---------- signals -------------
func _on_LineEdit_text_changed(new_text):
	if resource_data:
		resource_data["name"] = new_text
	update_name()
	if editor:
		editor.refresh_inspetor()


func _on_BehaviorTreeNode_close_request():
	script_data.unreference()
	disconnect_to_others()
	editor.update_connections_in_resource()
	resource.remove_node(resource_data)
	editor.refresh_inspetor()
	get_parent().remove_child(self)
	queue_free()


func _on_BehaviorTreeNode_dragged(from, to):
	resource_data["position"] = offset


func _on_LinkButton_pressed():
	editor.the_plugin.script_select_dialog.connect("file_selected", self, "_on_script_file_selected")
	editor.the_plugin.script_select_dialog.popup_centered()

func _on_selected():
	var editor_interface:EditorInterface = editor.the_plugin.get_editor_interface()
	editor_interface.inspect_object(script_data)


func _on_ConcurrentModeOptionButton_item_selected(id):
	resource_data["concurrent_mode"] = id


func _on_ConditionModeOptionButton_item_selected(id):
	resource_data["condition_mode"] = id
