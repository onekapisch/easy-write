"""Branded dmgbuild layout. Pass app/background paths through defines."""
files = [defines["app"]]
background = defines["background"]
symlinks = {"Applications": "/Applications"}
format = "UDZO"
filesystem = "HFS+"
window_rect = ((200, 120), (660, 400))
icon_locations = {"Easy Write.app": (180, 195), "Applications": (480, 195)}
icon_size = 112
text_size = 14
default_view = "icon-view"
show_icon_preview = False

# SetFile -a E/V adds FinderInfo after signing and makes strict verification fail.
# Cosmetic layout belongs in .DS_Store, never in the signed bundle's metadata.
hide_extensions = []
hide = []
