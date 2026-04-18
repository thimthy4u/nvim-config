# 🚀 Timkhoding's Neovim Config

> AstroNvim setup for Windows with PowerShell (pwsh) + Oh-My-Posh

---

## 📋 Requirements

- [Neovim](https://neovim.io/) >= 0.9.0
- [Git](https://git-scm.com/)
- [PowerShell 7+](https://github.com/PowerShell/PowerShell) (`pwsh`)
- [Oh-My-Posh](https://ohmyposh.dev/) (optional, for terminal styling)
- A [Nerd Font](https://www.nerdfonts.com/) (e.g. `JetBrainsMono Nerd Font`)
- [Node.js](https://nodejs.org/) (for LSP servers)
- [ripgrep](https://github.com/BurntSushi/ripgrep) (for Telescope live grep)

---

## 💻 Installation

### Windows (PowerShell)

```powershell
# Remove existing config if any
Remove-Item C:\Users\$env:USERNAME\.config\nvim -Recurse -Force

# Clone this config
git clone https://github.com/thimthy4u/nvim-config.git C:\Users\$env:USERNAME\.config\nvim

# Open Neovim — lazy.nvim will auto-install all plugins
nvim
```

### Linux / Mac

```bash
# Remove existing config if any
rm -rf ~/.config/nvim

# Clone this config
git clone https://github.com/thimthy4u/nvim-config.git ~/.config/nvim

# Open Neovim — lazy.nvim will auto-install all plugins
nvim
```

---

## 📁 Folder Structure

```
nvim/
├── init.lua                  # Entry point
└── lua/
    └── plugins/
        ├── astrocore.lua     # Core AstroNvim config & keymaps
        ├── astrolsp.lua      # LSP configuration
        ├── astroui.lua       # UI configuration
        ├── mason.lua         # LSP/formatter installer
        ├── none-ls.lua       # Formatter & linter setup
        ├── treesitter.lua    # Syntax highlighting
        └── example.lua       # Custom plugins & overrides
```

---

## ✨ Features

- 🎨 **Custom Dashboard Banner** — personalized ASCII art header
- 💻 **PowerShell (pwsh)** — default terminal with Oh-My-Posh styling
- 🔍 **Telescope** — fuzzy finder for files, text, and more
- 🌳 **Treesitter** — advanced syntax highlighting
- 🧠 **LSP** — language server support via Mason
- 📦 **Lazy.nvim** — fast plugin manager
- ✏️ **Autopairs** — auto close brackets, quotes, etc.
- 🗂️ **Aerial.nvim** — code outline panel (via LSP backend)

---

## 🔧 Customization

### Change the Dashboard Banner
Edit `lua/plugins/example.lua`:
```lua
{
  "folke/snacks.nvim",
  opts = {
    dashboard = {
      preset = {
        header = table.concat({
          "Your custom",
          "ASCII art here",
        }, "\n"),
      },
    },
  },
},
```

### Change Terminal Shell
Edit `lua/plugins/astrocore.lua` or toggleterm config:
```lua
shell = "pwsh -NoLogo",  -- PowerShell 7
-- or
shell = "cmd",           -- Command Prompt
-- or
shell = "bash",          -- Bash (Linux/Mac)
```

---

## ⌨️ Key Mappings

| Key | Action |
|-----|--------|
| `<Leader>` | `Space` |
| `<Leader>e` | Toggle file explorer |
| `<Leader>ff` | Find files |
| `<Leader>fw` | Find text (live grep) |
| `<Leader>tt` | Toggle terminal |
| `<Leader>gg` | Open Lazygit |
| `gcc` | Toggle comment |
| `K` | Hover documentation |
| `gd` | Go to definition |

---

## 🔄 Updating

```powershell
# Update all plugins inside Neovim
:Lazy update

# Pull latest config from GitHub
cd C:\Users\$env:USERNAME\.config\nvim
git pull origin Thim
```

---

## 📦 Main Plugins

| Plugin | Purpose |
|--------|---------|
| [AstroNvim](https://github.com/AstroNvim/AstroNvim) | Base config framework |
| [lazy.nvim](https://github.com/folke/lazy.nvim) | Plugin manager |
| [snacks.nvim](https://github.com/folke/snacks.nvim) | Dashboard & utilities |
| [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) | Terminal integration |
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Fuzzy finder |
| [aerial.nvim](https://github.com/stevearc/aerial.nvim) | Code outline |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax highlighting |
| [mason.nvim](https://github.com/williamboman/mason.nvim) | LSP installer |

---

## 🐛 Known Issues & Fixes

### aerial.nvim treesitter error
If you see a `attempt to call method 'start'` error, add this to `example.lua`:
```lua
{
  "stevearc/aerial.nvim",
  opts = {
    backends = { "lsp", "markdown", "asciidoc", "man" },
  },
},
```

---

## 📝 License

MIT — feel free to use and modify for your own config!

---

<div align="center">
  Made with ❤️ by <a href="https://github.com/thimthy4u">Timkhoding</a>
</div>