-- Node / TypeScript stack.

local M = {}

-- Prefer a project's own eslint setup when it has one, otherwise prettier.
-- Lives here because both binaries are node tools installed with this stack.
function M.js_formatter()
	local eslint_configs = {
		".eslintrc",
		".eslintrc.js",
		".eslintrc.json",
		".eslintrc.yaml",
		"eslint.config.js",
		"eslint.config.mjs",
	}
	for _, config in ipairs(eslint_configs) do
		if vim.fn.filereadable(vim.fn.getcwd() .. "/" .. config) == 1 then
			return { "eslint_d" }
		end
	end
	return { "prettierd" }
end

M.mason = { "ts_ls", "eslint_d", "prettierd", "js-debug-adapter" }
M.treesitter = { "javascript", "typescript", "tsx" }
M.lsp = { "ts_ls" }
M.formatters = {
	javascript = M.js_formatter,
	typescript = M.js_formatter,
	javascriptreact = M.js_formatter,
	typescriptreact = M.js_formatter,
	-- prettierd ships with this stack, so json formatting depends on it.
	json = { "prettierd" },
}

return M
