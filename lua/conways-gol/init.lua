local M = {}

M._win_details = {}

M.FPS = 30
M.MAX_GENERATIONS = 200
M.DEAD = 0
M.ALIVE = 1

M.ROWS = 10
M.COLS = 10

M.ALIVE_CHAR = "x"
M.DEAD_CHAR = " "

M.matrixFrame1 = {}
M.matrixFrame2 = {}

M.generationCounter = 0

--@return table
function M.open_window()
	local config = {
		relative = "editor",
		anchor = "NW",
		border = "none",
		title = "Conway's Game of Life",
		style = "minimal",
		row = 0,
		col = 0,
		width = 80,
		height = 24,
	}
	local buf_id = vim.api.nvim_create_buf(false, true)
	local win_id = vim.api.nvim_open_win(buf_id, false, config)
	return {
		win_id = win_id,
		buf_id = buf_id,
	}
end

--@param details table
function M.validate_details(details)
	assert(vim.api.nvim_buf_is_valid(details.buf_id))
	assert(vim.api.nvim_win_is_valid(details.win_id))
end

--@param details table
function M.focus_win(details)
	M.validate_details(details)
	--vim.api.nvim_set_current_buf(results.buf_id)
	vim.api.nvim_set_current_win(details.win_id)
end

--@param details table
--@param str string
function M.render_to_win(details, lines)
	print(vim.inspect(lines))
	vim.api.nvim_buf_set_lines(details.buf_id, 0, -1, false, lines)
end

local function determineNextPhase(matrixFrame, row, col)
	local liveNeighborCount = 0

	for i = 1, 3 do
		for j = 1, 3 do
			local x = (row + i - 1 + M.ROWS) % M.ROWS
			local y = (col + i - 1 + M.COLS) % M.COLS
		end
	end
end

function M._update()
	local mf = M.generationCounter % 2 == 1 and M.matrixFrame1 or M.matrixFrame2
	if M.generationCounter % 2 == 1 then
		for i, row in ipairs(M.matrixFrame1) do
			for j, _ in ipairs(row) do
				mf[i][j] = determineNextPhase(M.matrixFrame1, i, j)
			end
		end
	else
		for i, row in ipairs(M.matrixFrame2) do
			for j, _ in ipairs(row) do
				mf[i][j] = determineNextPhase(M.matrixFrame2, i, j)
			end
		end
	end
end

local function matrixFrameToLines(matrixFrame)
	local out = {}
	local line
	for i, row in ipairs(matrixFrame) do
		line = ""
		for _, col in ipairs(row) do
			if col == 0 then
				line = line .. M.DEAD_CHAR
			elseif col == 1 then
				line = line .. M.ALIVE_CHAR
			end
		end
		out[i] = line
	end

	return out
end

function M._draw()
	local mf = M.generationCounter % 2 == 1 and M.matrixFrame1 or M.matrixFrame2
	local lines = matrixFrameToLines(mf)
	M.render_to_win(M._win_details, lines)
end

function M._game_loop()
	-- M._update()
	M._draw()
end

function M.start_game()
	-- init window
	M._win_details = M.open_window()
	M.focus_win(M._win_details)

	-- init matrix frames
	for i = 1, M.ROWS do
		M.matrixFrame1[i] = {}
		M.matrixFrame2[i] = {}
		for j = 1, M.COLS do
			if i == 5 and j == 5 then
				M.matrixFrame1[i][j] = 1
				M.matrixFrame2[i][j] = 1
			else
				M.matrixFrame1[i][j] = 0
				M.matrixFrame2[i][j] = 0
			end
		end
	end

	-- handle game loop
	local timer = vim.uv.new_timer()
	timer:start(
		0,
		1000 / M.FPS,
		vim.schedule_wrap(function()
			M._game_loop()
			if M.generationCounter >= M.MAX_GENERATIONS then
				timer:close()
			end
			M.generationCounter = M.generationCounter + 1
		end)
	)
end

function M.setup()
	vim.api.nvim_create_user_command("StartGame", M.start_game, {})
end

return M
