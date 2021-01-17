local obj = {}
obj.__index = obj

-- Metadata
obj.name = "CommandCatalog"
obj.version = "0.0.1"
obj.author = "Jacob Williams <jacobaw@gmail.com>"
obj.license = "MIT - https://opensource.org/licenses/MIT"
obj.homepage = "https://github.com/brokensandals/motley-hammerspoons"

--- CommandCatalog.commands
--- Variable
--- A list of command specs. Each element is a table containing:
---   text = string display name for the command
---   fn = function to call to invoke the command
---   hotkeyMods = optionally, modifiers for the hotkey
---   hotkey = optionally, a hotkey to bind this command to
obj.commands = {}

--- CommandCatalog.add(text, fn, [hotkeyMods, hotkey])
--- Function
--- Adds a command to CommandCatalog.commands.
function obj.add(text, fn, hotkeyMods, hotkey)
  obj.commands[#obj.commands+1] = {text = text, fn = fn, hotkeyMods = hotkeyMods, hotkey = hotkey}
end

--- CommandCatalog.bindCommandHotkeys()
--- Function
--- Binds all hotkeys specified in CommandCatalog.commands.
function obj.bindCommandHotkeys()
  for _,cmd in ipairs(obj.commands) do
    if cmd.hotkey then
      hs.hotkey.bind(cmd.hotkeyMods, cmd.hotkey, cmd.text, cmd.fn)
    end
  end
end

--- CommandCatalog.sortCommands()
--- Function
--- Sorts commands alphabetically.
function obj.sortCommands()
  table.sort(obj.commands, function(a, b) return a.text < b.text end)
end

--- CommandCatalog.chooseCommand()
--- Function
--- Shows a chooser for the commands.
function obj.chooseCommand()
  local choices = {}
  for index,cmd in ipairs(obj.commands) do
    choices[#choices+1] = {
      index = index,
      text = cmd.text
    }
    if cmd.hotkey then
      choices[#choices].text = choices[#choices].text .. " (" .. cmd.hotkeyMods .. "+" .. cmd.hotkey .. ")"
    end
  end
  local chooser = hs.chooser.new(function(choice)
    obj.commands[choice.index].fn()
  end)
  chooser:choices(choices)
  chooser:placeholderText('command')
  chooser:show()
end

return obj
