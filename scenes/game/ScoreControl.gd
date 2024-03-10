extends Control


func _ready():
    %"Score J1".material.set_shader_parameter("Shift_Hue", get_parent().PlayerManagers.array[0].modulateFaceColor)
    %"Score J2".material.set_shader_parameter("Shift_Hue", get_parent().PlayerManagers.array[1].modulateFaceColor)
