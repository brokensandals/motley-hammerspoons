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

function obj:chooseWinsAndApplyLayout(chosen, rects)
  local chosenSet = {}
  for _,win in ipairs(chosen) do
    chosenSet[win:id()] = true
  end
  local windows = hs.window.allWindows()
  local choices = {}
  for i,win in ipairs(windows) do
    if not chosenSet[win:id()] then
      choices[#choices+1] = {
        text = "" .. win:application():title() .. " " .. win:title(),
        -- image = win:snapshot() -- too slow
        id = win:id()
      }
    end
  end
  local chooser = hs.chooser.new(function(selected)
    local win = hs.window.get(selected.id)
    chosen[#chosen+1] = win
    if #chosen >= #rects then
      local layout = {}
      for i,rect in ipairs(rects) do
        layout[i] = {nil, chosen[i], nil, rects[i], nil, nil}
        chosen[i]:raise()
      end
      hs.layout.apply(layout)
    else
      chooseWinsAndApplyLayout(chosen, rects)
    end
  end)
  chooser:choices(choices)
  chooser:placeholderText("window " .. (#chosen+1))
  chooser:show()
end

obj.savedLayouts = {}

function obj:saveLayoutByName(name)
  local layout = {}
  local windows = hs.window.orderedWindows()
  for i,win in ipairs(windows) do
    layout[i] = {
      id = win:id(),
      frame = win:frame()
    }
  end
  obj.savedLayouts[name] = layout
end

function obj:saveLayout()
  local focused = hs.window.focusedWindow()
  hs.focus()
  local btn, name = hs.dialog.textPrompt('Save Layout', 'Enter a name for the layout.', 'custom', 'OK', 'Cancel')
  if btn == 'OK' then
    obj:saveLayoutByName(name)
  end
  if focused then
    focused:focus()
  end
end

function obj:loadLayoutByName(name)
  local layout = obj.savedLayouts[name]
  for i = #layout, 1, -1 do
    local entry = layout[i]
    local win = hs.window.get(entry.id)
    if win then
      win:setFrame(entry.frame)
      win:raise()
      if i == 1 then
        win:focus()
      end
    end
  end
end

function obj:chooseLayout()
  local actions = {
    ["60-40"] = function()
      obj:chooseWinsAndApplyLayout(
        {hs.window.focusedWindow()},
        {hs.geometry(0,0,0.6,1), hs.geometry(0.6,0,0.4,1)}
      )
    end,
    ["50-50"] = function()
      obj:chooseWinsAndApplyLayout(
        {hs.window.focusedWindow()},
        {hs.layout.left50, hs.layout.right50}
      )
    end,
    ["3-pane-60"] = function()
      obj:chooseWinsAndApplyLayout(
        {hs.window.focusedWindow()},
        {hs.geometry(0,0,0.6,1), hs.geometry(0.6,0,0.4,0.5), hs.geometry(0.6,0.5,0.4,0.5)})
    end,
    ["3-pane-50"] = function()
      obj:chooseWinsAndApplyLayout(
        {hs.window.focusedWindow()},
        {hs.geometry(0,0,0.5,1), hs.geometry(0.5,0,0.5,0.5), hs.geometry(0.5,0.5,0.5,0.5)})
    end,
    save = obj.saveLayout,
    clear = function() obj.savedLayouts = {} end
  }
  local chooser = hs.chooser.new(function(selected)
    actions[selected.id]()
  end)
  local choices = {
    {text = "fifty-fifty", id = "50-50"},
    {text = "sixty-forty", id = "60-40"},    
    {text = "three pane sixty-forty", id = "3-pane-60"},
    {text = "three pane fifty-fifty", id = "3-pane-50"},
    {text = "save", id = "save"},
    {text = "clear saved", id = "clear"}
  }
  for name,layout in pairs(obj.savedLayouts) do
    local id = "user-" .. name
    actions[id] = function() obj:loadLayoutByName(name) end
    choices[#choices+1] = {text = name, id = id}
  end
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

return obj
