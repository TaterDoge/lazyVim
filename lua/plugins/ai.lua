return {
  -- 代码伴侣 https://codecompanion.olimorris.dev
  {
    "olimorris/codecompanion.nvim",
    -- enabled = false,
    lazy = false,
    keys = require("config.ai.codecompanion.init").keys,
    opts = require("config.ai.codecompanion.init").config,
    dependencies = {
      { "nvim-lua/plenary.nvim", version = false },
      "nvim-treesitter/nvim-treesitter",
      "ravitemer/mcphub.nvim",
      "ravitemer/codecompanion-history.nvim",
      "franco-ruggeri/codecompanion-spinner.nvim",
      {
        "j-hui/fidget.nvim",
        opts = {
          notification = {
            window = {
              winblend = 0,
            },
          },
        },
      },
      {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown", "codecompanion" },
        opts = require("config.editor.render-markdown"),
      },
      -- 使用内联助手或 @editor 工具时，使用 mini.diff 获得更清晰的差异
      {
        "nvim-mini/mini.diff",
        config = function()
          local diff = require("mini.diff")
          diff.setup({
            -- Disabled by default
            source = diff.gen_source.none(),
          })
        end,
      },
      -- 使用 img-clip.nvim 通过 :PasteImage 将图像从系统剪贴板复制到聊天缓冲区
      {
        "HakonHarnes/img-clip.nvim",
        opts = {
          filetypes = {
            codecompanion = {
              prompt_for_file_name = false,
              template = "[Image]($FILE_PATH)",
              use_absolute_path = true,
            },
          },
        },
      },
    },
  },

  {
    "ravitemer/mcphub.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    build = "bun add -g mcp-hub@latest",
    opts = {
      port = 37373,
      auto_approve = true,
    },
  },

  {
    "sudo-tee/opencode.nvim",
    config = function()
      require("opencode").setup({
        preferred_picker = "snacks",
        default_mode = "Sisyphus",
      })
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = require("config.editor.render-markdown"),
        ft = { "markdown", "Avante", "copilot-chat", "opencode_output" },
      },
      "saghen/blink.cmp",
      "folke/snacks.nvim",
    },
  },

  {
    "folke/sidekick.nvim",
    keys = {
      {
        "<A-\\>",
        mode = { "n", "i", "t" },
        function()
          require("sidekick.cli").toggle({ name = "opencode", focus = true })
        end,
        desc = "切换 OpenCode",
      },
    },
    opts = {
      nes = {
        enabled = false,
      },
      cli = {
        mux = {
          enabled = true,
          backend = "zellij",
        },
      },
    },
  },
}
