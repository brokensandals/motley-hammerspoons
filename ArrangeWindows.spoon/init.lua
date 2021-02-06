local obj = {}
obj.__index = obj

-- Metadata
obj.name = "ArrangeWindows"
obj.version = "0.0.1"
obj.author = "Jacob Williams <jacobaw@gmail.com>"
obj.license = "MIT - https://opensource.org/licenses/MIT"
obj.homepage = "https://github.com/brokensandals/motley-hammerspoons"

--- ArrangeWindows.maximize()
--- Function
--- Maximizes the currently open window.
function obj.maximize()
  local win = hs.window.focusedWindow()
  hs.layout.apply({{nil, win, nil, hs.layout.maximized, nil, nil}})
end

--- ArrangeWindows.layouts
--- Variable
--- Table containing the options that the layout chooser will show.
---
--- Each key should be a unique value identifying the layout, and the value
--- should be a table with the following keys:
---
---   text: string display name for the layout
---   source: indicates ownership/origin of the layout
---           layouts provided by this spoon have source "default"
---           layouts managed by the save/load functionality have source "saved"
---   windows: a list of specifications for laying out windows; they should be ordered such that the frontmost window is first; each table has the following keys:
---     selector: specifies what window is to be moved
---               "focused" means the currently focused window
---               "chooser" means to ask the user to select a window
---               "match" means to look up the window by ID or title
---     prompt: when selector=="chooser", this is the prompt to show in the fuzzy finder
---     id: when selector="match", the window ID, if available
---     title: when selector="match", the window title
---     applicationTitle: when selector="match", the application title, if known
---     frameRect: optional frame rect to pass to hs.layout
---     fullFrameRect: optional full frame rect to pass to hs.layout
---     unitRect: optional unit rect to pass to hs.layout
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
  },
  ["centered"] = {
    text = "centered",
    source = "default",
    windows = {
      {selector = "focused",  unitRect = hs.geometry(0.15,0,0.7,1)}
    }
  },
  ["y-70-30"] = {
    text = "y seventy-thirty",
    source = "default",
    windows = {
      {selector = "focused", unitRect = hs.geometry(0,0,1,0.7)},
      {selector = "chooser", unitRect = hs.geometry(0,0.7,1,0.3), prompt = "bottom window"}
    }
  },
}

--- ArrangeWindows.applyLayout(selected, layout)
--- Function
--- Applies the specified layout.
--- selected is a list of hs.window objects indicating the windows to apply the layout to; normally, just pass an empty table and this function will figure it out.
--- layout is a table of the format documented for the values of ArrangeWindows.layouts
function obj.applyLayout(selected, layout)
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
        obj.applyLayout(selected, layout)
      end)
      chooser:choices(choices)
      chooser:placeholderText(cfg.prompt)
      chooser:show()
      return
    elseif cfg.selector == "match" then
      local win = nil
      if cfg.id then
        win = hs.window.get(cfg.id)
        if not win then
          -- HACK to forget outdated window IDs in case they get reused for other windows later
          cfg.id = nil
          obj.persistSavedLayouts()
        end
      end
      
      if cfg.applicationTitle and not win then
        local app = hs.application.get(cfg.applicationTitle, 3)
        win = app and app:getWindow(cfg.title)
      end
      win = win or hs.window.get(cfg.title)
      selected[#selected+1] = win
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

--- ArrangeWindows.captureLayout()
--- Function
--- Returns a layout (see ArrangeWindows.layouts) based on the current arrangement of windows on-screen.
function obj.captureLayout()
  local layout = {windows = {}}
  local windows = hs.window.orderedWindows()
  for i,win in ipairs(windows) do
    layout.windows[i] = {
      selector = "match",
      id = win:id(),
      title = win:title(),
      applicationTitle = (win:application() and win:application():title()) or nil,
      frameRect = win:frame()
    }
  end
  return layout
end

--- ArrangeWindows.saveLayout()
--- Function
--- Asks the user for a name and then saves the current arrangement of windows.
function obj.saveLayout()
  local focused = hs.window.focusedWindow()
  hs.focus()
  local btn, name = hs.dialog.textPrompt('Save Layout', 'Enter a name for the layout.', 'custom', 'OK', 'Cancel')
  if btn == 'OK' then
    local layout = obj.captureLayout()
    layout.text = name
    layout.source = "saved"
    obj.layouts[name] = layout
    obj.persistSavedLayouts()
  end
  if focused then
    focused:focus()
  end
end

--- ArrangeWindows.clearSavedLayouts()
--- Function
--- Erases the user's saved layouts.
function obj.clearSavedLayouts()
  for k,layout in pairs(obj.layouts) do
    if layout.source == "saved" then
      obj.layouts[k] = nil
    end
  end
  obj.persistSavedLayouts()
end

--- ArrangeWindows.chooseLayout()
--- Function
--- Displays a chooser for all the layouts in ArrangeWindows.layouts and applies the selected one.
function obj.chooseLayout()
  local chooser = hs.chooser.new(function(choice)
    obj.applyLayout({}, obj.layouts[choice.id])
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

--- ArrangeWindows.chooseWindow()
--- Function
--- Shows a chooser with each open window's title, and then focuses on the chosen window.
function obj.chooseWindow()
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

--- ArrangeWindows.init()
--- Function
--- Loads saved layouts from settings.
function obj.init()
  local saved = hs.settings.get("ArrangeWindows.saved")
  if saved then
    for k,v in pairs(saved) do
      obj.layouts[k] = v
      for _,cfg in pairs(v.windows) do
        local fr = cfg.frameRect
        if fr then
          cfg.frameRect = hs.geometry.rect(fr._x, fr._y, fr._w, fr._h)
        end
      end
    end
  end
end

--- ArrangeWindows.persistSavedLayouts()
--- Function
--- Copies the user's custom layouts into their settings.
function obj.persistSavedLayouts()
  local save = {}
  for k,v in pairs(obj.layouts) do
    if v.source == "saved" then
      save[k] = v
    end
  end
  hs.settings.set("ArrangeWindows.saved", save)
end

return obj
