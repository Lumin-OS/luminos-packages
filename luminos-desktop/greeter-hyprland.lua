-- The login screen: regreet inside a Hyprland of its own, which
-- luminos-greeter starts for greetd. When regreet exits after a login,
-- this Hyprland exits too, and greetd starts the user's session.

-- The keyboard layout chosen in Dawn, from where it keeps it: the file
-- `localectl set-x11-keymap` writes. A password typed here then uses the
-- same layout as the desktop.
local function x11_keyboard()
    local file = io.open("/etc/X11/xorg.conf.d/00-keyboard.conf", "r")
    if not file then
        return nil, nil
    end
    local text = file:read("a")
    file:close()
    return text:match('Option%s+"XkbLayout"%s+"([^"]*)"'),
           text:match('Option%s+"XkbVariant"%s+"([^"]*)"')
end

local layout, variant = x11_keyboard()

hl.config({
    input = {
        kb_layout  = layout or "us",
        kb_variant = variant or "",
    },
    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        force_default_wallpaper  = 0,
    },
})

hl.on("hyprland.start", function()
    hl.exec_cmd("regreet --config /usr/share/luminos-desktop/greeter/regreet.toml"
        .. " --style /usr/share/luminos-desktop/greeter/regreet.css;"
        .. " hyprctl dispatch 'hl.dsp.exit()'")
end)
