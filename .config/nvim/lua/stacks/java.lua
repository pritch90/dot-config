-- Java stack.
--
-- jdtls is not a mason-tool-installer entry: nvim-java manages its own jdtls,
-- and the whole setup is deferred to the first java buffer so a non-Java
-- session never pays for it.
--
-- The JDK comes from SDKMAN, pinned by JDTLS_JAVA_VERSION in versions.env.

local M = {}

M.treesitter = { "java" }

-- ctx.ensure_dap lazily loads nvim-dap; it is owned by init.lua because the
-- other debug configurations share it.
function M.setup(ctx)
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
			ctx.ensure_dap()
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
end

return M
