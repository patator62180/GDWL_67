extends Node2D

class_name Mediator

static var instance: Mediator


func _ready():
    instance = self


func call_on_server(callable, arg1 = null, arg2 = null, arg3 = null):
    if arg3 != null:
        callable.rpc_id(1, arg1, arg2, arg3)
    elif arg2 != null:
        callable.rpc_id(1, arg1, arg2)
    elif arg1 != null:
        callable.rpc_id(1, arg1)
    else:
        callable.rpc_id(1)


func call_on_players(callable, arg1 = null, arg2 = null, arg3 = null):
    if arg3 != null:
        callable.rpc(arg1, arg2, arg3)
    elif arg2 != null:
        callable.rpc(arg1, arg2)
    elif arg1 != null:
        callable.rpc(arg1)
    else:
        callable.rpc()


func call_on_player(peer_id, callable, arg1 = null, arg2 = null, arg3 = null):
    if arg3 != null:
        callable.rpc_id(peer_id, arg1, arg2, arg3)
    elif arg2 != null:
        callable.rpc_id(peer_id, arg1, arg2)
    elif arg1 != null:
        callable.rpc_id(peer_id, arg1)
    else:
        callable.rpc_id(peer_id)
