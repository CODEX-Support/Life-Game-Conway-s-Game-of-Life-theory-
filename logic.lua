-- Function to handle cell selection
local function cellTapped(event)
    local cell = event.target

    if not isSimulationRunning then
        if cell.selected then
            -- Change the cell's color back to white when deselected
            cell:setFillColor(1, 1, 1)  -- White color
            cell.selected = false
        else
            -- Change the cell's color to dark when selected
            cell:setFillColor(0, 0, 0)
            cell.selected = true
        end
    end
end