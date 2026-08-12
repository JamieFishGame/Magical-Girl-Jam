@tool
extends EditorPlugin


func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	add_custom_type("AfterImage2D", "Node2D", preload("./data/AfterImage2D.gd"), preload("./data/AfterImage2D.png"))


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_custom_type("AfterImage2D")
