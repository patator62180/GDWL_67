extends CanvasLayer

@export var mute_button : BaseButton
@export var help_button : TextureButton
@export var help_panel : Panel

signal mute_music

func _ready():
    mute_button.toggled.connect(_on_mute_sound_toggled)
    help_button.toggled.connect(on_help_toggled)


func _on_mute_sound_toggled(toggled_on):
    if toggled_on:
        AudioServer.set_bus_mute(0, true)
    else: AudioServer.set_bus_mute(0, false)
    
func on_help_toggled(toggled_on):
    if toggled_on:
        help_panel.visible = true
    else: help_panel.visible = false
