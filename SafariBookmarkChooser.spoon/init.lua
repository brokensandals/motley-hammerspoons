local obj = {}
obj.__index = obj

-- Metadata
obj.name = "SafariBookmarkChooser"
obj.version = "0.0.1"
obj.author = "Jacob Williams <jacobaw@gmail.com>"
obj.license = "MIT - https://opensource.org/licenses/MIT"
obj.homepage = "https://github.com/brokensandals/motley-hammerspoons"

--- SafariBookmarkChooser.chooseBookmark()
--- Function
--- Opens Safari, loads its bookmark list, and displays a chooser for them.
function obj.chooseBookmark()
  local focused = hs.window.focusedWindow()
  local safari = hs.application.open('Safari', 5, true)
  safari:getMenuItems(function(menu)
    local choices = {}
    function findChoices(path, list)
      for _,item in pairs(list) do
        local newpath = {}
        for i,title in ipairs(path) do
          newpath[i] = title
        end
        newpath[#newpath+1] = item.AXTitle
        if item.AXChildren then
          findChoices(newpath, item.AXChildren[1])
        elseif item.AXTitle and (not (item.AXTitle == '')) and item.AXEnabled then
          choices[#choices+1] = {
            text = item.AXTitle,
            path = newpath
          }
        end
      end
    end
    for _,item in pairs(menu) do
      if item.AXTitle == "Bookmarks" then
        local relevant = {}
        local foundStart = false
        for i,child in ipairs(item.AXChildren[1]) do
          if child.AXTitle == "Favorites" then
            foundStart = true
          end
          if foundStart then
            relevant[#relevant+1] = child
          end
        end
        findChoices({item.AXTitle}, relevant)
      end
    end
    local chooser = hs.chooser.new(function(selected)
      if selected then
        safari:selectMenuItem('New Tab')
        safari:selectMenuItem(selected.path)
      elseif focused then
        focused:focus()
      end
    end)
    chooser:choices(choices)
    chooser:placeholderText('bookmark')
    chooser:show()
  end)
end

return obj
