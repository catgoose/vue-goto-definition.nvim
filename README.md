# vue-goto-component

<!--toc:start-->

- [vue-goto-component](#vue-goto-component)
  - [About](#about)
  - [Neovim Config](#neovim-config)
    - [Default configuration](#default-configuration)
      - [Filter](#filter)
      - [Defer](#defer)
      - [Framework detection](#framework-detection)
    - [Lazy.nvim](#lazynvim)
  - [Framework and LSP configuration](#framework-and-lsp-configuration)
    - [Vue 3](#vue-3)
    - [Nuxt](#nuxt)
  - [LSP](#lsp)
  <!--toc:end-->

Improves `@vue/typescript-plugin` goto definition functionality

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
  filter = {
    auto_imports = true, -- resolve definitions in auto-imports.d.ts
    auto_components = true, -- resolve definitions in components.d.ts
    same_file = true, -- filter location list entries referencing the current file
    declaration = true, -- filter declaration files unless the only location list
    -- item is a declaration file
  },
  filetypes = { "vue" }, -- enabled for filetypes
  detection = { -- framework detection.  Detection functions can be overridden here
    nuxt = function() -- look for .nuxt directory
      return vim.fn.glob(".nuxt/") ~= ""
    end,
    vue3 = function() -- look for vite.config.ts
      return vim.fn.filereadable("vite.config.ts") == 1
    end,
    priority = { "nuxt", "vue3" }, -- order in which to detect framework
  },
  defer = 100, -- time in ms to wait before resolving imports See below for details
}
```

#### Filter

If after filtering the locationlist items there are multiple items remaining they
will be populated in a locationlist window.

#### Defer

Using `vim.lsp.buf.defintion` in a `.Vue` file on a symbol that is defined in a
typescript file will result in both `tsserver` and `@vue/typescript-plugin` being
called. This plugin attempts to populate a locationlist from each call first before
resolving the definition

I've opened an issue about this [here](https://github.com/vuejs/language-tools/issues/4112)

#### Framework detection

[neoconf](https://github.com/folke/neoconf.nvim) could be used to detect the framework

### Lazy.nvim

```lua
local opts = {
  filter = {
    auto_imports = true,
    auto_components = true,
    same_file = true,
    declaration = true,
  },
  filetypes = { "vue" },
  detection = {
    nuxt = function()
      return vim.fn.glob(".nuxt/") ~= ""
    end,
    vue3 = function()
      return vim.fn.filereadable("vite.config.ts") == 1
    end,
    priority = { "nuxt", "vue3" },
  },
  defer = 100
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

This is how I have configured `tsserver` and `@vue/typescript-plugin`: [nvim config - lspconfig](https://github.com/catgoose/nvim/blob/main/lua/plugins/lspconfig.lua):

```lua
{
  tsserver = {
    capabilities = capabilities,
    on_attach = rename_on_attach,
    init_options = {
    plugins = {
      {
        name = "@vue/typescript-plugin",
        location = "node_modules/@vue/typescript-plugin",
        languages = {
          "vue",
        },
      },
    },
      filetypes = {
      "typescript",
      "javascript",
      "vue",
      }
  }
}
```

Make sure you have installed `@vue/typescript-plugin`
