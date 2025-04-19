local url = "https://raw.githubusercontent.com/hellamane/favenlua/refs/heads/main/StemTree.lua"
local success, response = pcall(function()
    return game:HttpGet(url)
end)

if success then
    local loadFunction = loadstring(response)
    if loadFunction then
        loadFunction() -- Execute the script
    else
        warn("Failed to load the script.")
    end
else
    warn("Failed to fetch the script from the URL. Error:", response)
end
