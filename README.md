# markup.nvim

<p align="center">
    <img src="https://img.shields.io/badge/%20Lua-%23D0B8EB?style=for-the-badge&logo=lua"
        alt="Markdown-plus is built with Lua"
    />
    <img src="https://img.shields.io/github/last-commit/jeangiraldoo/markup.nvim?style=for-the-badge&labelColor=%232E3A59&color=%23A6D8FF"
        alt="When was the last commit made"/>
    <img src="https://img.shields.io/badge/v0.10%2B-%238BD5CA?style=for-the-badge&logo=neovim&label=Neovim&labelColor=%232E3A59&color=%238BD5CA"
        alt="Neovim version 0.10.0 and up"/>
    <a href = "https://github.com/jeangiraldoo/markup.nvim/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/MIT-%232E3A59?style=for-the-badge&label=License&labelColor=%232E3A59&color=%23F4A6A6"
            alt="Latest version"/>
    </a>
    <img src="https://img.shields.io/github/repo-size/jeangiraldoo/markup.nvim?style=for-the-badge&logo=files&logoColor=yellow&label=SIZE&labelColor=%232E3A59&color=%23A8D8A1"
        alt="Repository size in KB"/>
</p>

Enjoy a smoother, smarter experience when working with markup languages, with handy features that
take care of the little things for you.

## 📖 Table of contents

- [Features](#-features)
- [Requirements](#-requirements)
- [Installation](#-installation)
- [Usage](#-usage)
- [Motivation](#-motivation)
- [License](#-license)

## 🚀 Features

- Supports the following markup languages:

  - Markdown
  - Typst
  - LaTex

- Automatically:

  - Capitalizes the first letter of headings
  - Continues unordered lists

- Format the word under the cursor or visual selection as:

  - Bold
  - Italic
  - Bold + Italic
  - Inline or multiline code block
  - Inline or multiline quote block

## 📋 Requirements

- Neovim 0.10+

## 📦 Installation

Choose your preferred plugin manager and use the corresponding command:

### [lazy.nvim](http://www.lazyvim.org/)

```lua
{
    "jeangiraldoo/markup.nvim",
    ft = {
        "markdown",
        "typst",
        "tex" -- latex
    },
    opts = {}
}
```

#### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
    "jeangiraldoo/markup.nvim",
    config = function()
        require("markdown").setup({})
    end,
}
```

## ⚙️ Configuration

Here are all the available configuration options and their defaults:

````lua
-- Options:
--   auto_capitalize_headings -> Automatically capitalize the first letter of headings
--   auto_continue_lists      -> Automatically continue list entries when pressing Enter
--
-- Style options (each can be one of the following):
--   - string: A format string with a '%s' placeholder for the text
--   - function: A function that takes the text and returns formatted text
--   - table: A table defining separate formats, where keys map to either strings or functions as above
--        The table can include:
--          inline           -> Format for inline usage
--          multiline        -> Format for multiline usage
--          multiline_repeat -> (optional) A prefix string repeated on each line in multiline usage
--
--   bold       -> Bold style
--   italic     -> Italic style
--   bolditalic -> Combined bold and italic
--   quote      -> Quoted text style
--   code       -> Code block style

return {
    markdown = {
        auto_capitalize_headings = true,
        auto_continue_lists = true,
        style = {
            bold = "**%s**",
            italic = "_%s_",
            bolditalic = "***%s***",
            quote = {
                inline = '"%s"',
                multiline = "> %s",
                multiline_repeat = "> ",
            },
            code = {
                inline = "`%s`",
                multiline = "```\n%s\n```",
            },
        },
    },
    typst = {
        auto_capitalize_headings = true,
        auto_continue_lists = true,
        style = {
            bold = "*%s*",
            italic = "_%s_",
            bolditalic = "_*%s*_",
            quote = {
                inline = '"%s"',
                multiline = "> %s",
                multiline_repeat = "> ",
            },
            code = {
                inline = "`%s`",
                multiline = "```\n%s\n```",
            },
        },
    },
    tex = { -- Filetype used for LaTex
        auto_capitalize_headings = true,
        auto_continue_lists = true,
        style = {
            bold = "\\textbf{%s}",
            italic = "\\textit{%s}",
            bolditalic = "\\textbf{\\textit{%s}}",
            quote = {
                inline = "``%s''",
                multiline = "\\begin{quote}\n%s\n\\end{quote}",
            },
            code = {
                inline = "\\verb|%s|",
                multiline = "\\begin{verbatim}\n%s\n\\end{verbatim}",
            },
        },
    },
}
````

## 💻 Usage

### Smart editing

Just edit your Markdown file as usual — the plugin works automatically in the background.

- When you create a heading, the first letter will be capitalized instantly.
- When you press **Enter** after a list item, the next bullet or number will be inserted for you.

No commands or configuration are required.

## 💡 Motivation

I enjoy taking notes and writing documentation in Markdown, but I’ve always wanted certain parts of
the editing process to feel more automated, much like in a traditional word processor. I first
created this functionality for my own Neovim setup, then decided to turn it into a plugin so others
could enjoy it as well (o˘◡˘o)

## 📜 License

Markdown-plus is licensed under the MIT License. This means you are free to download, install,
modify, share, and use the plugin for both personal and commercial purposes.

The only requirement is that if you modify and redistribute the code, you must include the same
LICENSE file found in this repository.
