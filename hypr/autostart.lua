-- Autostart
hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpm reload -n")
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("setxkbmap -layout us -variant dvorak")
    
    -- Extra autostart processes via uwsm
    hl.exec_cmd("uwsm-app -- kanshi")
    hl.exec_cmd("uwsm-app -- waybar")
    hl.exec_cmd("uwsm-app -- blueman-applet")
    hl.exec_cmd("uwsm-app -- hypridle")
    hl.exec_cmd("uwsm-app -- mako")
    hl.exec_cmd("uwsm-app -- swayosd-server")
end)

-- Reloading kanshi (equivalent to exec)
hl.exec_cmd("sleep 2 && kanshictl reload")
