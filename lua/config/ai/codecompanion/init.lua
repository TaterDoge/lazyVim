local M = {}

--- @type string # 默认适配器名称
-- codeplan
local defaultAdapters = "x-aio"
local models = {
  "XAIO-C-4-5-Opus",
  "XAIO-C-4-5-Sonnet",
  "XAIO-O-G5-2",
  "XAIO-O-G5-2-Codex",
  "XAIO-G-3-Pro-Preview",
  "XAIO-G-3-Flash-Preview",
  "GLM-4.7",
  "MiniMax-M2.1",
}
local defaultModel = "XAIO-C-4-5-Opus"
local secondaryModel = "GLM-4.7"

M.keys = {
  {
    "<leader>cp",
    mode = { "n", "v" },
    "<cmd>CodeCompanionChat Toggle<cr>",
    desc = "切换CodeCompanionChat聊天面板",
  },
  {
    "<leader>ae",
    mode = { "n", "v" },
    "<cmd>CodeCompanionActions<cr>",
    desc = "打开CodeCompanionChat操作面板",
  },
}

M.config = {
  -- 配置
  opts = {
    language = "Chinese",
  },

  display = {
    chat = {
      start_in_insert_mode = true, -- 以插入模式打开聊天缓冲区？
    },
  },

  -- 适配器
  adapters = {
    http = {
      -- codeplan
      ["x-aio"] = function()
        -- openai_compatible
        -- anthropic
        return require("codecompanion.adapters").extend("anthropic", {
          name = "codeplan-completions",
          -- url = "https://code-api.x-aio.com/v1/chat/completions",
          url = "https://code-api.x-aio.com/anthropic/v1/messages",
          env = {
            api_key = function()
              return os.getenv("XAIO_API_KEY")
            end,
          },
          schema = {
            model = {
              default = defaultModel,
              choices = models,
            },
            extended_thinking = {
              default = true,
            },
            thinking_budget = {
              default = 16000,
            },
          },
        })
      end,
    },
  },

  -- 交互行为 - 配置操作使用的适配器
  interactions = {
    chat = {
      adapter = defaultAdapters,
      variables = {
        ["buffer"] = {
          opts = {
            default_params = "diff", -- all diff
          },
        },
      },
      tools = {
        opts = {
          default_tools = { "full_stack_dev" },
        },
        ["insert_edit_into_file"] = {
          opts = {
            require_approval_before = {
              buffer = false,
              file = false,
            },
            require_confirmation_after = false,
          },
        },
        ["cmd_runner"] = {
          opts = {
            require_approval_before = false,
            require_cmd_approval = false,
          },
        },
        ["create_file"] = {
          opts = {
            require_approval_before = false,
            require_cmd_approval = false,
          },
        },
        ["grep_search"] = {
          opts = {
            require_approval_before = false,
            require_cmd_approval = false,
          },
        },
        ["read_file"] = {
          opts = {
            require_approval_before = false,
            require_cmd_approval = false,
          },
        },
      },
    },
  },
  prompt_library = {
    markdown = {
      dirs = {
        "~/.config/opencode/command",
      },
    },
  },

  -- 规则
  rules = {},

  -- 扩展
  extensions = {
    history = {
      enabled = true,
      opts = {
        -- Keymap to open history from chat buffer (default: gh)
        keymap = "gh",
        -- Keymap to save the current chat manually (when auto_save is disabled)
        save_chat_keymap = "sc",
        -- Save all chats by default (disable to save only manually using 'sc')
        auto_save = true,
        -- 聊天记录自动删除的天数（0表示禁用该功能）
        expiration_days = 1,
        -- 选择器界面（自动解析为有效的选择器）
        picker = "snacks", --- ("telescope", "snacks", "fzf-lua", or "default")
        -- 可选的过滤功能，用于控制浏览时显示的聊天记录。
        chat_filter = nil, -- function(chat_data) return boolean end
        -- Customize picker keymaps (optional)
        picker_keymaps = {
          rename = { n = "r", i = "<M-r>" },
          delete = { n = "d", i = "<M-d>" },
          duplicate = { n = "<C-y>", i = "<C-y>" },
        },
        ---Automatically generate titles for new chats
        auto_generate_title = true,
        title_generation_opts = {
          ---Adapter for generating titles (defaults to current chat adapter)
          adapter = defaultAdapters, -- "copilot"
          ---Model for generating titles (defaults to current chat model)
          model = secondaryModel, -- "gpt-4o"
          ---Number of user prompts after which to refresh the title (0 to disable)
          refresh_every_n_prompts = 0, -- e.g., 3 to refresh after every 3rd user prompt
          ---Maximum number of times to refresh the title (default: 3)
          max_refreshes = 3,
          format_title = function(original_title)
            -- this can be a custom function that applies some custom
            -- formatting to the title.
            return original_title
          end,
        },
        ---On exiting and entering neovim, loads the last chat on opening chat
        continue_last_chat = false,
        ---When chat is cleared with `gx` delete the chat from history
        delete_on_clearing_chat = false,
        ---Directory path to save the chats
        dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
        ---Enable detailed logging for history extension
        enable_logging = false,

        -- Summary system
        summary = {
          -- Keymap to generate summary for current chat (default: "gcs")
          create_summary_keymap = "gcs",
          -- Keymap to browse summaries (default: "gbs")
          browse_summaries_keymap = "gbs",

          generation_opts = {
            adapter = nil, -- defaults to current chat adapter
            model = nil, -- defaults to current chat model
            context_size = 90000, -- max tokens that the model supports
            include_references = true, -- include slash command content
            include_tool_outputs = true, -- include tool execution results
            system_prompt = nil, -- custom system prompt (string or function)
            format_summary = nil, -- custom function to format generated summary e.g to remove <think/> tags from summary
          },
        },
      },
    },
    mcphub = {
      callback = "mcphub.extensions.codecompanion",
      opts = {
        -- MCP Tools
        make_tools = true, -- Make individual tools (@server__tool) and server groups (@server) from MCP servers
        show_server_tools_in_chat = true, -- Show individual tools in chat completion (when make_tools=true)
        add_mcp_prefix_to_tool_names = false, -- Add mcp__ prefix (e.g `@mcp__github`, `@mcp__neovim__list_issues`)
        show_result_in_chat = true, -- Show tool results directly in chat buffer
        format_tool = nil, -- function(tool_name:string, tool: CodeCompanion.Agent.Tool) : string Function to format tool names to show in the chat buffer
        -- MCP Resources
        make_vars = true, -- Convert MCP resources to #variables for prompts
        -- MCP Prompts
        make_slash_commands = true, -- Add MCP prompts as /slash commands
      },
    },
    spinner = {},
  },
}

vim.api.nvim_create_autocmd("User", {
  pattern = "CodeCompanionChatCreated",
  callback = function(event)
    local chat = require("codecompanion").buf_get_chat(event.data.bufnr)
    if chat then
      -- Insert #buffer at the end of the chat buffer
      local line_count = vim.api.nvim_buf_line_count(event.data.bufnr)
      vim.api.nvim_buf_set_lines(event.data.bufnr, line_count, line_count, false, { "", "#{buffer}", "" })
    end
  end,
})

return M
