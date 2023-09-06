local lunatest = require("lunatest")
local assert = lunatest.assert

-- Import the functions to test
require("main")

lunatest.suite("Unit Tests")

-- Test for cellTapped function
function test_cellTapped()
    -- Create a mock cell and tap event
    local cell = { selected = false }
    local tapEvent = { target = cell }

    -- Test cell selection
    cellTapped(tapEvent)
    assert.True(cell.selected)

    -- Test cell deselection
    cellTapped(tapEvent)
    assert.False(cell.selected)
end

-- Test for calculateNextGeneration function
function test_calculateNextGeneration()
    -- Create a mock grid with specific cell selections
    local grid = {
        { selected = false, false, false },
        { false, false, true },
        { false, true, true }
    }

    -- Set the grid as the current grid
    _G.grid = grid

    -- Calculate the next generation
    calculateNextGeneration()

    -- Check if the next generation is as expected
    local expectedGrid = {
        { selected = false, false, false },
        { false, true, true },
        { false, true, true }
    }

    for row = 1, #grid do
        for col = 1, #grid[row] do
            assert.are.same(grid[row][col], expectedGrid[row][col])
        end
    end
end

-- Test for updateGrid function
function test_updateGrid()
    -- Mock the necessary variables
    _G.isIterationLeft = true
    _G.isSimulationRunning = true

    -- Mock the calculateNextGeneration function
    local calculateNextGenerationCalled = false
    _G.calculateNextGeneration = function()
        calculateNextGenerationCalled = true
        _G.isIterationLeft = false
    end

    -- Run the updateGrid function
    updateGrid()

    -- Check if calculateNextGeneration was called
    assert.True(calculateNextGenerationCalled)

    -- Check if isSimulationRunning is still true (indicating ongoing simulation)
    assert.True(isSimulationRunning)

    -- Check if isIterationLeft is set to false at the end of the iteration
    assert.False(isIterationLeft)
end

-- Test for increaseIterationTime function
function test_increaseIterationTime()
    -- Mock the iteration delay
    _G.iterationDelay = 2000

    -- Increase the iteration time
    increaseIterationTime()

    -- Check if the iteration delay has increased by 500 milliseconds
    assert.are.equal(_G.iterationDelay, 2500)

    -- Attempt to decrease the iteration time (should not go below 500)
    for _ = 1, 5 do
        decreaseIterationTime()
    end

    -- Check if the iteration delay is still at the minimum of 500 milliseconds
    assert.are.equal(_G.iterationDelay, 500)
end

-- Test for decreaseIterationTime function
function test_decreaseIterationTime()
    -- Mock the iteration delay
    _G.iterationDelay = 2000

    -- Decrease the iteration time
    decreaseIterationTime()

    -- Check if the iteration delay has decreased by 500 milliseconds
    assert.are.equal(_G.iterationDelay, 1500)

    -- Attempt to decrease the iteration time (should not go below 500)
    for _ = 1, 5 do
        decreaseIterationTime()
    end

    -- Check if the iteration delay is still at the minimum of 500 milliseconds
    assert.are.equal(_G.iterationDelay, 500)
end

-- Add more test functions for other code components

lunatest.run()
