extends Node2D

class_name Mediator

static var instance: Mediator

signal on_peer_player_join

var is_couch = false

func _ready():
	instance = self

func is_player():
	return is_couch or (multiplayer and not multiplayer.is_server())

func is_server(include_couch=true):
	return (include_couch and is_couch) or (not is_couch and multiplayer and multiplayer.is_server())

func call_on_server(callable, arg1 = null, arg2 = null, arg3 = null):
	if is_couch:
		if arg3 != null:
			callable.call(arg1, arg2, arg3)
		elif arg2 != null:
			callable.call(arg1, arg2)
		elif arg1 != null:
			callable.call(arg1)
		else:
			callable.call()
	else:
		if arg3 != null:
			callable.rpc_id(1, arg1, arg2, arg3)
		elif arg2 != null:
			callable.rpc_id(1, arg1, arg2)
		elif arg1 != null:
			callable.rpc_id(1, arg1)
		else:
			callable.rpc_id(1)


func call_on_players(callable, arg1 = null, arg2 = null, arg3 = null):
	if is_couch:
		if arg3 != null:
			callable.call(arg1, arg2, arg3)
		elif arg2 != null:
			callable.call(arg1, arg2)
		elif arg1 != null:
			callable.call(arg1)
		else:
			callable.call()
	else:
		if arg3 != null:
			callable.rpc(arg1, arg2, arg3)
		elif arg2 != null:
			callable.rpc(arg1, arg2)
		elif arg1 != null:
			callable.rpc(arg1)
		else:
			callable.rpc()


func call_on_player(peer_id, callable, arg1 = null, arg2 = null, arg3 = null):
	if is_couch:
		if arg3 != null:
			callable.call(arg1, arg2, arg3)
		elif arg2 != null:
			callable.call(arg1, arg2)
		elif arg1 != null:
			callable.call(arg1)
		else:
			callable.call()
	else:
		if arg3 != null:
			callable.rpc_id(peer_id, arg1, arg2, arg3)
		elif arg2 != null:
			callable.rpc_id(peer_id, arg1, arg2)
		elif arg1 != null:
			callable.rpc_id(peer_id, arg1)
		else:
			callable.rpc_id(peer_id)

func listen_peer_player_connection(callable):
	if is_couch:
		callable.call(0)
		callable.call(1)
	else:
		Immersive.client.peer_player_joined.connect(callable)
