# doxygen-previewer.nvim

A Neovim plugin for previewing Doxygen documentation.

![preview doxygen](https://github.com/hat0uma/doxygen-previewer.nvim/assets/55551571/d940e31b-eca4-42e7-a507-2b432f6e3533)

## Features

- Live preview of Doxygen-generated documentation in your browser.
- Automated updates of the documentation preview when the source code is saved.
- Finds the project's Doxyfile and use it for previewing. Generate without a Doxyfile is also possible.
- Doxygen options for preview are configurable.

## Requirements

- Neovim v0.10.1 or later
- Doxygen
- [prelive.nvim](https://github.com/hat0uma/prelive.nvim) (for live preview)

## Installation

Install the plugin using your favorite package manager.

Using [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'hat0uma/prelive.nvim'
Plug 'hat0uma/doxygen-previewer.nvim'
lua require("doxygen-previewer").setup()
```

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "hat0uma/doxygen-previewer.nvim",
  opts = {},
  dependencies = { "hat0uma/prelive.nvim" },
  cmd = {
    "DoxygenOpen",
    "DoxygenUpdate",
    "DoxygenStop",
    "DoxygenLog",
    "DoxygenTempDoxyfileOpen"
  },
}

```

## Usage

The plugin provides the following commands:

- `:DoxygenOpen` - Open Doxygen documentation preview. The preview is automatically updated when saving the buffer.
- `:DoxygenUpdate` - Manually update the preview.
- `:DoxygenStop` - Stop the Doxygen documentation preview.
- `:DoxygenLog` - Open the Doxygen generation log.
- `:DoxygenTempDoxyfileOpen` - Open the temporary Doxyfile used for preview.

## Configuration

The plugin's behavior can be customized by providing a table to the `setup` function. Here are the defaults:

For live preview settings, see [prelive.nvim](https://github.com/hat0uma/prelive.nvim#Configuration).

```lua
require("doxygen-previewer").setup({
  --- Path to output doxygen results
  tempdir = vim.fn.stdpath "cache",
  --- If true, update automatically when saving.
  update_on_save = true,
  --- doxygen settings section
  doxygen = {
    --- doxygen executable
    cmd = "doxygen",
    --- doxyfile pattern.
    --- Search upward from the parent directory of the file to be previewed and use the first match.
    --- The directory matching the pattern is used as the cwd when doxygen is run.
    --- If not matched, doxygen's default settings will be used. (see `doxygen -g -`)
    doxyfile_patterns = {
      "Doxyfile",
      "doc/Doxyfile",
    },
    --- If the pattern in `doxyfile_patterns` setting is not found, use this parameter as cwd when running doxygen.
    fallback_cwd = function()
      return vim.fs.dirname(vim.api.nvim_buf_get_name(0))
    end,
    --- doxygen options to override.
    --- For details, see [Doxygen configuration](https://www.doxygen.nl/manual/config.html).
    --- Also, other options related to generation are overridden by default. see `Doxygen Options` section in README.md.
    --- If a function is specified in the value, it will be evaluated at runtime.
    --- For example:
    --- override_options = {
    ---   PROJECT_NAME = "PreviewProject",
    ---   HTML_EXTRA_STYLESHEET = vim.fn.stdpath("config") .. "/stylesheet.css"
    --- }
    --- @type table<string, string|fun():string>
    override_options = {},
  },
})
```

## Doxygen Options

By default the following settings are overridden for preview. If you want to set other options, you can change them with `doxygen.override_options`.

| KEY              | VALUE                                    |
| ---------------- | ---------------------------------------- |
| INPUT            | .                                        |
| FILE_PATTERNS    | <<preview_file_name>>.\*                 |
| EXCLUDE_PATTERNS | \*/.git/\* \*/.svn/\* \*/node_modules/\* |
| RECURSIVE        | YES                                      |
| SEARCH_INCLUDES  | NO                                       |
| EXTRACT_ALL      | YES                                      |

In addition, the following options are set inside the plugin. It is recommended not to change it because it is related to the generation destination.

| KEY              | VALUE           |
| ---------------- | --------------- |
| OUTPUT_DIRECTORY | \<\<tempdir\>\> |
| SHORT_NAMES      | NO              |
| CASE_SENSE_NAMES | NO              |
| CREATE_SUBDIRS   | NO              |
| GENERATE_HTML    | YES             |
| GENERATE_LATEX   | NO              |
| GENERATE_MAN     | NO              |
| GENERATE_RTF     | NO              |
| GENERATE_XML     | NO              |

## License

MIT
