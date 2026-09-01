-- Web stack: Vue and Svelte. Runs on top of the node stack, which the stack
-- loader pulls in automatically.

local node = require("stacks.node")

return {
	mason = { "vue_ls", "svelte-language-server" },
	treesitter = { "html", "css", "vue", "svelte" },
	lsp = { "vue_ls", "svelte" },
	formatters = { vue = node.js_formatter },
}
