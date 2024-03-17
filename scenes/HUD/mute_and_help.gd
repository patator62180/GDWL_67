extends CanvasLayer

@export var mute_button_music : BaseButton
@export var mute_button_sfx : BaseButton
@export var help_button : TextureButton
@export var help_panel : Panel

signal mute_music

func _ready():
    mute_button_music.toggled.connect(_on_mute_sound_toggled)
    mute_button_sfx.toggled.connect(_on_mute_sfx_toggled)    
    help_button.toggled.connect(on_help_toggled)


func _on_mute_sound_toggled(toggled_on):
    if toggled_on:
        AudioServer.set_bus_mute(1, true)
    else: AudioServer.set_bus_mute(1, false)
    
func _on_mute_sfx_toggled(toggled_on):
    if toggled_on:
        AudioServer.set_bus_mute(2, true)
    else: AudioServer.set_bus_mute(2, false)

func on_help_toggled(toggled_on):
    if toggled_on:
        help_panel.visible = true
    else: help_panel.visible = false
