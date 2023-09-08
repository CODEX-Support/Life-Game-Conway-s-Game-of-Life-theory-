-- Import Lunatest
local lunatest = require("lunatest")

package.path = package.path .. ";./?.lua"

-- Import the code module that contains the functions to be tested
local code = require("main")

-- Set testMode to true to enable test mode
code.testMode = true

-- Test for cellTapped(event)
function test_cellTapped()
    -- Create a test cell
    local testCell = display.newRect(0, 0, code.cellSize, code.cellSize)

    -- Simulate a tap event on the cell
    local testEvent = { target = testCell }
    code.cellTapped(testEvent)

    -- Check if the cell color changes as expected
    lunatest.assert_equals(testCell.fillColor, { 0, 0, 0 })

    -- Simulate another tap event on the same cell
    code.cellTapped(testEvent)

    -- Check if the cell color reverts back to white
    lunatest.assert_equals(testCell.fillColor, { 1, 1, 1 })
end

-- Test for calculateNextGeneration()
function test_calculateNextGeneration()
    -- Define a test grid with a known state
    code.grid = {
        {false, false, false},
        {false, true, false},
        {false, false, false}
    }

    -- Call the function to calculate the next generation
    code.calculateNextGeneration()

    -- Define the expected next generation
    local expectedNextGen = {
        {false, false, false},
        {false, false, false},
        {false, false, false}
    }

    -- Check if the calculated next generation matches the expected outcome
    for row = 1, #code.grid do
        for col = 1, #code.grid[row] do
            lunatest.assert_equals(code.grid[row][col], expectedNextGen[row][col])
        end
    end
end

-- Test for updateGrid()
function test_updateGrid()
    -- Assuming isSimulationRunning is initially true
    code.isSimulationRunning = true

    -- Define a mock function to simulate calculateNextGeneration
    local calculateNextGenerationCalled = false
    code.calculateNextGeneration = function()
        calculateNextGenerationCalled = true
    end

    -- Call the function to update the grid
    code.updateGrid()

    -- Check if calculateNextGeneration is called
    lunatest.assert_true(calculateNextGenerationCalled)

    -- Assuming isSimulationRunning is set to false
    code.isSimulationRunning = false
    calculateNextGenerationCalled = false

    -- Call the function to update the grid
    code.updateGrid()

    -- Check if calculateNextGeneration is not called when simulation is not running
    lunatest.assert_false(calculateNextGenerationCalled)
end


-- Test for increaseIterationTime()
function test_increaseIterationTime()
    -- Get the initial iteration delay
    local initialDelay = code.iterationDelay

    -- Call the function to increase the iteration time
    code.increaseIterationTime()

    -- Check if the iteration delay has increased as expected
    lunatest.assert_true(code.iterationDelay > initialDelay)
end

-- Test for decreaseIterationTime()
function test_decreaseIterationTime()
    -- Set an initial iteration delay (greater than 500)
    code.iterationDelay = 1000

    -- Call the function to decrease the iteration time
    code.decreaseIterationTime()

    -- Check if the iteration delay has decreased as expected
    lunatest.assert_true(code.iterationDelay < 1000)
end

-- ... (Add more test cases for other functions as needed)

-- Run the tests
lunatest.run()
