local obj = {}
obj.__index = obj

-- Metadata
obj.name = "AudioSelect"
obj.version = "0.0.1"
obj.author = "Jacob Williams <jacobaw@gmail.com>"
obj.license = "MIT - https://opensource.org/licenses/MIT"
obj.homepage = "https://github.com/brokensandals/motley-hammerspoons"

--- AudioSelect.chooseAudioOutput()
--- Function
--- Shows a chooser listing all audio output devices.
function obj.chooseAudioOutput()
  local devices = hs.audiodevice.allOutputDevices()
  local choices = {}
  for index,device in ipairs(devices) do
    choices[#choices+1] = {
      index = index,
      text = device:name()
    }
  end
  local chooser = hs.chooser.new(function(selected)
    devices[selected.index]:setDefaultOutputDevice()
  end)
  chooser:choices(choices)
  chooser:placeholderText("audio output device")
  chooser:show()
end

--- AudioSelect.chooseAudioOutput()
--- Function
--- Shows a text entry dialog for setting volume to a number between 0 and 100.
function obj.chooseAudioOutputVolume()
  local focused = hs.window.focusedWindow()
  hs.focus()
  local curvol = hs.audiodevice.defaultOutputDevice():volume()
  local btn, vol = hs.dialog.textPrompt('Set Audio Output Volume', 'Enter a number from 0 to 100. (currently: ' .. curvol ..  ')', '' .. curvol, 'OK', 'Cancel')
  if btn == 'OK' then
    local device = hs.audiodevice.defaultOutputDevice()
    vol = tonumber(vol)
    if vol >= 0 and vol <= 100 then
      device:setOutputVolume(vol)
    end
  end
  if focused then
    focused:focus()
  end
end

return obj
