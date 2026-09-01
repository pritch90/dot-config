-- Python stack. Tooling is mason-installed, so there is no Brewfile.stack.python.

return {
	mason = { "basedpyright", "ruff" },
	treesitter = { "python" },
	lsp = { "basedpyright", "ruff" },
	formatters = { python = { "ruff_organize_imports", "ruff_format" } },
}
