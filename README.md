# motley-hammerspoons

Some spoons for [hammerspoon](https://www.hammerspoon.org).

## Installation

This will create a symlink for each spoon inside your `~/.hammerspoon/Spoons` folder:

```bash
git clone https://github.com/brokensandals/motley-hammerspoons.git
./install.sh
```

(Alternatively, just symlink or copy the individual spoons you want.)

## ArrangeWindows

This lets you quickly rearrange all your windows to match various layouts.

Some default layouts are provided, such as two-column 50/50, two-column 60/40, or three panels with two stacked vertically on the right half of the screen.
You can also hardcode additional layouts by modifying `spoon.ArrangeWindows.layouts`.

It also supports saving the current arrangement of windows, with a given name, so that you can load it again later.
Saved layouts are currently persisted using the `hs.settings` module.

Some tangentially-related functionality is also provided:

- Maximize current window
- Show a fuzzy finder of all window titles, then go to the one you select

Example bindings:

```lua
hs.loadSpoon("ArrangeWindows")
hs.hotkey.bind("cmd+ctrl", "M", spoon.ArrangeWindows.maximize, "maximize current window")
hs.hotkey.bind("cmd+ctrl", "L", spoon.ArrangeWindows.chooseLayout, "layout windows")
hs.hotkey.bind("cmd+ctrl", "F", spoon.ArrangeWindows.chooseWindow, "go to window")
hs.hotkey.bind("shift+cmd+ctrl", "S", spoon.ArrangeWindows.saveLayout, "save layout")
hs.hotkey.bind("shift+cmd+ctrl", "C", spoon.ArrangeWindows.clearSavedLayouts, "clear saved layouts")
```

## License

This is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
