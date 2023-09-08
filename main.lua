local M = {}

-- Set up display
local display = require("display")
local widget = require("widget")

-- Constants
local gridSize = 5
local cellSize = display.contentWidth / (gridSize)   -- Adjust this size as needed

local spacing = 0   -- Adjust the spacing between cells
local buttonWidth = 100
local buttonHeight = 40
local isIterationLeft = true
local iterationCount = 0

if gridSize>120 then
    cellSize = 3
end 

local strokeWidth = 0
if gridSize>99 then
    strokeWidth = 0
elseif gridSize>49 then
    strokeWidth = 1
else
    strokeWidth = 2
end

-- Declare the "Start" button and isSimulationRunning variable
local startButton
local isSimulationRunning

-- Create a group to hold all display objects
local sceneGroup = display.newGroup()

-- Create a group to hold the grid cells
local gridGroup = display.newGroup()

-- Create a variable to store the iteration delay
local iterationDelay = 2000  -- Default iteration delay in milliseconds

-- Create a function to increase the iteration time
local function increaseIterationTime()
    iterationDelay = iterationDelay + 500  -- Increase by 500 milliseconds
end

-- Create a function to decrease the iteration time
local function decreaseIterationTime()
    if iterationDelay > 500 then
        iterationDelay = iterationDelay - 500  -- Decrease by 500 milliseconds, but ensure it doesn't go below 500
    end
end

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

-- Create the grid
local grid = {}
for row = 1, gridSize do
    grid[row] = {}
    for col = 1, gridSize do
        local cell = display.newRect(
            (col - 1) * (cellSize + spacing),
            (row - 1) * (cellSize + spacing),
            cellSize,
            cellSize
        )

        cell.anchorX = 0
        cell.anchorY = 0
        cell:setFillColor(1, 1, 1)  -- White color
        cell.strokeWidth = strokeWidth
        cell:setStrokeColor(0, 0, 0)

        cell.selected = false  -- Custom flag to track cell selection

        cell:addEventListener("tap", cellTapped)

        grid[row][col] = cell
        gridGroup:insert(cell)
    end
end


-- Set the fixed screen width and height for gridGroup
gridGroup.width = 320
gridGroup.height = 320

-- Position the grid group at the center of the screen
gridGroup.x = 0
gridGroup.y = 95

-- Function to calculate the next generation
local function calculateNextGeneration()
    isIterationLeft = false

    -- Contains only true, false about isAlive
    local newGrid = {}
    for row = 1, gridSize do
        newGrid[row] = {}
        for col = 1, gridSize do
            local neighbors = 0
            for i = -1, 1 do
                for j = -1, 1 do
                    if i ~= 0 or j ~= 0 then
                        local x = (row + i - 1 + gridSize) % gridSize + 1
                        local y = (col + j - 1 + gridSize) % gridSize + 1
                        if grid[x][y].selected then
                            neighbors = neighbors + 1
                        end
                    end
                end
            end

            if grid[row][col].selected then
                -- Cell is alive
                if neighbors < 2 or neighbors > 3 then
                    newGrid[row][col] = false  -- Cell dies
                    isIterationLeft = true
                else
                    newGrid[row][col] = true  -- Cell stays alive
                end
            else
                -- Cell is dead
                if neighbors == 3 then
                    newGrid[row][col] = true  -- Cell becomes alive
                    isIterationLeft = true
                else
                    newGrid[row][col] = false  -- Cell stays dead
                end
            end
        end
    end

    -- Update the grid
    for row = 1, gridSize do
        for col = 1, gridSize do
            grid[row][col].selected = newGrid[row][col]
            if newGrid[row][col] then
                grid[row][col]:setFillColor(0, 0, 0)  -- Alive cell color (black)
            else
                grid[row][col]:setFillColor(1, 1, 1)  -- Dead cell color (white)
            end
        end
    end

    -- Print the grid as a matrix
    if iterationCount < 4 and gridSize<21 then
        iterationCount = iterationCount + 1
        print("Iteration :" .. iterationCount)
        for row = 1, gridSize do
            local rowString = ""
            for col = 1, gridSize do
                if newGrid[row][col] then
                    rowString = rowString .. "1 "
                else
                    rowString = rowString .. "0 "
                end
            end
            print(rowString)
        end
    end
end

-- Function to update the grid in each iteration
local function updateGrid()
    if isIterationLeft then
        if isSimulationRunning then
            calculateNextGeneration()
            print(iterationDelay)
            timer.performWithDelay(iterationDelay, updateGrid)  -- Adjust the delay as needed
        end
    else
        startButton:setLabel("Finished")
        print("Iteration finished")
    end
end

-- Create the "Start" button
startButton = widget.newButton({
    width = buttonWidth,
    height = buttonHeight,
    label = "Start",
    onRelease = function()
        if not isIterationLeft then
            isIterationLeft = true
        end

        if isSimulationRunning then
            -- Stop the simulation if it's already running
            isSimulationRunning = false
            startButton:setLabel("Start")
        else
            -- Start the simulation
            isSimulationRunning = true
            startButton:setLabel("Pause")

            -- Start the grid update loop
            updateGrid()
        end
    end,
    shape = "roundedRect", -- Use a rounded rectangle shape for the button
    cornerRadius = 10, -- Set the corner radius for rounded corners
    fillColor = { default = {0, 1, 0.8}, over = {1, 0, 0} },
    labelColor = { default = {0, 0, 0}, over = {0, 0, 0} }
})

startButton.x = display.contentCenterX
startButton.y = display.contentHeight - buttonHeight / 2 - 10

sceneGroup:insert(startButton)

-- ... (Previous code remains the same)

-- Create the "Random" button
local randomButton = widget.newButton({
    width = buttonWidth,
    height = buttonHeight,
    label = "Random",
    onRelease = function()
        if not isSimulationRunning then
            -- Generate and apply random cell selections
            for row = 1, gridSize do
                for col = 1, gridSize do
                    local randomValue = math.random(1, 5) -- Generate a random number between 1 and 5
                    grid[row][col].selected = randomValue == 1 -- Set the cell selection based on the random number
                    if grid[row][col].selected then
                        grid[row][col]:setFillColor(0, 0, 0) -- Set cell color to black for selected cells
                    else
                        grid[row][col]:setFillColor(1, 1, 1) -- Set cell color to white for unselected cells
                    end
                end
            end
        end
    end,
    shape = "roundedRect",
    cornerRadius = 10,
    fillColor = { default = {0.6, 0.8, 0.2}, over = {0.4, 0.6, 0.1} }, -- Green color
    labelColor = { default = {1, 1, 1}, over = {1, 1, 1} }
})

randomButton.x = display.contentCenterX - buttonWidth
randomButton.y = 5

sceneGroup:insert(randomButton)

-- Create the "Reset" button
local resetButton = widget.newButton({
    width = buttonWidth,
    height = buttonHeight,
    label = "Reset",
    onRelease = function()
        if not isSimulationRunning then
            -- Generate and apply random cell selections
            for row = 1, gridSize do
                for col = 1, gridSize do
                    grid[row][col].selected = false
                    grid[row][col]:setFillColor(1, 1, 1)
                end
            end

            -- Reset the label of the "Start" button
            startButton:setLabel("Start")
            isIterationLeft = true
        end
    end,
    shape = "roundedRect",
    cornerRadius = 10,
    fillColor = { default = {1, 0.6, 0}, over = {0.8, 0.4, 0} }, -- Orange color
    labelColor = { default = {1, 1, 1}, over = {1, 1, 1} }
})

resetButton.x = display.contentCenterX + buttonWidth
resetButton.y = 5

sceneGroup:insert(resetButton)

-- Create the "Save" button
local saveButton = widget.newButton({
    width = buttonWidth,
    height = buttonHeight,
    label = "Save",
    onRelease = function()
        if not isSimulationRunning then
            -- Save the current state of the grid (you need to implement this logic)
            
            local saveData = {}
            for row = 1, gridSize do
                saveData[row] = {}
                for col = 1, gridSize do
                    saveData[row][col] = grid[row][col].selected
                end
            end

            -- Convert saveData to JSON and save it to a file
            local json = require("json")
            local saveFile = io.open(system.pathForFile("saved_state.json", system.DocumentsDirectory), "w")
            if saveFile then
                saveFile:write(json.encode(saveData))
                io.close(saveFile)
            end
        end
    end,
    shape = "roundedRect",
    cornerRadius = 10,
    fillColor = { default = {0.2, 0.6, 0.9}, over = {0.5, 0.5, 0} }, -- Blue color
    labelColor = { default = {1, 1, 1}, over = {1, 1, 1} }
})

saveButton.x = display.contentCenterX - buttonWidth
saveButton.y = 55

sceneGroup:insert(saveButton)

-- Create the "Restore" button
local restoreButton = widget.newButton({
    width = buttonWidth,
    height = buttonHeight,
    label = "Restore",
    onRelease = function()
        if not isSimulationRunning then
            -- Restore the saved state of the grid (you need to implement this logic)
            
            -- Load saved data from the file
            local json = require("json")
            local saveFile = io.open(system.pathForFile("saved_state.json", system.DocumentsDirectory), "r")
            if saveFile then
                local savedData = json.decode(saveFile:read("*a"))
                io.close(saveFile)

                -- Apply the saved state to the grid
                for row = 1, gridSize do
                    for col = 1, gridSize do
                        grid[row][col].selected = savedData[row][col]
                        if grid[row][col].selected then
                            grid[row][col]:setFillColor(0, 0, 0) -- Set cell color to black for selected cells
                        else
                            grid[row][col]:setFillColor(1, 1, 1) -- Set cell color to white for unselected cells
                        end
                    end
                end
            end
        end
    end,
    shape = "roundedRect",
    cornerRadius = 10,
    fillColor = { default = {1, 0.2, 0.4}, over = {0.5, 0.1, 0.2} }, -- Red color
    labelColor = { default = {1, 1, 1}, over = {1, 1, 1} }
})

restoreButton.x = display.contentCenterX + buttonWidth
restoreButton.y = 55

sceneGroup:insert(restoreButton)

-- Create the "Increase Speed" button
local increaseSpeedButton = widget.newButton({
    width = 50,
    height = buttonHeight,
    label = "[+]",
    onRelease = decreaseIterationTime,
    shape = "roundedRect",
    cornerRadius = 10,
    fillColor = { default = {0.2, 0.7, 0.2}, over = {0.1, 0.5, 0.1} }, -- Green color
    labelColor = { default = {0, 0, 0}, over = {0, 0, 0} }
})

increaseSpeedButton.x = display.contentCenterX
increaseSpeedButton.y = 0

sceneGroup:insert(increaseSpeedButton)

-- Create the "Decrease Speed" button
local decreaseSpeedButton = widget.newButton({
    width = 50,
    height = buttonHeight,
    label = "[-]",
    onRelease = increaseIterationTime,
    shape = "roundedRect",
    cornerRadius = 10,
    fillColor = { default = {0.9, 0.2, 0.2}, over = {0.7, 0.1, 0.1} }, -- Red color
    labelColor = { default = {0, 0, 0}, over = {0, 0, 0} }
})

decreaseSpeedButton.x = display.contentCenterX
decreaseSpeedButton.y = 55

sceneGroup:insert(decreaseSpeedButton)

-- Function to handle app exit or scene cleanup
local function onExit(event)
    if event.phase == "will" then
        -- Stop any running timers, transitions, or audio here
        if isSimulationRunning then
            isSimulationRunning = false
        end
    end
end

-- Add an exit event listener
Runtime:addEventListener("system", onExit)

-- Return the module
return M

