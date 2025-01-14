@tool
extends EditorPlugin

const PluginName = "ClaudeAPI"

var dock
const Dock: PackedScene = preload("res://addons/claude_3.5_sonnet_chat_api/dock_window.tscn")

func _enter_tree():
	if not ProjectSettings.has_setting("plugins/claude_api/api_key"):
		ProjectSettings.set_setting("plugins/claude_api/api_key", "")

	# Create a Control node to hold the ClaudePanel
	var editor = get_editor_interface()
	dock = Dock.instantiate()
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)

func _exit_tree():
	if dock:
		remove_control_from_docks(dock)
		dock.free()
