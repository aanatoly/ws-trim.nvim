local M = {}

local defaults = {
  conform_fts = { "_" },
  max_blank_lines = 2,
  hl_group = { link = "Error" },
  hl_name = "ExtraWhitespace",
  hl_ws_prio = 10,
  hl_clear_prio = 20,
}

M.options = {}

M.refresh = function(_)
  local rc1 = not not vim.w.ws_enabled
  local rc2 = not not vim.b.ws_enabled
  if rc1 == rc2 then
    return
  end
  if rc2 then
    local reg = "\\S.*\\n\\zs\\(\\n\\)\\{1,%s}\\ze\\_s*\\S"
    reg = string.format(reg, M.options.max_blank_lines)
    vim.w.ws_enabled = {
      -- highlight spaces at the end of a line
      vim.fn.matchadd(M.options.hl_name, "\\s\\+$", M.options.hl_ws_prio),
      -- no highlight for whitespaces before cursor position
      vim.fn.matchadd("Normal", "\\s\\+\\%#", M.options.hl_clear_prio),

      -- highlight all empty lines
      vim.fn.matchadd(M.options.hl_name, "^\\n\\+", M.options.hl_ws_prio),
      -- no highlight for first N blank lines, following text, unless EOF
      vim.fn.matchadd("Normal", reg, M.options.hl_clear_prio),
      -- no highlight for newline after cursor
      vim.fn.matchadd("Normal", "\\%#\\n", M.options.hl_clear_prio),
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

M.conform_setup = function()
  local ok, conform = pcall(require, "conform")
  if not ok then
    return
  end
  conform.formatters["ws_trim"] = { format = M.format }
  local fts = conform.formatters_by_ft
  for _, ft in ipairs(M.options.conform_fts) do
    -- print("ws ft: " .. ft)
    local fmts = fts[ft]
    if fmts == nil then
      fmts = {}
    elseif type(fmts) == "string" then
      fmts = { fmts }
    end
    if type(fmts) ~= "table" then
      error("Invalid fmts spec: " .. type(fmts))
    else
      table.insert(fmts, "ws_trim")
      fts[ft] = fmts
    end
    -- print("conform fmts: " .. vim.inspect(fmts))
  end
end

M.setup = function(options)
  M.options = vim.tbl_deep_extend("force", {}, defaults, options or {})
  M.conform_setup()
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

  vim.api.nvim_set_hl(0, M.options.hl_name, M.options.hl_group)
end

return M
