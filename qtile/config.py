# Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

from typing import List  # noqa: F401

from libqtile import bar, layout, widget, qtile
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal
from libqtile import hook
import os
import subprocess

USERNAME = os.getlogin()
CONFIG_HOME = f'/home/{USERNAME}/NixOS_DotFiles/'

@hook.subscribe.startup_once
def autostart():
    home = (CONFIG_HOME + 'qtile/autostart.sh')
    subprocess.call([home])

mod = "mod4"
terminal = "alacritty"
browser = "firefox"
launcher = "ulauncher"

colors = [["#25503d", "#25503d"], # background
          ["#161817", "#161817"], # background alt
          ["#ffffff", "#ffffff"], # white
          ["#ff5555", "#ff5555"], # white alt
          ["#797FD4", "#797FD4"], # violet
          ["#89aaff", "#89aaff"], # blue
          ["#89ddff", "#89ddff"], # ice
          ["#E05F27", "#E05F27"], # orange
          ["#1f2825", "#1f2825"], # green
          ["#1a2423", "#1a2423"], # Bottom Bar Background  
          ["#ff1817", "#ff1817"]] # red



keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html

    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(),
        desc="Move window focus to other window"),

    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(),
        desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(),
        desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(),
        desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    Key([mod, "shift"], "space", lazy.client_to_next(),
        desc="Move window client to other stack"),

    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.grow_left(),
        desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(),
        desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(),
        desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),

    Key([mod, "shift"], "Return", lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack"),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    Key([mod], "b", lazy.spawn(browser), desc="Launch Firefox"),
    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "w", lazy.window.kill(), desc="Kill focused window"),

    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "r", lazy.spawn(launcher), desc="Launch launcher"),
    # programs
    Key([mod], "c", lazy.spawn("code"), desc="Launch VSCode"),
    Key([mod], "f", lazy.spawn("thunar"), desc="Launch File Manager"),
    Key([mod], "o", lazy.spawn(f"appimage-run /home/{USERNAME}/app_images/Obsidian-1.0.0.AppImage"), desc="Launch Obsidian"),
    # Screenshots
    Key([], "Print", lazy.spawn("flameshot gui --clipboard"), desc="Flameshot Capture to Clipboard"),
    # OS level commands/menus    
    Key([mod, "control"], "s", lazy.spawn(f'rofi -show power-menu -modi power-menu:{CONFIG_HOME}qtile/scripts/rofi-power-menu'), desc="Shutdown Menu"),
    Key([mod, "control"], "b", lazy.spawn(f'{CONFIG_HOME}qtile/scripts/rofi-bluetooth.sh'), desc="Buetooth Menu"),
    
    # Volume Control
    Key(
        [], "XF86AudioRaiseVolume",
        lazy.spawn("amixer -c 0 -q set Master 2dB+")
    ),
    Key(
        [], "XF86AudioLowerVolume",
        lazy.spawn("amixer -c 0 -q set Master 2dB-")
    ),
    Key(
        [], "XF86AudioMute",
        lazy.spawn("amixer set Master 1+ toggle")
    ),


]

group_names = [("WWW", {'layout': 'monadtall'}),
               ("DEV", {'layout': 'columns'}),
               ("SYS", {'layout': 'monadtall'}),
               ("DOC", {'layout': 'monadtall'}),
               ("GFX", {'layout': 'max'})]

groups = [Group(name, **kwargs) for name, kwargs in group_names]

for i, (name, kwargs) in enumerate(group_names, 1):
    keys.append(Key([mod], str(i), lazy.group[name].toscreen()))        # Switch to another group
    keys.append(Key([mod, "shift"], str(i), lazy.window.togroup(name))) # Send current window to another group

layouts = [
    layout.Columns(
        border_focus_stack='#71b18e', 
        border_focus = '#71b18e',
        border_normal = '#486156',
        margin = 8),
    layout.Max(),
    layout.MonadTall(
        border_focus_stack='#71b18e', 
        border_focus = '#71b18e',
        border_normal = '#486156',
        margin = 8
    ),    

    # Try more layouts by unleashing below layouts.
    layout.Stack(
        num_stacks=2,
        border_focus_stack='#71b18e', 
        border_focus = '#71b18e',
        border_normal = '#486156',
        margin = 8
        )        ,
    # layout.Bsp(),
    # layout.Matrix(),
    # layout.MonadTall(),
    # layout.MonadWide(),
    # layout.RatioTile(),
    # layout.Tile(),
    layout.TreeTab(
        border_focus_stack='#71b18e', 
        border_focus = '#71b18e',
        border_normal = '#486156',
        margin = 8),
    # layout.VerticalTile(),
    # layout.Zoomy(),
]

widget_defaults = dict(
    font='sans',
    fontsize=20,
    padding=3,
)
extension_defaults = widget_defaults.copy()

screens = [
    Screen(
        top=bar.Bar(
            [
                widget.TextBox(
                    text = '  ',
                    background = colors[0]

                ),
                widget.CurrentLayoutIcon(
                    background = colors[0],
                    padding = 3,
                ),
                widget.TextBox(
                    text = '  ',
                    background = colors[0]

                ),
                widget.GroupBox(
                    background = colors[0],
                    inactive = '000000',
                    highlight_method = 'line',
                    this_current_screen_border = colors[0],
                    highlight_color = ['000000', '282828'],
                ),
                widget.TextBox(
                    text = '  ',
                    background = colors[0]

                ),
                widget.Prompt(
                    background = colors[0],
                ),
                widget.WindowName(background = colors[8],),
                widget.Chord(
                    chords_colors={
                        'launch': ("#ff0000", "#ffffff"),
                    },
                    name_transform=lambda name: name.upper(),
                ),
                widget.TextBox(
                    text = '  ',
                    background = colors[0]

                ),
                widget.OpenWeather(
                    coordinates={"longitude": "-85.8725477","latitude": "34.1729504"},
                    app_key = 'd2cb97d17b9e98fb58a98e2944a748ca',
                    metric = False,
                    format = '{main_temp}°{units_temperature} {humidity}% {weather_details}',
                    background = colors[0],
                    mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn('kitty sh -c "curl wttr.in/gadsden?u; read"')},
                ),
                widget.TextBox(
                    text = '  ',
                    background = colors[0]

                ),
                widget.Clock(format='%Y-%m-%d %a %I:%M %p',
                    background = colors[0],),
                widget.TextBox(
                    text = '  ',
                    background = colors[0]

                ),
                widget.TextBox(
                    text = '⏻',
                    background = colors[0],
                    padding = 0,
                    fontsize = 24,
                    mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn(f'rofi -show power-menu -modi power-menu:{CONFIG_HOME}qtile/scripts/rofi-power-menu')},
                ),
                widget.TextBox(
                    text = '  ',
                    background = colors[0]

                ),
            ],
            24,
            opacity=.8,

        ),
        bottom=bar.Bar(
            [
                widget.TextBox(
                    text = '  ',
                    background = colors[0]

                ),
                widget.Systray(
                    background = colors[0],
                    icon_size = 23
                ),
                widget.TextBox(
                    text = '  ',
                    background = colors[0]

                ),
                widget.Spacer(background=colors[9]),
                widget.TextBox(
                    text = '  ',
                    background = colors[0]

                ),
                widget.Battery(
                    battery="BAT0",
                    format="BAT:{percent:2.0%}",
                    show_short_text = False,
                    background = colors[0]
                ),
                widget.TextBox(
                    text = '  ',
                    background = colors[0]

                ),
                widget.CPU(
                    background = colors[0],
                    mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn('kitty -e "glances"')},
                ),
                widget.TextBox(
                    text = '  ',
                    background = colors[0]

                ),
                widget.TextBox(
                    text = " MEM:",
                    background = colors[0],
                    padding = 0,
                    mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn('kitty -e "glances"')},
                    ),
                widget.Memory(
                    background = colors[0],
                    mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn('kitty -e "glances"')},
                ),
                widget.TextBox(
                    text = '  ',
                    background = colors[0]

                ),
                widget.TextBox(
                    text = " HDD:",
                    background = colors[0],
                    padding = 0,
                    mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn('thunar')},
                ),
                widget.DF(
                    format ='{f}{m}/{s}{m}',
                    visible_on_warn  = False,
                    background = colors[0],
                    mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn('thunar')},
                ),
                widget.TextBox(
                    text = '  ',
                    background = colors[0]

                ),
                widget.Net(
                    format = 'NET:{down} ↓↑ {up}',
                    background = colors[0]
                ),
                widget.TextBox(
                    text = '  ',
                    background = colors[0]

                ),
                widget.TextBox(
                    text = " VOL:",
                    background = colors[0],
                    padding = 0,
                    mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn('pavucontrol')},
                ),
                widget.Volume(
                    background = colors[0],
                    mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn('pavucontrol')},
                ),
                widget.TextBox(
                    text = '  ',
                    background = colors[0]

                ),
                widget.TextBox(
                      text = " Bluetooth",
                       background = colors[0],
                       padding = 0,
                    mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn(f'{CONFIG_HOME}qtile/scripts/rofi-bluetooth.sh')},
                       ),
                widget.TextBox(
                    text = '  ',
                    background = colors[0]

                ),                
            ],
            24,
            opacity=.8,            
        ),
    ),
]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(),
         start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(),
         start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front())
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: List
follow_mouse_focus = False
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(float_rules=[
    # Run the utility of `xprop` to see the wm class and name of an X client.
    *layout.Floating.default_float_rules,    
    Match(wm_class='confirmreset'),  # gitk
    Match(wm_class='makebranch'),  # gitk
    Match(wm_class='maketag'),  # gitk
    Match(wm_class='ssh-askpass'),  # ssh-askpass
    Match(title='branchdialog'),  # gitk
    Match(title='pinentry'),  # GPG key password entry
    Match(wm_class='tlp-ui'),  
    Match(wm_class='pavucontrol'),  
    Match(wm_class='ulauncher'),
    Match(wm_class='ffxiv_dx11.exe'),
    Match(wm_class='kitty'),
    # Match(wm_class='launcher.exe'),
    ],
    border_width=0,
    max_border_width=0,
    fullscreen_border_width=0,

)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

wmname = "LG3D"
