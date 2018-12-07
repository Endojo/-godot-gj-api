tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("GameJoltAPI", "HTTPRequest", preload("res://addons/GameJolt_API_1_2/gj_api.gd"), preload("res://addons/GameJolt_API_1_2/gj_icon.png"))

func _exit_tree():
	remove_custom_type("GameJoltAPI")