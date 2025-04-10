# Omni-Preview.nvim

Provides a master list of nvim preview plugins for different filetypes and a
command to tie them together. The goal is to get everything working quickly, while keeping open advanced configuration. Simple plugin + Awesome list of previews.

https://github.com/user-attachments/assets/e9c0a587-0536-478d-b408-30422ac8e73b


> [!IMPORTANT]
> Still in early stages and lacking support for many plugins, PR's to support your plugin are super welcome! I'll try to add as many as I can.

**Builtin**: 
- [x] Simple files: `.png`, `.svg`, `.tiff`, `.jpeg`, `.html`, `.pdfs`, etc. 

**Works out of the box with third party** 
- [x] CSV 
- [x] Latex (just by finding a corresponding pdf file, look into vimtex for more)
- [x] Markdown
- [x] Typst
- [x] Env Files
- [ ] ...More coming soon

## Install

`Lazy.nvim`

```lua
{
    "sylvanfranklin/omni-preview.nvim",
    opts = {}
}
```
`Packer.nvim` 

```lua
use {
    'sylvanfranklin/omni-preview.nvim',
    config = function()
        require 'omni-preview'.setup {}
    end,
}
```

### Installing Previews
Simply installing plugins as dependencies calls `.setup` which is usually enough for most of these pugins to work. If for some reason it doesn't you can manually call `.setup()` on each of them. 

**For example with** `Lazy`

```lua 
{
    "sylvanfranklin/omni-preview.nvim",
    dependencies = {
        -- Typst
        { 'chomosuke/typst-preview.nvim', lazy = true },
        -- CSV
        { 'hat0uma/csvview.nvim',         lazy = true },
    },
    opts = {},
}
```
**Override default settings**
Sometimes these plugins have behavior that you want to change, simply call setup on them yourself.  

```lua
{
    "sylvanfranklin/omni-preview.nvim",
    dependencies = {
        -- for markdown
        { "toppair/peek.nvim", lazy = true, build = "deno task --quiet build:fast" } 
    },
    config = function()
        require("omni-preview").setup()
        require("peek").setup({ app = "browser" })
    end
}
```

## Usage

One command to rule them all
`:OmniPreview {args}`

Three intuitive subcommands
`:OmniPreview start`, `:OmniPreview stop`, `:OmniPreview toggle`. 

There is no default keymapping for the, I recommend setting: 

```lua
vim.keymap.set("n", "<leader>p", ":OmniPreview toggle<CR>", { silent = true })
```

I often just close the preview manually since some of them don't have defined stop behavior, for instance system level preview tools. Maybe there is some way to close these efficiently but I'm not all that aware of it.    

## Filetypes

Remember to add these as dependencies or set them up manually with `.setup` if you want your own preferences. The Lazy package manager will call default setup functions on everything defined as a depencency. While this does save some complexity, it also often means less than desirable default behavior. Because of this I like to set things up individually. 

#### Typst


- [typst-preview.nvim](https://github.com/chomosuke/typst-preview.nvim) Instant onpyte updating preview  

```lua
{ 'chomosuke/typst-preview.nvim', lazy = true }, 
```


#### Markdown

- [peek.nvim](https://github.com/toppair/peek.nvim) Best all around in my experience.

```lua 
{ "toppair/peek.nvim", lazy = true, build = "deno task --quiet build:fast" },
```

- [github-preview.nvim](https://github.com/wallpants/github-preview.nvim?tab=readme-ov-file) Great plugin with full github parity, requires `bun.sh`

```lua
{ "wallpants/github-preview.nvim", lazy = true },
```

- [mardown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim) Slightly older but still great.

```lua
{"iamcco/markdown-preview.nvim", lazy = true}
```
- [markview.nvim](https://github.com/OXY2DEV/markview.nvim) In editor conceal based preview (also requires treesitter and dev icons)
```lua
{ "OXY2DEV/markview.nvim", lazy = true}
```

#### HTML

- [Live-Server.nvim](https://github.com/barrett-ruth/live-server.nvim) Requires node package live server

```lua
    {
        'barrett-ruth/live-server.nvim',
        build = 'pnpm add -g live-server',
        cmd = { 'LiveServerStart', 'LiveServerStop' },
        config = true
    }
```

#### CSV

- [csvview.nvim](https://github.com/hat0uma/csvview.nvim) Conceal in editor

```lua
{ 'hat0uma/csvview.nvim', lazy = true } 
```

#### Other

- [nvim-asciidoc-preview](https://github.com/tigion/nvim-asciidoc-preview?tab=readme-ov-file#installation)

```lua
    {'tigion/nvim-asciidoc-preview', lazy = true}
```

For images and other types I just use the unix `open` command. You can override that behavior by passing a filetype and start and stop string or function.

```lua
require("omni-preview").setup({
    previews = {
        { trig = "pdf", start = "zathura" -- , stop=... }
    }
})
```

- [cloak.nvim](https://github.com/laytan/cloak.nvim) cloak sensitive data

```lua
    {'laytan/cloak.nvim', lazy = true}
```


#### ROADMAP 🌾
Lot's of work to do, this is early days. 
- [ ] Mason like UI and registry
- [ ] Telescope like picker to support multiple types of previews
- [ ] More config options for more plugins
- [ ] More coverage of LaTeX 
- [ ] Support for multiple previews on a single filetype


#### Alternatives

- The OG [knap](https://github.com/frabjous/knap), requires a bit more tinkering to get certain previews working.    
- Live support for many types [live-preview.nvim](https://github.com/brianhuster/live-preview.nvim). I might try to intergrate this in omni soon.

go give stars to the authors of these and the preview plugins, they are the real heros.
