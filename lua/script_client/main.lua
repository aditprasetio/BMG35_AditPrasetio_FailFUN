print('script_client:hello world')

local bindableEvent = Event:GetEvent("OnClientInitDone")
bindableEvent:Bind(function()
    local wnd = UI:CreateGUIWindow("Gui/gameInfo")
    UI.Root:AddChild(wnd)
end)


