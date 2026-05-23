-- Input configuration
hl.config({
    input = {
        kb_options = "caps:escape",
        kb_layout = "us",
        kb_variant = "dvorak",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = true,
            clickfinger_behavior = 1
        }
    }
})

-- Gesture bind (matches original 'gesture = 3, horizontal, workspace')
hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

-- Per-device config
hl.config({
    device = {
        {
            name = "epic-mouse-v1",
            sensitivity = -0.5
        }
    }
})
