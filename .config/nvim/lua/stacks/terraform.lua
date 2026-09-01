-- Terraform stack.
--
-- No Brewfile.stack.terraform: the terraform CLI left homebrew-core when the
-- licence changed and now needs hashicorp/tap plus a manual `brew trust`,
-- which would break an unattended bootstrap. Install the CLI yourself, or use
-- opentofu. The language server below comes from mason either way.

return {
	mason = { "terraformls" },
	treesitter = { "terraform", "hcl" },
	lsp = { "terraformls" },
}
