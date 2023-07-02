# doxygen-previewer.nvim

A Neovim plugin for previewing doxygen documentation.

![preview doxygen](https://github.com/rikuma-t/doxygen-previewer.nvim/assets/55551571/d940e31b-eca4-42e7-a507-2b432f6e3533)

## Features

- Live preview of doxygen generated documentation in your browser.
- Automated updates of the documentation preview when the source code is saved.
- Find the project's Doxyfile and use it for preview. Generate without Doxyfile is also possible.
- Doxygen options for preview are configurable.

## Requirements

- Neovim Nightly
- Doxygen
- [live-server](https://www.npmjs.com/package/live-server)

## Installation

Install the plugin using your favorite package manager.

Using [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'rikuma-t/doxygen-previewer.nvim' , { 'do': 'npm install -g live-server' }
lua require("doxygen-previewer").setup()
```

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "rikuma-t/doxygen-previewer.nvim",
  build = "npm install -g live-server",
  config = true,
}
```

If you are a lazy.nvim user and don't want to install live-server globally you can use the following configuration:

```lua
{
  "rikuma-t/doxygen-previewer.nvim",
  config = function (plugin)
    require("doxygen-previewer").setup {
      viewers = {
        ["live-server"] = { open = { cmd = plugin.dir .. "/node_modules/.bin/live-server" } },
      },
      --other configurations
    }
  end,
  build = "npm install live-server",
}
```

## Usage

The plugin provides the following commands:

- `:DoxygenOpen` - Open doxygen documentation preview. The preview is automatically updated when saving the buffer.
- `:DoxygenUpdate` - Manually update the preview.
- `:DoxygenStop` - Stop the doxygen documentation preview.
- `:DoxygenLog` - Open the doxygen generation log.

## Configuration

The plugin's behavior can be customized by providing a table to the setup function. Here are the defaults:

```lua
require("doxygen-previewer").setup({
  --- Path to output doxygen results
  tempdir = vim.fn.stdpath "cache",
  --- viewer for display doxygen output
  --- Select the viewer in `viewers` settings.
  viewer = "live-server",
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
    --- By default, to reduce execution time, override the setting so that only files with the same name and different extension (for C/C++ headers) as the file to be previewed are generated.
    --- Also, other options related to generation are overridden by default.
    ---@return table
    override_options = function()
      return {
        -- include .h,.c,cpp
        ["INPUT"] = ".",
        ["FILE_PATTERNS"] = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t:r") .. ".*",
        ["EXCLUDE_PATTERNS"] = table.concat({ "*/.git/*", "*/.svn/*", "*/node_modules/*" }, " "),
        ["SEARCH_INCLUDES"] = "NO",
        ["EXTRACT_ALL"] = "YES",
        ["RECURSIVE"] = "YES",
      }
    end,
  },
  --- viewer preset
  --- By default, only live-server is available, but you can add any viewer you like.
  --- Set the following for each viewer.
  ---   open : command for DoxygenOpen
  ---   update : command at DoxygenUpdate
  ---   env : env for command execution
  --- Also, `open` and `update` can use the following.
  ---   {html_dir} : html generation directory
  ---   {html_name} : html file name for preview
  --- @type table<string,DoxygenViewer>
  viewers = {
    ["live-server"] = {
      open = { cmd = "live-server", args = { "{html_dir}", "--open={html_name}" } },
      update = nil,
      env = nil,
    },
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

## Viewer Settings

The plugin supports any viewer that can display HTML and take commands for opening and refreshing the page. Here is the default configuration for the `live-server` viewer:

```lua
["live-server"] = {
    open = { cmd = "live-server", args = { "{html_dir}", "--open={html_name}" } },
    update = nil,
    env = nil,
},
```

## License

MIT
