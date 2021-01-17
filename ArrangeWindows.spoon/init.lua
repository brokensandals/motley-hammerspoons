local obj = {}
obj.__index = obj

-- Metadata
obj.name = "ArrangeWindows"
obj.version = "0.0.1"
obj.author = "Jacob Williams <jacobaw@gmail.com>"
obj.license = "MIT - https://opensource.org/licenses/MIT"
obj.homepage = "https://github.com/brokensandals/motley-hammerspoons"

--- WindowArranger:maximize()
--- Method
--- Maximizes the currently open window.
function obj:maximize()
  local win = hs.window.focusedWindow()
  hs.layout.apply({{nil, win, nil, hs.layout.maximized, nil, nil}})
end

--- WindowArranger.layouts
--- Variable
--- 
obj.layouts = {
  ["50-50"] = {
    text = "fifty-fifty",
    source = "default",
    windows = {
      {selector = "focused", unitRect = hs.layout.left50},
      {selector = "chooser", unitRect = hs.layout.right50, prompt = "right window"}
    }
  },
  ["60-40"] = {
    text = "sixty-forty",
    source = "default",
    windows = {
      {selector = "focused", unitRect = hs.geometry(0,0,0.6,1)},
      {selector = "chooser", unitRect = hs.geometry(0.6,0,0.4,1), prompt = "right window"}
    }
  },
  ["3-pane-50"] = {
    text = "three-pane fifty-fifty",
    source = "default",
    windows = {
      {selector = "focused", unitRect = hs.geometry(0,0,0.5,1)},
      {selector = "chooser", unitRect = hs.geometry(0.5,0,0.5,0.5), prompt = "top right window"},
      {selector = "chooser", unitRect = hs.geometry(0.5,0.5,0.5,0.5), prompt = "bottom right window"}
    }
  },
  ["3-pane-60"] = {
    text = "three-pane sixty-forty",
    source = "default",
    windows = {
      {selector = "focused", unitRect = hs.geometry(0,0,0.6,1)},
      {selector = "chooser", unitRect = hs.geometry(0.6,0,0.4,0.5), prompt = "top right window"},
      {selector = "chooser", unitRect = hs.geometry(0.6,0.5,0.4,0.5), prompt = "bottom right window"}
    }
  }
}

function obj:applyLayout(selected, layout)
  for i=#selected+1,#(layout.windows) do
    local cfg = layout.windows[i]
    if cfg.selector == "focused" then
      selected[#selected+1] = hs.window.focusedWindow()
    elseif cfg.selector == "chooser" then
      local exclude = {}
      for _,win in pairs(selected) do
        exclude[win:id()] = true
      end

      local choices = {}
      for i,win in ipairs(hs.window.allWindows()) do
        if not exclude[win:id()] then
          choices[#choices+1] = {
            text = "" .. win:application():title() .. " " .. win:title(),
            id = win:id()
          }
        end
      end

      local chooser = hs.chooser.new(function(choice)
        local win = hs.window.get(choice.id)
        selected[#selected+1] = win
        obj:applyLayout(selected, layout)
      end)
      chooser:choices(choices)
      chooser:placeholderText(cfg.prompt)
      chooser:show()
      return
    elseif cfg.selector == "match" then
      selected[#selected+1] = hs.window.get(cfg.id)
    else
      -- error
      return
    end
  end

  local resultlayout = {}
  for i,win in ipairs(selected) do
    local cfg = layout.windows[i]
    resultlayout[i] = {nil, win, nil, cfg.unitRect, cfg.frameRect, cfg.fullFrameRect}
  end
  for i = #selected,1,-1 do
    selected[i]:raise()
  end
  hs.layout.apply(resultlayout)
  selected[1]:focus()
end

function obj:captureLayout()
  local layout = {windows = {}}
  local windows = hs.window.orderedWindows()
  for i,win in ipairs(windows) do
    layout.windows[i] = {
      selector = "match",
      id = win:id(),
      frameRect = win:frame()
    }
  end
  return layout
end

function obj:saveLayout()
  local focused = hs.window.focusedWindow()
  hs.focus()
  local btn, name = hs.dialog.textPrompt('Save Layout', 'Enter a name for the layout.', 'custom', 'OK', 'Cancel')
  if btn == 'OK' then
    local layout = obj:captureLayout()
    layout.text = name
    layout.source = "saved"
    obj.layouts[name] = layout
    obj:persistSavedLayouts()
  end
  if focused then
    focused:focus()
  end
end

function obj:clearSavedLayouts()
  for k,layout in pairs(obj.layouts) do
    if layout.source == "saved" then
      obj.layouts[k] = nil
    end
  end
  obj:persistSavedLayouts()
end

function obj:chooseLayout()
  local chooser = hs.chooser.new(function(choice)
    obj:applyLayout({}, obj.layouts[choice.id])
  end)
  
  local choices = {}
  for id,layout in pairs(obj.layouts) do
    choices[#choices+1] = {text = layout.text, id = id}
  end
  table.sort(choices, function(a, b) return a.text < b.text end)

  chooser:choices(choices)
  chooser:placeholderText("layout")
  chooser:show()
end

function obj:chooseWindow()
  local windows = hs.window.allWindows()
  local choices = {}
  for index,win in ipairs(windows) do
    choices[#choices+1] = {
      text = "" .. win:application():title() .. " " .. win:title(),
      -- image = win:snapshot() -- too slow
      index = index
    }
  end
  local chooser = hs.chooser.new(function(selected)
    windows[selected.index]:focus()
  end)
  chooser:choices(choices)
  chooser:placeholderText("window")
  chooser:show()
end

function obj:init()
  local saved = hs.settings.get("ArrangeWindows.saved")
  if saved then
    for k,v in pairs(saved) do
      obj.layouts[k] = v
    end
  end
end

function obj:persistSavedLayouts()
  local save = {}
  for k,v in pairs(obj.layouts) do
    if v.source == "saved" then
      save[k] = v
    end
  end
  hs.settings.set("ArrangeWindows.saved", save)
end

return obj
