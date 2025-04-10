local defaults = require("omni-preview.defaults")

local M = {}

M.stop = function(debug)
    local debug = debug or false
    local rp = defaults.find_running_preview()

    if not rp and debug then
        vim.notify(
            "No running preview found",
            vim.log.levels.WARN
        )
        return
    end

    if not rp then
      return
    end

    local key = rp.key

    if rp.preview.stop == nil and debug then
        vim.notify(
            "Failed to stop running preview, no command provided",
            vim.log.levels.ERROR
        )
        return
    end

    rp.preview.running[key] = nil
    if type(rp.preview.stop) == "string" then
        vim.cmd(rp.preview.stop)
    elseif type(rp.preview.stop) == "function" then
        rp.preview.stop()
    end
end

M.toggle = function()
    local rp = defaults.find_running_preview()

    if not rp then
        M.start()
    else
        M.stop()
    end
end

function M.start()
    local key = nil
    local current_buf = vim.api.nvim_get_current_buf()
    local p = defaults.get_triggerable_preview()
  
    if p then
        key = p.global and p.name or current_buf
    
        if type(p.start) == "string" then
            vim.cmd(p.start)
            if p.running then
              p.running[key] = true
            end
            return
        elseif type(p.start) == "function" then
            p.start()
            if p.running then
              p.running[key] = true
            end
            return
        else
            vim.notify(
                "Invalid preview command for current filetype",
                vim.log.levels.ERROR
            )
            return
        end
    end

    vim.notify(
        "No preview available for current filetype",
        vim.log.levels.WARN
    )
end

return M
