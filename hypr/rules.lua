-- Window Rules
hl.window_rule({
    name = "suppress-maximize",
    match = { class = ".*" },
    suppress_event = "maximize"
})

hl.window_rule({
    name = "1password-float",
    match = { class = "1password", initial_title = "1Password" },
    float = true
})

hl.window_rule({
    name = "fix-xwayland-drags",
    match = { 
        class = "^$", 
        title = "^$", 
        xwayland = true, 
        float = true, 
        fullscreen = false, 
        pin = false 
    },
    no_focus = true
})

-- VR stuff
hl.window_rule({ name = "vr-immediate-1", match = { class = "^(steamvr)$" }, immediate = true })
hl.window_rule({ name = "vr-immediate-2", match = { class = "^(vrcompositor)$" }, immediate = true })
hl.window_rule({ name = "vr-immediate-3", match = { class = "^(vrmonitor)$" }, immediate = true })

-- JetBrains
hl.window_rule({
    name = "jetbrains-tag",
    match = { class = "^(jetbrains-.*)$", title = "^$", float = true },
    tag = "+jbw"
})
hl.window_rule({ name = "jetbrains-no-anim", match = { tag = "jbw" }, no_anim = true })

-- Others
hl.window_rule({ name = "nwg-displays-float", match = { class = "^(nwg-displays)$" }, float = true })
hl.window_rule({ name = "gamescope-float", match = { class = "^(gamescope)$" }, float = true })
hl.window_rule({ name = "steam-settings-float", match = { title = "^(Steam Settings)$" }, float = true })

hl.window_rule({
    name = "gcr-prompter-stay-focused",
    match = { class = "^gcr-prompter$", title = "^Unlock Login Keyring$", float = true },
    stay_focused = true
})
