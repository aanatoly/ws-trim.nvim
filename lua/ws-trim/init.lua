local M = {}

--- @class VenvOptions
local defaults = {
  conform_fts = { "_" },
  install_conform_fallback = true,
  max_blank_lines = 2,
  hl_group = { link = "Error" },
}

M.options = {}

M.refresh = function(_)
  local rc1 = not not vim.w.ws_enabled
  local rc2 = not not vim.b.ws_enabled
  if rc1 == rc2 then
    return
  end
  if rc2 then
    local reg = "\\(^\\s*\\n\\)\\{%s}\\zs\\_s*\\n"
    reg = string.format(reg, M.options.max_blank_lines)
    vim.w.ws_enabled = {
      -- highlight spaces at the end of a line
      vim.fn.matchadd("ExtraWhitespace", "\\s\\+$", 10),
      -- highlight blank lines at the beggining of a file
      vim.fn.matchadd("ExtraWhitespace", "\\%^\\_s*\\n", 10),
      -- highlight blank lines at the end of a file
      vim.fn.matchadd("ExtraWhitespace", "^\\_s*\\%$", 10),
      -- highlight adjacent blank lines, starting from 3rd
      vim.fn.matchadd("ExtraWhitespace", reg, 10),
      -- -- no highlight for whitespaces before cursor position
      vim.fn.matchadd("Normal", "\\s\\+\\%#", 20),
    }
  else
    for _, r in ipairs(vim.w.ws_enabled) do
      vim.fn.matchdelete(r)
    end
    vim.w.ws_enabled = nil
  end
end

M.format = function(_, _, lines_in, callback)
  local lines_out = {}
  local blanks = 0
  for _, line in ipairs(lines_in) do
    local trimmed = line:gsub("%s+$", "")
    if trimmed == "" then
      blanks = blanks + 1
    else
      if #lines_out == 0 then
        blanks = 0
      end
      blanks = math.min(blanks, M.options.max_blank_lines)
      for _ = 1, blanks do
        table.insert(lines_out, "")
      end
      blanks = 0
      table.insert(lines_out, trimmed)
    end
  end
  callback(nil, lines_out)
end

M.setup = function(options)
  M.options = vim.tbl_deep_extend("force", {}, defaults, options or {})
  if M.options.install_conform_fallback then
    require("conform").formatters_by_ft["_"] = { "ws_trim" }
    require("conform").formatters["ws_trim"] = { format = M.format }
  end

  local augrp = vim.api.nvim_create_augroup("WhiteSpace", { clear = true })
  vim.api.nvim_create_autocmd({ "FileType" }, {
    group = augrp,
    callback = function(ev)
      vim.b.ws_enabled = vim.bo.buftype == ""
      M.refresh(ev)
    end,
  })
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
    group = augrp,
    callback = function(ev)
      M.refresh(ev)
    end,
  })

  vim.api.nvim_set_hl(0, "ExtraWhitespace", M.options.hl_group)
end

return M
