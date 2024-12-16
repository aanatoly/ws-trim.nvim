# ws-trim.nvim

neovim plugin that highlights trailing whitespaces and
removes them via [conform][conform]

Highlights:

- spaces at the end of the line
- blank lines at the end of the file
- too many consequitive blank lines, 2+

Trimming:
- it configures [conform][conform] to trim white spaces, if no formatters defined

## Installation

Installation with `lazy`

```lua
{
    "aanatoly/whitespaces-nvim",
    cmd = { "Venv", "VenvInfo" },
    opts = { search_path = { "~/.venvs", "." } }
}
```

[conform]: https://github.com/aanatoly/venv.nvim.git
