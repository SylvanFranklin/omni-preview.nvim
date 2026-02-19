-- local npm = require "omni-preview.npm"
local M = {}

M.system_open = function()
  local filename = vim.fn.expand "%:p"
  local success = os.execute("open " .. vim.fn.shellescape(filename))
  if not success then print('Could not use system command "open" to open ' .. filename) end
end

M.build_config = function()
  local trim = {}
  for _, preview in ipairs(M.previews) do
    local ok, module = pcall(require, preview.name)
    if preview.name == "builtin" or (ok and module ~= nil) then table.insert(trim, preview) end
  end

  return trim
end

---@return Preview | nil
M.get_triggerable_previews = function()
  local ft = vim.bo.filetype
  local fe = vim.fn.expand("%:e"):lower()
  local pr = require("omni-preview").previews
  local useable_previews = {}

  for _, p in ipairs(pr or {}) do
    if type(p.trig) == "string" then
      if p.trig == ft or p.trig == fe then table.insert(useable_previews, p) end
    end
    if type(p.trig) == "function" then
      if p.trig() then table.insert(useable_previews, p) end
    end
  end

  if #useable_previews >= 1 then return useable_previews end

  return nil
end

-- assumes preview names are unique(EXCEPTION are builtins)
M.find_preview_by_name = function(name)
  local pr = require("omni-preview").previews

  for _, p in ipairs(pr) do
    if p.name == name then return p end
  end
end

M.start_preview = function(preview)
  if preview then
    if type(preview.start) == "string" then
      vim.cmd(preview.start)
      return
    elseif type(preview.start) == "function" then
      preview.start()
      return
    end
  end

  vim.notify("Preview command not found or invalid for current filetype", vim.log.levels.WARN)
end

M.stop_preview = function(preview)
  if preview then
    if type(preview.start) == "string" then
      vim.cmd(preview.stop)
      return
    elseif type(preview.stop) == "function" then
      preview.stop()
      return
    end
  end

  vim.notify("Preview command not found or invalid for current filetype", vim.log.levels.WARN)
end

---@class Preview
---@field name string                 -- Unique name of the previewer
---@field trig string|fun():boolean  -- Trigger keyword or function that determines if the previewer should activate
---@field start string|fun()         -- Command or function to start the preview
---@field stop? string|fun()         -- Optional: command or function to stop the preview

-- TODO consolidate the default previews using some kind of loop
---@type Preview[]
---
M.previews = {
  { name = "typst-preview", trig = "typst", start = "TypstPreview", stop = "TypstPreviewStop" },
  { name = "vimtex", trig = "tex", start = "LatexStart" },
  {
    name = "csvview",
    trig = "csv",
    start = "CsvViewEnable",
    stop = "CsvViewDisable",
  },
  {
    name = "data-viewer",
    trig = "csv",
    start = "DataViewer",
    stop = "DataViewerClose",
  },
  {
    name = "markdown-preview",
    trig = "markdown",
    start = "MarkdownPreview",
    stop = "MarkdownPreviewStop",
  },
  {
    name = "github-preview",
    trig = "markdown",
    start = function() require("github-preview").fns.start() end,
    stop = function() require("github-preview").fns.stop() end,
  },
  {
    name = "markview",
    trig = "markdown",
    start = "Markview enable",
    stop = "Markview disable",
  },
  {
    name = "render-markdown",
    trig = "markdown",
    start = "RenderMarkdown enable",
    stop = "RenderMarkdown disable",
  },
  {
    name = "live-server",
    trig = "html",
    start = "LiveServerStart",
    stop = "LiveServerStop",
  },
  {
    name = "nvim-asciidoc-preview",
    trig = "asciidoc",
    start = "AsciiDocPreview",
    stop = "AsciiDocPreviewStop",
  },
  {
    name = "peek",
    trig = "markdown",
    start = function() require("peek").open() end,
    stop = function() require("peek").close() end,
  },
  {
    name = "cloak",
    trig = function()
      local ok, cloak = pcall(require, "cloak")
      if not ok then return false end

      local patterns = cloak.opts.patterns
      local file_patterns = patterns[1].file_pattern
      if type(file_patterns) == "string" then file_patterns = { file_patterns } end
      local base_name = vim.fn.expand "%:t"
      for _, file_pattern in ipairs(file_patterns) do
        if base_name ~= nil and vim.fn.match(base_name, vim.fn.glob2regpat(file_pattern)) ~= -1 then return true end
      end
      return false
    end,
    start = function() require("cloak").enable() end,
    stop = function() require("cloak").disable() end,
  },
  { trig = "pdf", start = M.system_open, name = "builtin" },
  { trig = "svg", start = M.system_open, name = "builtin" },
  { trig = "png", start = M.system_open, name = "builtin" },
  { trig = "tif", start = M.system_open, name = "builtin" },
  { trig = "tiff", start = M.system_open, name = "builtin" },
  { trig = "jpeg", start = M.system_open, name = "builtin" },
  { trig = "html", start = M.system_open, name = "builtin" },
  { trig = "gif", start = M.system_open, name = "builtin" },
  { trig = "jpg", start = M.system_open, name = "builtin" },
  { trig = "webp", start = M.system_open, name = "builtin" },
  { trig = "mp4", start = M.system_open, name = "builtin" },
  { trig = "mov", start = M.system_open, name = "builtin" },
  { trig = "avi", start = M.system_open, name = "builtin" },
  { trig = "mkv", start = M.system_open, name = "builtin" },
  { trig = "flv", start = M.system_open, name = "builtin" },
  { trig = "wmv", start = M.system_open, name = "builtin" },
  { trig = "webm", start = M.system_open, name = "builtin" },
  { trig = "3gp", start = M.system_open, name = "builtin" },
  { trig = "mpeg", start = M.system_open, name = "builtin" },
  { trig = "mpg", start = M.system_open, name = "builtin" },
  { trig = "m4v", start = M.system_open, name = "builtin" },
  { trig = "ogv", start = M.system_open, name = "builtin" },
}

return M
