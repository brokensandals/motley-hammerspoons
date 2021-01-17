# motley-hammerspoons

Some spoons (plugins) for [hammerspoon](https://www.hammerspoon.org).

|Spoon|Description|
|----|----|
|[ArrangeWindows](#arrangewindows)|Quickly rearrange windows into various layouts.|
|[AudioSelect](#audioselect)|Change audio device or volume using the keyboard only.|
|[CommandCatalog](#commandcatalog)|Manage a command palette and hotkeys for all your Hammerspoon commands in one place.|
|[MenuChooser](#menuchooser)|Access each application's menu as a command palette.|
|[SafariBookmarkChooser](#safaribookmark-chooser)|Access your bookmarks via a fuzzy finder.|

## Setup

First, symlink or copy the the spoons you want into your `~/.hammerspoon/Spoons` folder.
You can just run the install script to create symlinks for all of them:

```bash
git clone https://github.com/brokensandals/motley-hammerspoons.git
./install.sh
```

Then, in your `init.lua`, load the spoons you're interested in:

```lua
hs.loadSpoon("ArrangeWindows")
hs.loadSpoon("AudioSelect")
hs.loadSpoon("CommandCatalog")
hs.loadSpoon("MenuChooser")
hs.loadSpoon("SafariBookmarkChooser")
```

Then, you just need to set up some way for you to invoke the primary functions provided by each spoon.
You could bind hotkeys for each of them, but that gets hard to keep track of.

I prefer to set up a fuzzy finder for all the commands, which is what CommandCatalog is for.
If you add the following to your `init.lua`, you can press CMD+CTRL+P to get a command palette that provides access to all the functionality of these spoons.

```lua
spoon.CommandCatalog.add('go to window', spoon.ArrangeWindows.chooseWindow, 'cmd+ctrl', 'F')
spoon.CommandCatalog.add('layout windows', spoon.ArrangeWindows.chooseLayout, 'cmd+ctrl', 'L')
spoon.CommandCatalog.add('maximize window', spoon.ArrangeWindows.maximize, 'cmd+ctrl', 'M')
spoon.CommandCatalog.add('save window layout', spoon.ArrangeWindows.saveLayout)
spoon.CommandCatalog.add('clear window layouts', spoon.ArrangeWindows.clearSavedLayouts)
spoon.CommandCatalog.add('menu command palette', spoon.MenuChooser.chooseMenuItem, 'shift+cmd+ctrl', 'P')
spoon.CommandCatalog.add('bookmark palette', spoon.SafariBookmarkChooser.chooseBookmark)
spoon.CommandCatalog.add('reload hammerspoon config', hs.reload)
spoon.CommandCatalog.add('change audio output', spoon.AudioSelect.chooseAudioOutput)
spoon.CommandCatalog.add('change volume', spoon.AudioSelect.chooseAudioOutputVolume)
spoon.CommandCatalog.sortCommands()
spoon.CommandCatalog.bindCommandHotkeys()
hs.hotkey.bind("cmd+ctrl", "P", spoon.CommandCatalog.chooseCommand)
```

## ArrangeWindows

This lets you quickly rearrange all your windows to match various layouts.

Some default layouts are provided, such as two-column 50/50, two-column 60/40, or three panels with two stacked vertically on the right half of the screen.
You can also hardcode additional layouts by modifying `spoon.ArrangeWindows.layouts`.

It also supports saving the current arrangement of windows, with a given name, so that you can load it again later.
Saved layouts are currently persisted using the `hs.settings` module.

|Function name|Description|
|---|---|
|chooseLayout|Shows a fuzzy finder for selecting a layout.|
|chooseWindow|Shows a fuzzy finder full of window titles so you can choose one to switch focus to.|
|clearSavedLayouts|Forget all saved layouts.|
|maximize|maximizes the current window|
|saveLayout|Saves the current arrangement of windows to a name of your choosing.|

## AudioSelect

For configuring audio output using the keyboard.

|Function name|Description|
|---|---|
|chooseAudioOutput|Shows a fuzzy finder for selecting an audio output device by name.|
|chooseAudioOutputVolume|Provides a text input for changing the volume to a specified percentage.|

## CommandCatalog

Keeps a list of commands which can be invoked via a fuzzy finder command palette.
If you also specify a hotkey when registering the command, the hotkey will be shown in the command palette too.

|Function name|Description|
|---|---|
|add(text, fn, [hotkeyMods, hotkeys])|Registers a command.|
|bindCommandHotkeys|Should be called once after all commands are registered.|
|chooseCommand|Shows a fuzzy finder with all registered commands.|
|sortCommands|Sorts the commands alphabetically - call this after all commands are registered, if you want.|

## MenuChooser

Give every application a command palette!

|Function name|Description|
|---|---|
|chooseMenuItem|Shows a fuzzy finder containing all the menu items of the current (frontmost) application.|

## SafariBookmarkChooser

Open a bookmarked web page from anywhere.

|Function name|Description|
|---|---|
|chooseBookmark|Launches Safari and shows a fuzzy finder containing all your bookmarks.|

## License

This is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
