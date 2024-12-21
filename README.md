# `ws-trim.nvim`

[![Version](https://img.shields.io/github/tag/aanatoly/ws-trim.nvim.png)](https://github.com/aanatoly/ws-trim.nvim/releases)
[![Licence](https://img.shields.io/github/license/aanatoly/ws-trim.nvim.png)](./LICENSE)
[![Neovim](https://img.shields.io/badge/NeoVim-0.10-blue.png?logo=neovim)][neovim]
![Contributions](https://img.shields.io/badge/Contributions-Welcome-brightgreen.png)

[Neovim][neovim] plugin for highlighting and trimming unnecessary whitespace.
It integrates with [conform][conform] to provide actual formatting.

**Features:**

- Highlights whitespace in all normal buffers, including `gitcommit` buffers.
- Highlights the following types of whitespace issues:
  - Trailing spaces at the end of a line.
  - Trailing blank lines at the end of the file.
  - Leading blank lines at the start of the file.
  - Excessive blank lines (3+ consecutive blank lines).
- Whitespace trimming (formatting) for specific file types:
  - Uses [conform][conform], ensuring integration with your existing formatter setup.
  - Supports running as a fallback or as a post-formatter after other configured formatters.

## Installation

Installation with `lazy`

```lua
{
  "aanatoly/ws-trim.nvim",
  dependencies = { "stevearc/conform.nvim" },
  event = { "FileType" },
  opts = {},
}
```

## Configuration

The default configuration is

```lua
opts = {
  -- file types to format (e.g. trim whitespace)
  -- See https://github.com/stevearc/conform.nvim#options
  -- {"_"} - file types without a specific formatter
  -- {"*"} - all file types (runs last)
  -- {"c", "sh"} - specific file types (runs last)
  -- {} - do not format, only highlight
  conform_fts = { "_" },

  -- maximum number of blank lines allowed (excess lines are removed)
  max_blank_lines = 2,

  -- highlight group for trailing white spaces
  -- see `h: nvim_set_hl` for details
  -- { link = "Error" } - link to Error hl_group
  -- { bg = "red" } - red background
  hl_group = { link = "Error" },
}
```

Example usage

```lua
opts = {
  max_blank_lines = 1,
  hl_group = { bg = "yellow" },
}
```

## Limitations

Running `:noh` (which clears search highlights) can disrupt the dynamic highlighting
or concealment of whitespace based on cursor position.
The functionality resumes only after performing a new search (e.g., `/fff`), which
reactivates the necessary mechanisms.

In `nvchad`, `Esc` key mapped to `:noh`, so if you have highlight problem, try to remove
that mapping:

```lua
vim.keymap.del("n", "<Esc>")
```

## Creadits

Big thanks to these awesome projects for ideas and inspiration:

- [conform][conform] - Lightweight yet powerful formatter plugin for Neovim
- [trim][trim] - This plugin trims trailing whitespace and lines.

[neovim]: https://neovim.io/
[conform]: https://github.com/stevearc/conform.nvim/
[conform-opts]: https://github.com/stevearc/conform.nvim#options
[trim]: https://github.com/cappyzawa/trim.nvim
