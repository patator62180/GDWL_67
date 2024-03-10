extends Control

@export var PlayerManager0: PlayerManager
@export var PlayerManager1: PlayerManager


func _ready():
    %"Score J1".material.set_shader_parameter("Shift_Hue", PlayerManager0.modulateFaceColor)
    %"Score J2".material.set_shader_parameter("Shift_Hue", PlayerManager1.modulateFaceColor)
