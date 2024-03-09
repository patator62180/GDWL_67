extends Node2D

class_name Immersive

enum Modes {ONLINE, LOCAL}

@export_subgroup("Setup")
@export var client_start_scene: PackedScene
@export var server_start_scene: PackedScene
@export var local_server_uri: String = 'ws://127.0.0.1'
@export var local_immersive_api: String = 'http://127.0.0.1:8000'
@export var remote_server_uri: String
@export var remote_immersive_api: String

@export_subgroup("Internal")
@export var http_request: HTTPRequest
@export var boot_menu: Control
@export var start_as_fake_local_player_button: Button
@export var start_as_fake_server_button: Button
@export var start_as_immersive_local_player_button: Button
@export var start_as_remote_player_button: Button
@export var infos_box: Control
@export var instance_label: Label
@export var extra_info_label: Label

class Client:
    const LOCAL_CODE = 'FAKE'
    const LOCAL_PORT = 4000
    
    signal joined
    signal hosted
    signal peer_player_joined

    var immersive_url: String
    var game_instances_host: String
    var port
    var mode: Modes = Modes.ONLINE
    var request_callback
    var server_certs_file
    var server_key_file
    var game_room_code
    var multiplayer: MultiplayerAPI
    var http_request: HTTPRequest
    var is_server: bool
    var is_local: bool
    var is_faking_requests: bool
    var players_count: int
    var local_server_uri: String
    var local_immersive_api: String
    var remote_server_uri: String
    var remote_immersive_api: String

    var is_player: bool:
        get:
            return not is_server
    
    func on_request_completed(result, response_code, headers, body):
        if request_callback:
            var json = JSON.new()
            json.parse(body.get_string_from_utf8())
            var response = json.get_data()        
            request_callback.call(result, response_code, headers, response)
            request_callback = null

    func request(path, method, body = null, callback = null):
        var headers = ["Content-Type: application/json"]
        request_callback = callback
        http_request.request(immersive_url + path, headers, method, JSON.stringify(body) if body else '')

    func on_game_joined(id: int):
        joined.emit(game_room_code, id)

    func on_game_room_info_received(_result, _response_code, _headers, response):
        var peer = WebSocketMultiplayerPeer.new()
        game_room_code = response['code']
        peer.peer_connected.connect(on_game_joined)
        peer.create_client(game_instances_host + ':' + str(response['port']))
        multiplayer.multiplayer_peer = peer

    func starts_playing():
        if not is_faking_requests:
            request('/game-instances/%s/' % game_room_code, HTTPClient.METHOD_PUT, {'status': 'playing'})

    func book_game_room(game_name: String):
        if is_local and is_faking_requests:
            on_game_room_info_received(null, null, null, {'code': LOCAL_CODE, 'port': LOCAL_PORT})
        else:
            request('/game-instances/', HTTPClient.METHOD_POST, {'name': game_name}, on_game_room_info_received)

    func on_peer_player_joined(id: int):
        peer_player_joined.emit(id)
        players_count += 1

        if not is_faking_requests:
            request('/game-instances/%s/' % game_room_code, HTTPClient.METHOD_PUT, {'connected_players': players_count})

    func on_peer_player_left(id: int):
        players_count -= 1

        if not is_faking_requests:
            request('/game-instances/%s/' % game_room_code, HTTPClient.METHOD_PUT, {'connected_players': players_count})

    func host_game_room(port: int):
        var server_tls_options = null

        if server_certs_file and server_key_file:
            var server_certs = X509Certificate.new()
            var server_key = CryptoKey.new()
            
            server_key.load(server_key_file)
            server_certs.load(server_certs_file)
            server_tls_options = TLSOptions.server(server_key, server_certs)
        
        var peer = WebSocketMultiplayerPeer.new()
    
        if peer.create_server(port, '*', server_tls_options) == OK:
            peer.peer_connected.connect(on_peer_player_joined)
            peer.peer_disconnected.connect(on_peer_player_left)
            multiplayer.multiplayer_peer = peer
            request('/game-instances/%s/' % game_room_code, HTTPClient.METHOD_PUT, {'status': 'ready'})
            hosted.emit()

    func join_game_room(code: String):
        if is_local and is_faking_requests:
            on_game_room_info_received(null, null, null, {'code': LOCAL_CODE, 'port': LOCAL_PORT})
        else:        
            request('/game-instances/%s/' % code, HTTPClient.METHOD_GET, null, on_game_room_info_received)

    func parse_args():
        var args = Array(OS.get_cmdline_args())

        for arg in args:
            if arg.begins_with('--immersive-url='):
                immersive_url = arg.split('=')[1]
            elif arg.begins_with('--port='):
                port = int(arg.split('=')[1])
            elif arg.begins_with('--server-certs-file'):
                server_certs_file = arg.split('=')[1]
            elif arg.begins_with('--server-key-file'):
                server_key_file = arg.split('=')[1]
            elif arg.begins_with('--code'):
                game_room_code = arg.split('=')[1]
    
    func start(is_server: bool, is_local: bool, is_faking_requests: bool):
        self.is_server = is_server
        self.is_local = is_local
        self.is_faking_requests = is_faking_requests

        immersive_url = local_immersive_api if is_local else remote_immersive_api
        game_instances_host =  local_server_uri if is_local else remote_server_uri

        parse_args()
        
        if is_server:
            host_game_room(LOCAL_PORT if is_local else port)
    
    func _init(
            http_request: HTTPRequest,
            multiplayer: MultiplayerAPI,
            local_server_uri: String,
            local_immersive_api: String,
            remote_server_uri: String,
            remote_immersive_api: String):
        self.http_request = http_request
        self.multiplayer = multiplayer
        self.local_server_uri = local_server_uri
        self.local_immersive_api = local_immersive_api
        self.remote_server_uri = remote_server_uri
        self.remote_immersive_api = remote_immersive_api        

static var client: Client

func _ready():
    infos_box.visible = false
    extra_info_label.text = ''
    client = Client.new(http_request, multiplayer, local_server_uri, local_immersive_api, remote_server_uri, remote_immersive_api)
    start_as_fake_local_player_button.pressed.connect(func (): start(false, true, true))
    start_as_fake_server_button.pressed.connect(func (): start(true, true, true))
    start_as_immersive_local_player_button.pressed.connect(func (): start(false, true, false))
    start_as_remote_player_button.pressed.connect(func (): start(false, false, false))
    client.joined.connect(on_game_room_joined)
    
    http_request.request_completed.connect(on_request_completed)
    

    if OS.has_feature('dedicated_server'):
        start(true, false, false)
    elif OS.has_feature('editor'):
        boot_menu.visible = true
    else:
        start(false, false, false)

func on_request_completed(result, response_code, headers, body):
    if client:
        client.on_request_completed(result, response_code, headers, body)

func restart_client():
    if client:
        if client.joined.is_connected(on_game_room_joined):
            client.joined.disconnect(on_game_room_joined)
        
        var new_client = Client.new(http_request, multiplayer, local_server_uri, local_immersive_api, remote_server_uri, remote_immersive_api)
        new_client.joined.connect(on_game_room_joined)
        new_client.start(client.is_server, client.is_local, client.is_faking_requests)
        
        client = new_client


func start(is_server: bool, is_local: bool, is_faking_requests: bool):
    client.start(is_server, is_local, is_faking_requests)
    boot_menu.visible = false
    infos_box.visible = true
    instance_label.text = 'Server' if is_server else 'Player'
    var start_scene = server_start_scene if is_server else client_start_scene
    
    add_child(start_scene.instantiate())

func on_game_room_joined(room_code: String, id: int):
    extra_info_label.text = 'Room %s' % room_code
