extends Control


func _ready():
    if not OS.has_feature('dedicated_server'):
        %"Score J1".material.set_shader_parameter("Shift_Hue", get_parent().PlayerManager0.modulateFaceColor)
        %"Score J2".material.set_shader_parameter("Shift_Hue", get_parent().PlayerManager1.modulateFaceColor)
