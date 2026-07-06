-- [ ---- OPTIONS ---- ] --

-- Leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Line numbers
vim.opt.nu = true
vim.opt.rnu = true

-- Indentation
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.shiftwidth = 2
vim.opt.breakindent = true

-- Search
vim.opt.incsearch = true -- While typing a search, move the cursor to the first match incrementally
vim.opt.hlsearch = true -- Highlight all matches of the last search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- UI/Display
vim.opt.wrap = true
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 5
vim.opt.list = true
vim.opt.listchars = { trail = "·", nbsp = "␣", tab = "→ " }
vim.opt.fillchars = { eob = " " }

-- Splits
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Folding (treesitter-based)
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99

-- Spell check
vim.o.spell = true
vim.o.spelllang = "en_gb"

-- Misc
vim.opt.mouse = "a"
vim.opt.updatetime = 250
vim.opt.completeopt = { "fuzzy", "menu", "noselect", "popup" }
vim.opt.undofile = true

vim.filetype.add({
	extension = {
		tf = "terraform",
		tfvars = "terraform-vars",
	},
})

-- Clipboard
vim.opt.clipboard = "unnamedplus"

-- [ ---- KEYMAP ---- ] --

-- General editing
vim.keymap.set("n", "<leader>a", "ggVG")
-- vim.keymap.set("i", "jj", "<ESC>")
-- vim.keymap.set("v", "p", '"_dP')
-- vim.keymap.set("v", "x", "_x")

-- File operations
-- vim.keymap.set("i", "<C-s>", "<ESC>:w<cr>", { silent = false })
-- vim.keymap.set("n", "<C-s>", "<ESC>:w<cr>", { silent = false })
-- vim.keymap.set("v", "<C-s>", "<ESC>:w<cmd>", { silent = false })
-- vim.keymap.set("i", "<C-S-s>", "<ESC>:noautocmd w<cr>", { silent = false })
-- vim.keymap.set("n", "<C-S-s>", "<ESC>:noautocmd w<cr>", { silent = false })
-- vim.keymap.set("v", "<C-S-s>", "<ESC>:noautocmd w<cmd>", { silent = false })

-- Undo/Redo
-- vim.keymap.set("i", "<C-z>", "<ESC>:u<cr>a", { silent = false })
-- vim.keymap.set("n", "<C-z>", "<ESC>:u<cr>", { silent = false })
-- vim.keymap.set("v", "<C-z>", "<ESC>:u<cmd>", { silent = false })
-- vim.keymap.set("n", "<leader>r", "<ESC>:redo<cr>", { silent = false })
-- vim.keymap.set("v", "<leader>r", "<ESC>:redo<cr>", { silent = false })

-- Buffer management
vim.keymap.set("n", "<leader>q", ":q<cr>")
-- vim.keymap.set("n", "<leader>bd", ":bd!<cr>")
vim.keymap.set("n", "<leader>ba", function()
	local count = 0
	for _, b in ipairs(vim.api.nvim_list_bufs()) do
		if b ~= vim.api.nvim_get_current_buf() and vim.bo[b].buflisted and not vim.bo[b].modified then
			local success = pcall(vim.api.nvim_buf_delete, b, { force = false })
			if success then
				count = count + 1
			end
		end
	end
	vim.notify(string.format("Cleared %d inactive buffer%s", count, count == 1 and "" or "s"), vim.log.levels.INFO)
end, { desc = "Close all other buffers" })

-- Window management
vim.keymap.set("n", "<leader>ws", ":split<cr>", { desc = "Horizontal split" })
vim.keymap.set("n", "<leader>wv", ":vsplit<cr>", { desc = "Vertical split" })

-- Window resize
vim.keymap.set("n", "<leader>wh", ":vertical resize +5<cr>", { silent = true, desc = "Shrink window left" })
vim.keymap.set("n", "<leader>wl", ":vertical resize -5<cr>", { silent = true, desc = "Expand window right" })
vim.keymap.set("n", "<leader>wk", ":resize +5<cr>", { silent = true, desc = "Expand window up" })
vim.keymap.set("n", "<leader>wj", ":resize -5<cr>", { silent = true, desc = "Shrink window down" })

-- Insert mode navigation
vim.keymap.set("i", "<C-h>", "<Left>", { desc = "Move left" })
vim.keymap.set("i", "<C-j>", "<Down>", { desc = "Move down" })
vim.keymap.set("i", "<C-k>", "<Up>", { desc = "Move up" })
vim.keymap.set("i", "<C-l>", "<Right>", { desc = "Move right" })

-- Quickfix navigation
vim.keymap.set("n", "<leader>ch", ":cprevious<CR>", { desc = "Previous quickfix item" })
vim.keymap.set("n", "<leader>cl", ":cnext<CR>", { desc = "Next quickfix item" })

-- Search
vim.keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- Scrolling
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and centre" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and centre" })

-- [ ---- AUTOCMD ---- ] --
vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
	pattern = "*",
	desc = "Highlight selection on yank",
	callback = function()
		vim.highlight.on_yank({ timeout = 200, visual = true })
	end,
})

-- Auto-reload buffers when files change on disk
local autoreload_group = vim.api.nvim_create_augroup("auto_reload", { clear = true })

-- Rate limiting for auto-reload (in milliseconds)
local last_checktime = 0
local CHECKTIME_INTERVAL = 1000 -- Only check once per second

vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI" }, {
	group = autoreload_group,
	pattern = "*",
	desc = "Check if file has changed on disk and reload if unmodified",
	callback = function()
		-- Only check if buffer is a normal file
		if vim.fn.mode() ~= "c" and vim.bo.buftype == "" then
			local now = vim.uv.now()
			-- Rate limit: only run checktime if enough time has passed
			if now - last_checktime >= CHECKTIME_INTERVAL then
				vim.cmd("checktime")
				last_checktime = now
			end
		end
	end,
})

-- Notification when file is auto-reloaded
vim.api.nvim_create_autocmd("FileChangedShellPost", {
	group = autoreload_group,
	pattern = "*",
	desc = "Notify when file is reloaded from disk",
	callback = function()
		vim.notify("File reloaded from disk: " .. vim.fn.expand("%"), vim.log.levels.INFO)
	end,
})

-- [ ---- PLUGINS ---- ] --

-- CORE DEPENDENCIES
vim.pack.add({
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
})

-- COLOR SCHEME
vim.pack.add({
	{ src = "https://github.com/connorholyday/vim-snazzy" },
	{ src = "https://github.com/rmehri01/onenord.nvim" },
	-- { src = "https://github.com/projekt0n/github-nvim-theme" },
})

vim.g.SnazzyTransparent = 1

vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "snazzy",
	callback = function()
		local groups = {
			"Normal", "NormalNC", "NormalFloat", "FloatBorder",
			"SignColumn", "EndOfBuffer", "LineNr", "CursorLineNr",
			"StatusLine", "StatusLineNC", "VertSplit", "WinSeparator",
			"TabLine", "TabLineFill", "Pmenu",
			"TelescopeNormal", "TelescopeBorder",
			"TelescopePromptNormal", "TelescopePromptBorder",
		}
		for _, g in ipairs(groups) do
			vim.api.nvim_set_hl(0, g, { bg = "none" })
		end
	end,
})

local function apply_dark()
	if vim.g.colors_name ~= "snazzy" then
		vim.o.background = "dark"
		vim.cmd.colorscheme("snazzy")
	end
end
local function apply_light()
	if vim.g.colors_name ~= "onenord" then
		vim.o.background = "light"
		vim.cmd.colorscheme("onenord")
	end
end

local function sync_with_system()
	vim.system({ "defaults", "read", "-g", "AppleInterfaceStyle" }, { text = true }, function(out)
		vim.schedule(function()
			if out.code == 0 and out.stdout:match("Dark") then
				apply_dark()
			else
				apply_light()
			end
		end)
	end)
end

sync_with_system()
vim.api.nvim_create_autocmd("FocusGained", { callback = sync_with_system })

vim.api.nvim_create_user_command("ColorDark", apply_dark, {})
vim.api.nvim_create_user_command("ColorLight", apply_light, {})
vim.api.nvim_create_user_command("ColorAuto", sync_with_system, {})
vim.keymap.set("n", "<leader>td", "<cmd>ColorDark<CR>", { desc = "Theme: dark (snazzy)" })
vim.keymap.set("n", "<leader>tl", "<cmd>ColorLight<CR>", { desc = "Theme: light (github high contrast)" })
vim.keymap.set("n", "<leader>ta", "<cmd>ColorAuto<CR>", { desc = "Theme: follow macOS" })

-- SESSIONS (per-project, using built-in mksession)
local session_dir = vim.fn.stdpath("data") .. "/sessions"
vim.fn.mkdir(session_dir, "p")

local function get_project_root()
	local cwd = vim.fn.getcwd()
	local git_root = vim.fn.systemlist("git -C " .. vim.fn.shellescape(cwd) .. " rev-parse --show-toplevel 2>/dev/null")[1]
	return (git_root and git_root ~= "" and vim.fn.isdirectory(git_root) == 1) and git_root or cwd
end

local function session_file_for_project()
	local root = vim.fs.normalize(get_project_root())
	local name = root:gsub("/", "%%") -- encode path separators
	return session_dir .. "/" .. name .. ".vim"
end

local function save_session()
	-- Only save if there are real file buffers open (not just alpha/empty)
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= "" then
			vim.cmd("mksession! " .. vim.fn.fnameescape(session_file_for_project()))
			return
		end
	end
end

local function has_session()
	return vim.fn.filereadable(session_file_for_project()) == 1
end

local function restore_session()
	local f = session_file_for_project()
	if vim.fn.filereadable(f) == 1 then
		vim.cmd("silent! source " .. vim.fn.fnameescape(f))
	else
		vim.notify("No session found for this project", vim.log.levels.WARN)
	end
end
-- Expose globally for dashboard button
_G.restore_session = restore_session

local function delete_session()
	local f = session_file_for_project()
	if vim.fn.filereadable(f) == 1 then
		vim.fn.delete(f)
		vim.notify("Session deleted", vim.log.levels.INFO)
	end
end

-- Auto-save session on exit
vim.api.nvim_create_autocmd("VimLeavePre", { callback = save_session })

-- Keymaps for manual session control
vim.keymap.set("n", "<leader>ss", save_session, { desc = "Save session" })
vim.keymap.set("n", "<leader>sr", restore_session, { desc = "Restore session" })
vim.keymap.set("n", "<leader>sd", delete_session, { desc = "Delete session" })
vim.keymap.set("n", "<leader>;", ":Alpha<CR>", { desc = "Open dashboard", silent = true })

-- DASHBOARD
vim.pack.add({
	{ src = "https://github.com/goolord/alpha-nvim" },
})

local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

-- Header
dashboard.section.header.val = {
	[[                                                    ]],
	[[ ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗]],
	[[ ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║]],
	[[ ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║]],
	[[ ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║]],
	[[ ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║]],
	[[ ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
}

-- Buttons
local session_label = has_session() and "  Restore session" or "  Restore session (none saved)"
dashboard.section.buttons.val = {
	dashboard.button("s", session_label, has_session() and ":lua restore_session()<CR>" or ""),
	dashboard.button("f", "  Find file", ":Telescope find_files<CR>"),
	dashboard.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
	dashboard.button("g", "  Live grep", ":Telescope live_grep<CR>"),
	dashboard.button("e", "  New file", ":ene <BAR> startinsert<CR>"),
	dashboard.button("c", "  Config", ":e $MYVIMRC<CR>"),
	dashboard.button("q", "  Quit", ":qa<CR>"),
}

-- MRU files scoped to current git project, returned as navigable buttons
local function get_project_mru_buttons(max_files)
	max_files = max_files or 5
	local cwd = vim.fn.getcwd()
	local git_root = vim.fn.systemlist("git -C " .. vim.fn.shellescape(cwd) .. " rev-parse --show-toplevel 2>/dev/null")[1]
	local project_root = (git_root and git_root ~= "" and vim.fn.isdirectory(git_root) == 1) and git_root or cwd
	project_root = vim.fs.normalize(project_root)

	local files = {}
	local shortcut_keys = { "1", "2", "3", "4", "5", "6", "7", "8", "9" }
	for _, filepath in ipairs(vim.v.oldfiles or {}) do
		if #files >= max_files then break end
		local normalized = vim.fs.normalize(filepath)
		if normalized:sub(1, #project_root) == project_root and vim.fn.filereadable(filepath) == 1 then
			table.insert(files, filepath)
		end
	end

	if #files == 0 then
		return {
			type = "text",
			val = "  No recent files in this project",
			opts = { hl = "Comment", position = "center" },
		}
	end

	local buttons = {}
	for i, filepath in ipairs(files) do
		local display = vim.fn.fnamemodify(filepath, ":~:.")
		local key = shortcut_keys[i]
		local btn = dashboard.button(key, "  " .. display, ":e " .. vim.fn.fnameescape(filepath) .. "<CR>")
		btn.opts.align_shortcut = "right"
		btn.opts.width = 60
		table.insert(buttons, btn)
	end

	return { type = "group", val = buttons, opts = { spacing = 0 } }
end

-- Git status for current project
local function git_status_section()
	local cwd = vim.fn.getcwd()
	local branch = vim.fn.systemlist("git -C " .. vim.fn.shellescape(cwd) .. " branch --show-current 2>/dev/null")[1]
	if not branch or branch == "" then
		return { "  Not a git repository" }
	end

	local status = vim.fn.systemlist("git -C " .. vim.fn.shellescape(cwd) .. " status --short 2>/dev/null")
	local staged, modified, untracked = 0, 0, 0
	for _, line in ipairs(status) do
		local x, y = line:sub(1, 1), line:sub(2, 2)
		if x == "?" then
			untracked = untracked + 1
		elseif x ~= " " and x ~= "?" then
			staged = staged + 1
		end
		if y ~= " " and y ~= "?" then
			modified = modified + 1
		end
	end

	local parts = { "  " .. branch }
	if staged > 0 then table.insert(parts, " +" .. staged) end
	if modified > 0 then table.insert(parts, " ~" .. modified) end
	if untracked > 0 then table.insert(parts, " ?" .. untracked) end
	if staged == 0 and modified == 0 and untracked == 0 then
		table.insert(parts, "  clean")
	end
	return { table.concat(parts) }
end

-- Assemble layout and setup alpha at VimEnter (after shada loads oldfiles)
local mru_heading = { type = "text", val = "── Recent (project) ──", opts = { hl = "SpecialComment", position = "center" } }
local git_heading = { type = "text", val = "── Git ──", opts = { hl = "SpecialComment", position = "center" } }
local git_text = { type = "text", val = git_status_section, opts = { hl = "Comment", position = "center" } }

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		-- Rebuild layout now that vim.v.oldfiles is populated
		dashboard.config.layout = {
			{ type = "padding", val = 2 },
			dashboard.section.header,
			{ type = "padding", val = 2 },
			dashboard.section.buttons,
			{ type = "padding", val = 1 },
			mru_heading,
			{ type = "padding", val = 1 },
			get_project_mru_buttons(5),
			{ type = "padding", val = 1 },
			git_heading,
			{ type = "padding", val = 1 },
			git_text,
			{ type = "padding", val = 1 },
			dashboard.section.footer,
		}
		alpha.setup(dashboard.config)

		-- Show dashboard when nvim is started with a directory argument (e.g. `nvim .`)
		local arg = vim.fn.argv(0)
		if arg ~= "" and vim.fn.isdirectory(arg) == 1 then
			vim.cmd("bdelete")
			alpha.start()
		end
	end,
})

-- LUALINE
vim.pack.add({
	{ src = "https://github.com/nvim-lualine/lualine.nvim" },
})
require("lualine").setup({
	options = {
		theme = "auto",
		component_separators = { left = "|", right = "|" },
		section_separators = { left = "", right = "" },
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch", "diff", "diagnostics" },
		lualine_c = { { "filename", path = 2 } }, -- 2 = full path
		lualine_x = { "progress" },
		lualine_y = { "filetype" },
		lualine_z = {},
	},
})

-- GITSIGNS
vim.pack.add({
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },
})
require("gitsigns").setup({
	current_line_blame = true,
})

-- SMART SPLITS
vim.pack.add({
	{ src = "https://github.com/mrjones2014/smart-splits.nvim" },
})
-- Moving between splits
vim.keymap.set("n", "<C-h>", require("smart-splits").move_cursor_left, { desc = "Move to left split" })
vim.keymap.set("n", "<C-j>", require("smart-splits").move_cursor_down, { desc = "Move to below split" })
vim.keymap.set("n", "<C-k>", require("smart-splits").move_cursor_up, { desc = "Move to above split" })
vim.keymap.set("n", "<C-l>", require("smart-splits").move_cursor_right, { desc = "Move to right split" })

-- YAZI
vim.pack.add({
	{ src = "https://github.com/mikavilpas/yazi.nvim" },
})
vim.g.loaded_netrwPlugin = 1
require("yazi").setup({
	open_for_directories = false,
})
vim.keymap.set("n", "<leader>fd", ":Yazi<CR>", { noremap = true, silent = true, desc = "Open file manager" })

-- ARROW
-- vim.pack.add({
-- 	{ src = "https://github.com/otavioschwanck/arrow.nvim" },
-- })
-- require("arrow").setup({
-- 	show_icons = true,
-- 	leader_key = "'",
-- 	buffer_leader_key = "m",
-- })

-- TELESCOPE
vim.pack.add({
	{ src = "https://github.com/nvim-telescope/telescope.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope-live-grep-args.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope-ui-select.nvim" },
	{ src = "https://github.com/kkharji/sqlite.lua" },
	{ src = "https://github.com/danielfalk/smart-open.nvim" },
})
local telescope = require("telescope")
local builtin = require("telescope.builtin")
local actions = require("telescope.actions")
local themes = require("telescope.themes")
telescope.setup({
	defaults = {
		path_display = { "truncate " },
		mappings = {
			i = {
				["<C-k>"] = actions.move_selection_previous,
				["<C-j>"] = actions.move_selection_next,
				["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
			},
		},
	},
	pickers = {
		buffers = {
			sort_lastused = true,
			show_all_buffers = true,
			ignore_current_buffer = false,
			bufnr_width = 0,
			mappings = {
				i = {
					["<C-d>"] = actions.delete_buffer,
				},
			},
		},
	},
	extensions = {
		live_grep_args = {
			auto_quoting = true,
		},
		["ui-select"] = {
			-- require("telescope.themes").get_dropdown({}),
			-- require("telescope.themes").get_cursor({
			-- 	-- Cursor theme provides a better experience for confirmations
			-- 	layout_config = {
			-- 		width = 0.5,
			-- 		height = 0.4,
			-- 	},
			-- }),
			themes.get_dropdown({
				layout_config = {
					width = 0.8,
					height = 0.8,
				},
			}),
		},
	},
})
telescope.load_extension("live_grep_args")
telescope.load_extension("smart_open")
telescope.load_extension("ui-select")

-- Telescope keymaps
vim.keymap.set("n", "<leader><leader>", function()
	builtin.find_files({
		find_command = {
			"fd", "--type", "f", "--hidden", "--no-ignore-vcs",
			"--exclude", ".git",
			"--exclude", "node_modules",
			"--exclude", "bin",
			"--exclude", "dist",
			"--exclude", "build",
			"--exclude", ".next",
			"--exclude", "coverage",
		},
	})
end, { desc = "Find files" })
vim.keymap.set("n", "<leader>ff", function()
	telescope.extensions.live_grep_args.live_grep_args()
end, { desc = "Live grep" })
vim.keymap.set("n", "<leader>e", builtin.buffers, { desc = "Open buffers" })
vim.keymap.set("n", "<leader>s", function()
	require("telescope").extensions.smart_open.smart_open()
end, { noremap = true, silent = true, desc = "Smart open" })
vim.keymap.set("n", "<leader>fc", function()
	builtin.commands({ show_user_commands = true })
end, { desc = "Find commands" })

-- TREESITTER
vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main" },
	{ src = "https://github.com/windwp/nvim-ts-autotag" },
})

vim.treesitter.language.register("markdown", "mdx")

require("nvim-treesitter").setup()

-- Auto-install parsers
local ensure_installed = {
	"json",
	"javascript",
	"typescript",
	"tsx",
	"yaml",
	"html",
	"css",
	"markdown",
	"markdown_inline",
	"bash",
	"lua",
	"vim",
	"dockerfile",
	"gitignore",
	"c",
	"rust",
	"zig",
	"odin",
	"vue",
  "svelte",
	"go",
	"gomod",
	"gosum",
	"gowork",
}
local installed = require("nvim-treesitter").get_installed("parsers")
local installed_set = {}
for _, p in ipairs(installed) do
	installed_set[p] = true
end
local to_install = {}
for _, p in ipairs(ensure_installed) do
	if not installed_set[p] then
		to_install[#to_install + 1] = p
	end
end
if #to_install > 0 then
	require("nvim-treesitter").install(to_install)
end

-- Ensure treesitter attaches to buffers so render-markdown can find the parser
vim.api.nvim_create_autocmd("FileType", {
	callback = function(args)
		pcall(vim.treesitter.start, args.buf)
	end,
})

-- nvim-ts-autotag setup
require("nvim-ts-autotag").setup()

-- TREESITTER TEXTOBJECTS
require("nvim-treesitter-textobjects").setup()

-- Selection: e.g. vaf (around function), vif (inner function)
vim.keymap.set({ "x", "o" }, "af", function()
	require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
end, { desc = "Around function" })
vim.keymap.set({ "x", "o" }, "if", function()
	require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
end, { desc = "Inner function" })
vim.keymap.set({ "x", "o" }, "ac", function()
	require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
end, { desc = "Around class" })
vim.keymap.set({ "x", "o" }, "ic", function()
	require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
end, { desc = "Inner class" })
vim.keymap.set({ "x", "o" }, "aa", function()
	require("nvim-treesitter-textobjects.select").select_textobject("@parameter.outer", "textobjects")
end, { desc = "Around parameter" })
vim.keymap.set({ "x", "o" }, "ia", function()
	require("nvim-treesitter-textobjects.select").select_textobject("@parameter.inner", "textobjects")
end, { desc = "Inner parameter" })
vim.keymap.set({ "x", "o" }, "ai", function()
	require("nvim-treesitter-textobjects.select").select_textobject("@conditional.outer", "textobjects")
end, { desc = "Around conditional" })
vim.keymap.set({ "x", "o" }, "ii", function()
	require("nvim-treesitter-textobjects.select").select_textobject("@conditional.inner", "textobjects")
end, { desc = "Inner conditional" })
vim.keymap.set({ "x", "o" }, "al", function()
	require("nvim-treesitter-textobjects.select").select_textobject("@loop.outer", "textobjects")
end, { desc = "Around loop" })
vim.keymap.set({ "x", "o" }, "il", function()
	require("nvim-treesitter-textobjects.select").select_textobject("@loop.inner", "textobjects")
end, { desc = "Inner loop" })

-- Movement: jump between functions, classes, parameters
local move = require("nvim-treesitter-textobjects.move")
vim.keymap.set({ "n", "x", "o" }, "]f", function()
	move.goto_next_start("@function.outer", "textobjects")
end, { desc = "Next function start" })
vim.keymap.set({ "n", "x", "o" }, "]F", function()
	move.goto_next_end("@function.outer", "textobjects")
end, { desc = "Next function end" })
vim.keymap.set({ "n", "x", "o" }, "[f", function()
	move.goto_previous_start("@function.outer", "textobjects")
end, { desc = "Previous function start" })
vim.keymap.set({ "n", "x", "o" }, "[F", function()
	move.goto_previous_end("@function.outer", "textobjects")
end, { desc = "Previous function end" })
vim.keymap.set({ "n", "x", "o" }, "]c", function()
	move.goto_next_start("@class.outer", "textobjects")
end, { desc = "Next class start" })
vim.keymap.set({ "n", "x", "o" }, "[c", function()
	move.goto_previous_start("@class.outer", "textobjects")
end, { desc = "Previous class start" })
vim.keymap.set({ "n", "x", "o" }, "]a", function()
	move.goto_next_start("@parameter.outer", "textobjects")
end, { desc = "Next parameter" })
vim.keymap.set({ "n", "x", "o" }, "[a", function()
	move.goto_previous_start("@parameter.outer", "textobjects")
end, { desc = "Previous parameter" })

-- Swap: move parameters left/right
local swap = require("nvim-treesitter-textobjects.swap")
vim.keymap.set("n", "<leader>sa", function()
	swap.swap_next("@parameter.inner")
end, { desc = "Swap parameter forward" })
vim.keymap.set("n", "<leader>sA", function()
	swap.swap_previous("@parameter.inner")
end, { desc = "Swap parameter backward" })

-- RENDER MARKDOWN
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown", "mdx" },
	once = true,
	callback = function()
		vim.pack.add({
			{ src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
		})
		require("render-markdown").setup({})
	end,
})

-- MINI.NVIM
vim.pack.add({
	{ src = "https://github.com/echasnovski/mini.ai" },
	{ src = "https://github.com/echasnovski/mini.surround" },
	{ src = "https://github.com/echasnovski/mini.pairs" },
})
require("mini.ai").setup()
require("mini.surround").setup()
require("mini.pairs").setup()

-- BLINK.CMP
vim.pack.add({
	{ src = "https://github.com/saghen/blink.cmp", version = vim.version.range("^1") },
})

require("blink.cmp").setup({
	fuzzy = { implementation = "prefer_rust_with_warning" },
	signature = { enabled = true },
	keymap = {
		preset = "default",
		["<C-space>"] = {},
		["<C-p>"] = {},
		-- ["<Tab>"] = { "select_and_accept", "fallback" },
		["<Enter>"] = { "select_and_accept", "fallback" },
		["<S-Tab>"] = {},
		["<C-y>"] = { "show", "show_documentation", "hide_documentation" },
		["<C-n>"] = { "select_and_accept" },
		["<C-k>"] = { "select_prev", "fallback" },
		["<C-j>"] = { "select_next", "fallback" },
		["<C-d>"] = { "scroll_documentation_down", "fallback" },
		["<C-u>"] = { "scroll_documentation_up", "fallback" },
		["<C-l>"] = { "snippet_forward", "fallback" },
		["<C-h>"] = { "snippet_backward", "fallback" },
	},

	appearance = {
		use_nvim_cmp_as_default = true,
		nerd_font_variant = "normal",
	},

	completion = {
		trigger = {
			show_on_insert_on_trigger_character = true,
		},
		documentation = {
			auto_show = true,
			auto_show_delay_ms = 200,
		},
	},

	cmdline = {
		keymap = {
			preset = "inherit",
			["<CR>"] = { "accept_and_enter", "fallback" },
		},
	},

	sources = { default = { "lsp", "path", "snippets", "buffer" } },
})

-- LSP
vim.pack.add({
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/mason-org/mason-lspconfig.nvim" },
	{ src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
})
require("mason").setup()
require("mason-lspconfig").setup({
	automatic_enable = false, -- Prevent auto-starting LSPs (we manually enable them below)
})
require("mason-tool-installer").setup({
	ensure_installed = {
		"lua_ls",
		"stylua",
		"ts_ls",
		"js-debug-adapter",
		"vue_ls",
		"eslint_d",
		"prettierd",
		"yamlls",
		"svelte-language-server",
		"basedpyright",
		"ruff",
		"gopls",
		"terraformls",
		"gofumpt",
		"goimports",
		"golangci-lint",
		"delve",
	},
})

-- Configure LSP servers
local capabilities = require("blink.cmp").get_lsp_capabilities()

vim.lsp.config("ts_ls", {
	capabilities = capabilities,
	init_options = {
		plugins = {
			{
				name = "@vue/typescript-plugin",
				location = vim.fn.stdpath("data")
					.. "/mason/packages/vue-language-server/node_modules/@vue/language-server/node_modules/@vue/typescript-plugin",
				languages = { "vue" },
			},
		},
	},
	filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
})

vim.lsp.config("yamlls", {
	capabilities = capabilities,
})

vim.lsp.config("svelte", {
	capabilities = capabilities,
})

vim.lsp.config("basedpyright", {
	capabilities = capabilities,
})

vim.lsp.config("gopls", {
	capabilities = capabilities,
	settings = {
		gopls = {
			analyses = {
				unusedparams = true,
				shadow = true,
			},
			staticcheck = true,
			gofumpt = true,
			completeUnimported = true,
			usePlaceholders = true,
		},
	},
})

vim.lsp.config("terraformls", {
	capabilities = capabilities,
})

vim.lsp.enable("ts_ls")
vim.lsp.enable("lua_ls")
vim.lsp.enable("vue_ls")
vim.lsp.enable("yamlls")
vim.lsp.enable("svelte")
vim.lsp.enable("basedpyright")
vim.lsp.enable("ruff")
vim.lsp.enable("gopls")
vim.lsp.enable("terraformls")

-- LSP keymaps
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions" })
vim.keymap.set("v", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
vim.keymap.set("n", "<leader>lr", ":lsp restart<CR>", { desc = "Restart LSP" })
vim.keymap.set("n", "<leader>ls", function()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	if #clients == 0 then
		print("No LSP clients active for this buffer")
	else
		print("Active LSP clients:")
		for _, client in ipairs(clients) do
			print("  - " .. client.name)
		end
	end
end, { desc = "Show active LSPs" })
vim.keymap.set("n", "<leader>ld", function()
	vim.cmd.edit(vim.lsp.get_log_path())
	vim.cmd("normal! G")
end, { desc = "Open LSP log" })
vim.keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", { desc = "References" })
vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", { desc = "Go to definition" })
vim.keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", { desc = "Go to implementation" })
vim.keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", { desc = "Go to type definition" })

-- LSP FILE OPERATIONS
vim.pack.add({
	{ src = "https://github.com/antosha417/nvim-lsp-file-operations" },
})
require("lsp-file-operations").setup()

-- FIDGET
vim.pack.add({
	{ src = "https://github.com/j-hui/fidget.nvim" },
})
require("fidget").setup()

-- CONFORM
vim.pack.add({
	{ src = "https://github.com/stevearc/conform.nvim" },
})
local conform = require("conform")

-- Helper to detect which formatter to use for JS/TS projects
local function js_formatter()
	-- Check for eslint config files
	local eslint_configs =
		{ ".eslintrc", ".eslintrc.js", ".eslintrc.json", ".eslintrc.yaml", "eslint.config.js", "eslint.config.mjs" }
	for _, config in ipairs(eslint_configs) do
		if vim.fn.filereadable(vim.fn.getcwd() .. "/" .. config) == 1 then
			return { "eslint_d" }
		end
	end
	-- Default to prettier
	return { "prettierd" }
end

conform.setup({
	log_level = vim.log.levels.ERROR,
	notify_on_error = true,
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "ruff_organize_imports", "ruff_format" },
		rust = { "rustfmt" },
		go = { "goimports", "gofumpt" },
		json = { "prettierd" },
		javascript = js_formatter,
		typescript = js_formatter,
		javascriptreact = js_formatter,
		typescriptreact = js_formatter,
		vue = js_formatter,
	},
	-- Use format_on_save to automatically format files
	format_on_save = false,
})

-- Conform keymaps
vim.keymap.set({ "n", "v" }, "<leader>fp", function()
	print("Format keybinding triggered")
	local success, err = pcall(function()
		conform.format({
			lsp_format = "fallback",
			async = false,
			timeout_ms = 1000,
		})
	end)
	if not success then
		print("Format error: " .. tostring(err))
	end
end, { desc = "Format file or selection" })

-- TROUBLE
local trouble_loaded = false
local function ensure_trouble()
	if trouble_loaded then
		return
	end
	trouble_loaded = true
	vim.pack.add({
		{ src = "https://github.com/folke/trouble.nvim" },
	})
	require("trouble").setup()
end
vim.keymap.set("n", "<leader>t", function()
	ensure_trouble()
	vim.cmd("Trouble")
end, { desc = "Toggle diagnostics" })

-- WHICH-KEY
vim.pack.add({
	{ src = "https://github.com/folke/which-key.nvim" },
})
require("which-key").setup({
	delay = 300,
})

-- NVIM-DAP (Debug Adapter Protocol) — deferred to first use
local dap_loaded = false
local function ensure_dap()
	if dap_loaded then
		return
	end
	dap_loaded = true

	vim.pack.add({
		{ src = "https://github.com/mfussenegger/nvim-dap" },
		{ src = "https://github.com/rcarriga/nvim-dap-ui" },
		{ src = "https://github.com/nvim-neotest/nvim-nio" },
		{ src = "https://github.com/theHamsta/nvim-dap-virtual-text" },
	})

	local dap = require("dap")
	local dapui = require("dapui")

	dapui.setup({
		layouts = {
			{
				elements = {
					{ id = "watches", size = 0.35 },
					{ id = "repl", size = 0.65 },
				},
				position = "left",
				size = 42,
			},
			{
				elements = {
					{ id = "scopes", size = 0.5 },
					{ id = "console", size = 0.5 },
				},
				position = "bottom",
				size = 14,
			},
		},
	})

	require("nvim-dap-virtual-text").setup()

	-- Automatically open/close dap-ui
	dap.listeners.before.attach.dapui_config = function()
		dapui.open()
	end
	dap.listeners.before.launch.dapui_config = function()
		dapui.open()
	end
	dap.listeners.before.event_terminated.dapui_config = function()
		dapui.close()
	end
	dap.listeners.before.event_exited.dapui_config = function()
		dapui.close()
	end

	-- Node.js adapter configuration (matching VSCode launch.json)
	dap.adapters["pwa-node"] = {
		type = "server",
		host = "localhost",
		port = "${port}",
		executable = {
			command = "js-debug-adapter",
			args = { "${port}" },
		},
	}
	dap.adapters.node = dap.adapters["pwa-node"]

	dap.configurations.javascript = {
		{
			type = "pwa-node",
			request = "launch",
			name = "debug local server",
			cwd = "${workspaceFolder}",
			runtimeExecutable = "pnpm",
			runtimeArgs = { "dev" },
			console = "integratedTerminal",
			skipFiles = { "<node_internals>/**", "**/node_modules/**" },
			env = { NODE_ENV = "development" },
			sourceMaps = true,
			autoAttachChildProcesses = true,
			resolveSourceMapLocations = {
				"${workspaceFolder}/**",
				"!**/node_modules/**",
			},
			outputCapture = "console",
			trace = true,
		},
	}

	dap.configurations.typescript = dap.configurations.javascript
	dap.configurations.typescriptreact = dap.configurations.javascript
	dap.configurations.javascriptreact = dap.configurations.javascript

	-- Go (delve) adapter
	dap.adapters.delve = function(callback, config)
		if config.mode == "remote" and config.request == "attach" then
			callback({
				type = "server",
				host = config.host or "127.0.0.1",
				port = config.port or "38697",
			})
		else
			callback({
				type = "server",
				port = "${port}",
				executable = {
					command = "dlv",
					args = { "dap", "-l", "127.0.0.1:${port}", "--log", "--log-output=dap" },
					detached = vim.fn.has("win32") == 0,
				},
			})
		end
	end

	dap.configurations.go = {
		{
			type = "delve",
			name = "Debug",
			request = "launch",
			program = "${file}",
		},
		{
			type = "delve",
			name = "Debug package",
			request = "launch",
			program = "${fileDirname}",
		},
		{
			type = "delve",
			name = "Debug test (file)",
			request = "launch",
			mode = "test",
			program = "${file}",
		},
		{
			type = "delve",
			name = "Debug test (package)",
			request = "launch",
			mode = "test",
			program = "${fileDirname}",
		},
	}
end

-- DAP keymaps — each ensures DAP is loaded before calling the real function
local dap_keymap = function(key, fn_name, desc)
	vim.keymap.set("n", key, function()
		ensure_dap()
		local dap = require("dap")
		local dapui = require("dapui")
		local fn_map = {
			toggle_breakpoint = dap.toggle_breakpoint,
			continue = dap.continue,
			step_into = dap.step_into,
			step_over = dap.step_over,
			step_out = dap.step_out,
			terminate = dap.terminate,
			repl_open = dap.repl.open,
			run_last = dap.run_last,
			ui_toggle = dapui.toggle,
			hover = function()
				require("dap.ui.widgets").hover()
			end,
			reset = function()
				dap.terminate()
				dap.disconnect()
				dap.clear_breakpoints()
				dapui.toggle()
			end,
		}
		fn_map[fn_name]()
	end, { desc = desc })
end

dap_keymap("<leader>db", "toggle_breakpoint", "Toggle breakpoint")
dap_keymap("<leader>dc", "continue", "Continue debugging")
dap_keymap("<leader>dsi", "step_into", "Step into")
dap_keymap("<leader>dso", "step_over", "Step over")
dap_keymap("<leader>dsO", "step_out", "Step out")
dap_keymap("<leader>dt", "terminate", "Stop debugger")
dap_keymap("<leader>dR", "repl_open", "Open debug REPL")
dap_keymap("<leader>dl", "run_last", "Re-run last debug config")
dap_keymap("<leader>du", "ui_toggle", "Toggle debug UI")
dap_keymap("<leader>dr", "reset", "Reset debugger")
dap_keymap("<leader>dh", "hover", "Debug hover")

-- Java — deferred to first java file
vim.api.nvim_create_autocmd("FileType", {
	pattern = "java",
	once = true,
	callback = function()
		vim.pack.add({
			{ src = "https://github.com/MunifTanjim/nui.nvim" },
			{ src = "https://github.com/mfussenegger/nvim-dap" },
			{ src = "https://github.com/nvim-java/lua-async-await" },
			{ src = "https://github.com/nvim-java/nvim-java-core" },
			{ src = "https://github.com/nvim-java/nvim-java-refactor" },
			{ src = "https://github.com/nvim-java/nvim-java-test" },
			{ src = "https://github.com/nvim-java/nvim-java-dap" },
			{ src = "https://github.com/JavaHello/spring-boot.nvim" },
			{ src = "https://github.com/nvim-java/nvim-java" },
		})

		local jdtls_java_version = vim.env.JDTLS_JAVA_VERSION or "25.0.3-amzn"
		local java_candidates = {
			vim.env.JDTLS_JAVA_HOME,
			vim.fn.expand("~/.sdkman/candidates/java/" .. jdtls_java_version),
			vim.env.JAVA_HOME,
		}
		local jdtls_java_home
		for _, candidate in ipairs(java_candidates) do
			if candidate and candidate ~= "" and vim.fn.executable(candidate .. "/bin/java") == 1 then
				jdtls_java_home = candidate
				break
			end
		end

		if jdtls_java_home then
			vim.env.JAVA_HOME = jdtls_java_home
			vim.env.PATH = jdtls_java_home .. "/bin:" .. vim.env.PATH
		else
			vim.notify("JDTLS Java not found for version: " .. jdtls_java_version, vim.log.levels.WARN)
		end

		require("java").setup({
			root_markers = {
				"settings.gradle",
				"settings.gradle.kts",
				"pom.xml",
				"build.gradle",
				"mvnw",
				"gradlew",
				"build.gradle.kts",
			},
			jdk = {
				auto_install = false,
			},
			java_test = {
				enable = true,
			},
			java_debug_adapter = {
				enable = true,
			},
			spring_boot_tools = {
				enable = false,
			},
			notifications = {
				dap = false,
			},
		})

		vim.lsp.enable("jdtls")
		-- Re-trigger FileType so jdtls attaches to the current buffer
		vim.schedule(function()
			vim.api.nvim_exec_autocmds("FileType", { buffer = vim.api.nvim_get_current_buf() })
		end)

		-- Ensure Java DAP configs are populated after JDTLS attaches
		ensure_dap()
		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(args)
				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if not client or client.name ~= "jdtls" then
					return
				end
				vim.defer_fn(function()
					local dap = require("dap")
					if not dap.configurations.java or #dap.configurations.java == 0 then
						local ok, java_dap = pcall(require, "java-dap")
						if ok then
							java_dap.config_dap()
						end
					end
				end, 3000)
			end,
		})

		-- Java keymaps
		vim.keymap.set("n", "<leader>jr", ":JavaTestRunCurrentMethod<CR>", { desc = "Run current test method" })
		vim.keymap.set("n", "<leader>jR", ":JavaTestRunCurrentClass<CR>", { desc = "Run current test class" })
		vim.keymap.set("n", "<leader>jd", ":JavaTestDebugCurrentMethod<CR>", { desc = "Debug current test method" })
		vim.keymap.set("n", "<leader>jD", ":JavaTestDebugCurrentClass<CR>", { desc = "Debug current test class" })
		vim.keymap.set("n", "<leader>jt", ":JavaTestViewLastReport<CR>", { desc = "View last test report" })
	end,
})
