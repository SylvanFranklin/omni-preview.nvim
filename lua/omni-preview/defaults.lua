-- local npm = require "omni-preview.npm"
local M = {}

M.system_open = function()
    local filename = vim.fn.expand("%:p")
    local success = os.execute("open " .. vim.fn.shellescape(filename))
    if not success then
        print("Could not use system command \"open\" to open " .. filename)
    end
end

M.build_config = function()
    local trim = {}
    for index, preview in ipairs(M.previews) do
        local ok, module = pcall(require, preview.name)
        if preview.name == "builtin" or (ok and module ~= nil) then
            table.insert(trim, preview)
        end
    end

    return trim
end

---@return Preview | nil
M.get_triggerable_preview = function()
    local ft = vim.bo.filetype
    local fe = vim.fn.expand("%:e"):lower()
    local pr = require("omni-preview").previews
    for _, p in ipairs(pr or {}) do
        if type(p.trig) == "string" then
            if p.trig == ft or p.trig == fe then
                return p
            end
        elseif type(p.trig) == "function" then
            if p.trig() then
                return p
            end
        end
    end

    return nil
end

M.find_running_preview = function ()
    local key = nil
    local current_buf = vim.api.nvim_get_current_buf()
    local p = M.get_triggerable_preview()

    if not p or not p.running then
        return nil
    end

    key = p.global and p.name or current_buf

    if not p.running[key] then
        return nil
    end

    return { preview = p, key = key }
end

---@class Preview
---@field name string                 -- Unique name of the previewer
---@field trig string|fun():boolean  -- Trigger keyword or function that determines if the previewer should activate
---@field start string|fun()         -- Command or function to start the preview
---@field stop? string|fun()         -- Optional: command or function to stop the preview
---@field global? boolean            -- Optional: whether the previewer runs globally, not tied to a specific buffer
---@field running? table<string|number, boolean> -- Tracks running state, global plugins just use name/key combo

-- TODO consolidate the default previews using some kind of loop
---@type Preview[]
---
M.previews = {
    { name = "typst-preview", trig = "typst", start = "TypstPreview", stop = "TypstPreviewStop", running = {} },
    { name = "vimtex",        trig = "tex",   start = "LatexStart", running = {} },
    {
        name = "csvview",
        trig = "csv",
        start = "CsvViewEnable",
        stop = "CsvViewDisable",
        running = {},
    },
    {
        name = "data-viewer",
        trig = "csv",
        start = "DataViewer",
        stop = "DataViewerClose",
        running = {},
    },
    {
        name = "markdown-preview",
        trig = "markdown",
        start = "MarkdownPreview",
        stop = "MarkdownPreviewStop",
        running = {},
    },
    {
        name = "github-preview",
        trig = "markdown",
        start = function() require "github-preview".fns.start() end,
        stop = function() require "github-preview".fns.stop() end,
        running = {},
    },
    {
        name = "markview",
        trig = "markdown",
        start = "Markview",
        stop = "",
        running = {},
    },
    {
        name = 'live-server',
        trig = 'html',
        start = "LiveServerStart",
        stop = "LiveServerStop",
        running = {},
    },
    {
        name = 'nvim-asciidoc-preview',
        trig = 'asciidoc',
        start = "AsciiDocPreview",
        stop = "AsciiDocPreviewStop",
        running = {},
    },
    {
        name = "peek",
        trig = "markdown",
        start = function() require "peek".open() end,
        stop = function() require "peek".close() end,
        running = {},
    },
    {
        name = "cloak",
        trig = function()
            local ok, cloak = pcall(require, "cloak")
            if not ok then
                return false
            end

            local cloak = require "cloak"
            local patterns = cloak.opts.patterns
            local file_patterns = patterns[1].file_pattern
            if type(file_patterns) == 'string' then
              file_patterns = { file_patterns }
            end
            local base_name = vim.fn.expand("%:t")
            for _, file_pattern in ipairs(file_patterns) do
              if base_name ~= nil and
                  vim.fn.match(base_name, vim.fn.glob2regpat(file_pattern)) ~= -1 then
                return true
              end
            end
            return false
        end,
        start = function() require "cloak".enable() end,
        stop = function() require "cloak".disable() end,
        global = true,
        running = (function ()
            local ok, cloak = pcall(require, "cloak")
            if not ok then
                return {}
            end
   
            local enabled = cloak.opts.enabled

            if not enabled then
                return {}
            end

            return { ["cloak"] = true } -- cloak is global
        end)(),
    },
    { trig = "pdf",  start = M.system_open, name = "builtin" },
    { trig = "svg",  start = M.system_open, name = "builtin" },
    { trig = "png",  start = M.system_open, name = "builtin" },
    { trig = "tif",  start = M.system_open, name = "builtin" },
    { trig = "tiff", start = M.system_open, name = "builtin" },
    { trig = "jpeg", start = M.system_open, name = "builtin" },
    { trig = "html", start = M.system_open, name = "builtin" },
    { trig = "gif",  start = M.system_open, name = "builtin" },
    { trig = "jpg",  start = M.system_open, name = "builtin" },
    { trig = "webp", start = M.system_open, name = "builtin" },
}

return M
