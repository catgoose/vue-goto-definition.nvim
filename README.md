# vue-goto-definition

<!--toc:start-->

- [vue-goto-definition](#vue-goto-definition)
  - [About](#about)
  - [API](#api)
  - [Neovim Config](#neovim-config)
    - [Default configuration](#default-configuration)
      - [Filter](#filter)
      - [Framework detection](#framework-detection)
    - [Lazy.nvim](#lazynvim)
  - [Framework and LSP configuration](#framework-and-lsp-configuration)
    - [Vue 3](#vue-3)
    - [Nuxt](#nuxt)
    - [lspconfig](#lspconfig)
  - [Extra](#extra)
  <!--toc:end-->

Improves `Volar` language server goto definition functionality

## The Problem

When using vue with autoimports ([unplugin-vue-components](https://github.com/unplugin/unplugin-vue-components) and [unplugin-auto-import](https://github.com/unplugin/unplugin-auto-import) or using [nuxt](https://nuxt.com/)) `vim.lsp.buf.definition` will populate location list with the autoimport definition file and/or the typescript declaration for a symbol.

For example:

| ![default goto definition](https://github.com/catgoose/vue-goto-definition.nvim/blob/screenshots/2024-03-20_07-55.png) |
| :--------------------------------------------------------------------------------------------------------------------: |
|                                  _Default goto definition with unplugin auto-imports_                                  |

| ![goto definition for function in same .vue file](https://github.com/catgoose/vue-goto-definition.nvim/blob/screenshots/loclist_samefile.png) |
| :-------------------------------------------------------------------------------------------------------------------------------------------: |
|                                    _Using the default goto definition for a symbol in the same .vue file_                                     |

Another issue with Volar LSP is that since it uses typescript LSP, when
`vim.lsp.buf.definition` is called it requests definitions from both volar and
tsserver. Since the two LSP can return different results, the consequences can
be unpredictable.

## The Solution

`vue-goto-definition` waits a debounce period (configurable in opts) before
processing definitions. This allows Volar and tsserver time to return definitions.

`vue-goto-definition` overrides `vim.lsp.buf.definition` to attempt to filter the
location list and decide the best source for a symbol's definition.

## API

Calling `goto_definition` directly can be useful if you have set `opts.lsp.override`
to false, disabling autocommand creation to override the default lsp definition.

```lua
require("vue-goto-definition").goto_definition(opts)
```

`opts` is optional and will be passed into `vim.lsp.buf.definition`

## Neovim Config

### Default configuration

```lua
{
  filters = {
    auto_imports = true, -- resolve definitions in auto-imports.d.ts
    auto_components = true, -- resolve definitions in components.d.ts
    import_same_file = true, -- filter location list entries referencing an
    -- import in the current file.  See below for details
    declaration = true, -- filter declaration files unless the only location list
    -- item is a declaration file
    duplicate_filename = true, -- dedupe duplicate filenames
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
  },
  lsp = {
    override_definition = true, -- override vim.lsp.buf.definition
  },
  debounce = 200
}
```

`filters.import_same_file` stops the following from occuring:

```typescript
import { useCounterStore } from "./stores/counter";
const store = useCounterStore();
```

Calling `goto_definition` on `useCounterStore()` can target the import line as
the definition. Setting `filters.import_same_file` will filter those targets
in the same file.

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
    import_same_file = true,
    declaration = true,
    duplicate_filename = true,
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
  },
  lsp = {
    override_definition = true, -- override vim.lsp.buf.definition
  },
  debounce = 200
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

### lspconfig

If you are having trouble getting `Volar` configured correctly check my
[lspconfig.lua](https://github.com/catgoose/nvim/blob/main/lua/plugins/lspconfig.lua)

## Extra

- [My neovim config](https://github.com/catgoose/nvim)
- [telescope-helpgrep.nvim](https://github.com/catgoose/telescope-helpgrep.nvim)
- [do-the-needful.nvim](https://github.com/catgoose/do-the-needful.nvim)
