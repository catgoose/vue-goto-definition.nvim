# vue-goto-definition

<!--toc:start-->
- [vue-goto-definition](#vue-goto-definition)
  - [About](#about)
  - [Neovim Config](#neovim-config)
    - [Default configuration](#default-configuration)
      - [Filter](#filter)
      - [Framework detection](#framework-detection)
    - [Lazy.nvim](#lazynvim)
  - [Framework and LSP configuration](#framework-and-lsp-configuration)
    - [Vue 3](#vue-3)
    - [Nuxt](#nuxt)
  - [LSP](#lsp)
    - [Takeover mode](#takeover-mode)
  - [Extra](#extra)
<!--toc:end-->

Improves `Volar` language server goto definition functionality

## About

When using vue with autoimports ([unplugin-vue-components](https://github.com/unplugin/unplugin-vue-components) and [unplugin-auto-import](https://github.com/unplugin/unplugin-auto-import) or using [nuxt](https://nuxt.com/)) `vim.lsp.buf.definition` will populate location list with the autoimport definition file and/or the typescript declaration for a symbol.

For example:

![default goto definition](https://github.com/catgoose/vue-goto-definition.nvim/blob/screenshots/2024-03-20_07-55.png)

This is annoying because now you have to open another file to go to the definition,
polluting the jump list.

`vue-goto-definition` overrides `vim.lsp.buf.definition` to edit the autoimported
symbol so you don't have to make multiple jumps to goto the definition.

## Neovim Config

### Default configuration

```lua
{
  filters = {
    auto_imports = true, -- resolve definitions in auto-imports.d.ts
    auto_components = true, -- resolve definitions in components.d.ts
    same_file = true, -- filter location list entries referencing the current file
    declaration = true, -- filter declaration files unless the only location list
    -- item is a declaration file
  },
  filetypes = { "vue", "typescript" }, -- enabled for filetypes
  detection = { -- framework detection.  Detection functions can be overridden here
    nuxt = function() -- look for .nuxt directory
      return vim.fn.glob(".nuxt/") ~= ""
    end,
    vue3 = function() -- look for vite.config.ts or App.vue
      return vim.fn.filereadable("vite.config.ts") == 1 or vim.fn.filereadable("src/App.vue") == 1
    end,
    priority = { "nuxt", "vue3" }, -- order in which to detect framework
  }
}
```

#### Filter

If after filtering the locationlist items there are multiple items remaining they
will be populated in a locationlist window.

#### Framework detection

[neoconf](https://github.com/folke/neoconf.nvim) could be used to detect the framework

### Lazy.nvim

```lua
local opts = {
  filters = {
    auto_imports = true,
    auto_components = true,
    same_file = true,
    declaration = true,
  },
  filetypes = { "vue", "typescript" },
  detection = {
    nuxt = function()
      return vim.fn.glob(".nuxt/") ~= ""
    end,
    vue3 = function()
      return vim.fn.filereadable("vite.config.ts") == 1 or vim.fn.filereadable("src/App.vue") == 1
    end,
    priority = { "nuxt", "vue3" },
  }
}

return {
  "catgoose/vue-goto-definition.nvim",
  event = "BufReadPre",
  opts = opts
})
```

## Framework and LSP configuration

### Vue 3

If you are using `unplugin-auto-import` and `unplugin-vue-components` make sure
to configure your `tsconfig.app.json` like this:

```json
{
  "extends": "@vue/tsconfig/tsconfig.dom.json",
  "include": [
    "env.d.ts",
    "src/**/*",
    "src/**/*.vue",
    "auto-imports.d.ts",
    "components.d.ts"
  ],
  "exclude": ["src/**/__tests__/*"],
  "compilerOptions": {
    "composite": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  }
}
```

### Nuxt

I don't use nuxt so you are on your own here. Please open an issue if definition
resolution is not working.

## LSP

I would recommend using `volar` with takeover mode because the new hybrid mode
results in two calls when `vim.lsp.buf.definition` is executed.

I've opened an issue about this [here](https://github.com/vuejs/language-tools/issues/4112)

### Takeover mode

I use neoconf to enable takeover mode

Create a `.neoconf.json` in project root, something like:

```json
{
  "lsp": {
    "servers": {
      "volar": {
        "disable": false
      },
      "tsserver": {
        "disable": true
      },
      "angularls": {
        "disable": true
      }
    }
  }
}
```

Create a `neoconf.json` in nvim config directory:

```json
{
  "lsp": {
    "servers": {
      "volar": {
        "disable": true
      }
    }
  }
}
```

Use a function like this in your lspconfig to disable lsp servers per project

```lua
local server_enabled = function(server)
  return not require("neoconf").get("lsp.servers." .. server .. ".disable")
end

```

## Extra

[My neovim config](https://github.com/catgoose/nvim)
[telescope-helpgrep.nvim](https://github.com/catgoose/telescope-helpgrep.nvim)
[do-the-needful.nvim](https://github.com/catgoose/do-the-needful.nvim)
