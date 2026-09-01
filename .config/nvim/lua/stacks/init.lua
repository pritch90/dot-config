-- Stack selection for Neovim.
--
-- Reads the same ~/.config/dotfiles/stacks file that install.sh writes and the
-- zsh config reads, so the editor only sets up tooling for stacks this machine
-- actually has installed.
--
-- Each stack module returns a mostly-declarative table:
--
--   {
--     mason      = { "gopls" },              -- mason-tool-installer entries
--     treesitter = { "go" },                 -- parsers
--     lsp        = { "gopls" },              -- servers to vim.lsp.enable()
--     formatters = { go = { "gofumpt" } },   -- conform formatters_by_ft
--     setup      = function(ctx) end,        -- escape hatch for odd cases
--   }

local M = {}

M.known = { "java", "node", "web", "go", "python", "terraform" }

-- Stacks that pull in another stack. Keep in step with stacks.zsh.
local requires = { web = "node" }

local stacks_file = vim.fn.expand("~/.config/dotfiles/stacks")

local function read_selection()
	local file = io.open(stacks_file, "r")

	-- No selection recorded: enable everything, so a machine that has not run
	-- the installer behaves exactly as it did before stacks existed.
	if not file then
		return vim.deepcopy(M.known)
	end

	local selected, seen = {}, {}
	for line in file:lines() do
		line = line:gsub("#.*", ""):gsub("%s+", "")
		if line ~= "" and not seen[line] then
			seen[line] = true
			table.insert(selected, line)
		end
	end
	file:close()

	for stack, required in pairs(requires) do
		if seen[stack] and not seen[required] then
			seen[required] = true
			table.insert(selected, required)
		end
	end

	return selected
end

M.enabled = {}
M.modules = {}

for _, name in ipairs(read_selection()) do
	local ok, module = pcall(require, "stacks." .. name)
	if ok then
		M.enabled[name] = true
		table.insert(M.modules, module)
	else
		vim.notify("Unknown stack in " .. stacks_file .. ": " .. name, vim.log.levels.WARN)
	end
end

function M.is_enabled(name)
	return M.enabled[name] == true
end

-- Append every enabled stack's contribution to a base list.
function M.collect(field, base)
	local out = vim.deepcopy(base or {})
	for _, module in ipairs(M.modules) do
		for _, value in ipairs(module[field] or {}) do
			table.insert(out, value)
		end
	end
	return out
end

-- Merge every enabled stack's contribution into a base map.
function M.merge(field, base)
	local out = vim.deepcopy(base or {})
	for _, module in ipairs(M.modules) do
		for key, value in pairs(module[field] or {}) do
			out[key] = value
		end
	end
	return out
end

-- Run the escape-hatch setup for stacks that need more than data.
function M.setup_all(ctx)
	for _, module in ipairs(M.modules) do
		if type(module.setup) == "function" then
			module.setup(ctx)
		end
	end
end

return M
