# markdown-plus.nvim

<p align="center">
    <img src="https://img.shields.io/badge/%20Lua-%23D0B8EB?style=for-the-badge&logo=lua"
        alt="Markdown-plus is built with Lua"
    />
    <img src="https://img.shields.io/github/last-commit/jeangiraldoo/markdown-plus.nvim?style=for-the-badge&labelColor=%232E3A59&color=%23A6D8FF"
        alt="When was the last commit made"/>
    <img src="https://img.shields.io/badge/v0.10%2B-%238BD5CA?style=for-the-badge&logo=neovim&label=Neovim&labelColor=%232E3A59&color=%238BD5CA"
        alt="Neovim version 0.10.0 and up"/>
    <a href = "https://github.com/jeangiraldoo/markdown-plus.nvim/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/MIT-%232E3A59?style=for-the-badge&label=License&labelColor=%232E3A59&color=%23F4A6A6"
            alt="Latest version"/>
    </a>
    <img src="https://img.shields.io/github/repo-size/jeangiraldoo/markdown-plus.nvim?style=for-the-badge&logo=files&logoColor=yellow&label=SIZE&labelColor=%232E3A59&color=%23A8D8A1"
        alt="Repository size in KB"/>
</p>

Enjoy a smoother, smarter Markdown experience in Neovim with handy features that take care of the
little things for you.

## 📖 Table of contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Motivation](#motivation)
- [License](#license)

### <a id="features"></a>🚀 Features

- Automatically capitalizes the first letter of headings.
- Automatically continues lists: inserts the next bullet (`-`) in an unordered list based on the
  previous line.

### <a id="requirements"></a>📋 Requirements

- Neovim 0.10+

### <a id="installation"></a>📦 Installation

Choose your preferred plugin manager and use the corresponding command:

#### [lazy.nvim](http://www.lazyvim.org/)

```lua
{
    "jeangiraldoo/markdown-plus.nvim",
    ft = "markdown",
    opts = {}
}
```

#### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
    "jeangiraldoo/markdown-plus.nvim",
    config = function()
        require("markdown").setup({})
    end,
}
```

### <a id="usage"></a>💻 Usage

#### Smart editing

Just edit your Markdown file as usual — the plugin works automatically in the background.

- When you create a heading, the first letter will be capitalized instantly.
- When you press **Enter** after a list item, the next bullet or number will be inserted for you.

No commands or configuration are required.

### <a id="motivation"></a>💡 Motivation

I enjoy taking notes and writing documentation in Markdown, but I’ve always wanted certain parts of
the editing process to feel more automated, much like in a traditional word processor. I first
created this functionality for my own Neovim setup, then decided to turn it into a plugin so others
could enjoy it as well (o˘◡˘o)

### <a id="license"></a>📜 License

Markdown-plus is licensed under the MIT License. This means you are free to download, install,
modify, share, and use the plugin for both personal and commercial purposes.

The only requirement is that if you modify and redistribute the code, you must include the same
LICENSE file found in this repository.
