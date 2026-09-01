-- Go stack.

return {
	mason = { "gopls", "gofumpt", "goimports", "golangci-lint", "delve" },
	treesitter = { "go", "gomod", "gosum", "gowork" },
	lsp = { "gopls" },
	formatters = { go = { "goimports", "gofumpt" } },
}
