local defaults = require "omni-preview.defaults"

---@class CustomModule
local M = {}

M.close_float = function(buf, win)
  if buf ~= nil and vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end

  if win ~= nil and vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
end

M.create_float_window = function(previews, title, callback)
  -- Create a scratch buffer
  local buf = vim.api.nvim_create_buf(false, true)

  -- create array of just names for the float
  local names = vim.tbl_map(function(item) return item.name end, previews)

  -- Insert the lines into the buffer
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, names)

  -- Open the buffer in a floating window for display
  local width = 50
  local height = 10
  local float = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = (vim.o.lines - height) / 2,
    col = (vim.o.columns - width) / 2,
    style = "minimal",
    border = "rounded",
    title = title,
    title_pos = "center",
  })

  -- line numbers
  vim.api.nvim_set_option_value("number", true, { win = float })

  -- Set bindings for menu
  vim.keymap.set("n", "<ESC>", function() M.close_float(buf, float) end, { buffer = buf, silent = true })

  vim.keymap.set("n", "q", function() M.close_float(buf, float) end, { buffer = buf, silent = true })

  vim.keymap.set("n", "<CR>", function()
    -- Get cursor line number while in the float window
    local line_number = vim.api.nvim_win_get_cursor(0)[1]

    -- get the name(text on the line)
    local preview_name = vim.api.nvim_buf_get_lines(buf, line_number - 1, line_number, false)[1]

    local p = defaults.find_preview_by_name(preview_name)

    M.close_float(buf, float)

    -- start/close AFTER closing picker or it will use wrong buf
    -- callback that will start or close the preview
    -- this can be whatever function that needs to be passed in to do something
    callback(p)
  end, { buffer = buf, silent = true })

    -- Number key bindings (1-9)
  for i = 1, math.min(9, #previews) do
    vim.keymap.set("n", tostring(i), function()
      local preview = previews[i]
      M.close_float(buf, float)
      callback(preview)
    end, { buffer = buf, silent = true })
  end
end

return M
