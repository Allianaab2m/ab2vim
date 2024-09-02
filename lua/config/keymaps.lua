local M = setmetatable({}, {
	__call = function(m)
		return m.set()
	end,
})

M.lsp = {
	{ "<leader>li", "<cmd>LspInfo<cr>", desc = "Lsp Info" },
	{ "gd", vim.lsp.buf.definition, desc = "Goto Definition", has = "definition" },
	{ "gr", vim.lsp.buf.references, desc = "References", nowait = true },
	{ "gI", vim.lsp.buf.implementation, desc = "Goto Implementation" },
	{ "gy", vim.lsp.buf.type_definition, desc = "Goto T[y]pe Definition" },
	{ "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
	{ "K", vim.lsp.buf.hover, desc = "Hover" },
	{ "gK", vim.lsp.buf.signature_help, desc = "Signature Help", has = "signatureHelp" },
	{ "<c-k>", vim.lsp.buf.signature_help, mode = "i", desc = "Signature Help", has = "signatureHelp" },
	{ "<leader>la", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "v" }, has = "codeAction" },
	{ "<leader>lc", vim.lsp.codelens.run, desc = "Run Codelens", mode = { "n", "v" }, has = "codeLens" },
	{ "<leader>lC", vim.lsp.codelens.refresh, desc = "Refresh & Display Codelens", mode = { "n" }, has = "codeLens" },
	-- {
	-- 	"<leader>cR",
	-- 	require("utils.lsp").rename_file,
	-- 	desc = "Rename File",
	-- 	mode = { "n" },
	-- 	has = { "workspace/didRenameFiles", "workspace/willRenameFiles" },
	-- },
	{ "<leader>lr", vim.lsp.buf.rename, desc = "Rename", has = "rename" },
	-- { "<leader>cA", require("utils.lsp").action.source, desc = "Source Action", has = "codeAction" },
}

M.editor = {
	{ "jj", "<Esc>", mode = { "i" } },
	{ "JJ", "<Esc>", mode = { "i" } },
	{ "jk", "<Esc>", mode = { "i" } },
	{ "JK", "<Esc>", mode = { "i" } },
	{ "kj", "<Esc>", mode = { "i" } },
	{ "KJ", "<Esc>", mode = { "i" } },
}

---@param method string|string[]
M.has = function(buffer, method)
	if type(method) == "table" then
		for _, m in ipairs(method) do
			if M.has(buffer, m) then
				return true
			end
		end
		return false
	end
	method = method:find("/") and method or "textDocument/" .. method
	local clients = require("utils.lsp").get_clients({ bufnr = buffer })
	for _, client in ipairs(clients) do
		if client.supports_method(method) then
			return true
		end
	end
	return false
end

M.set = function()
	for _, keys in pairs(M.editor) do
		vim.keymap.set(keys.mode or "n", keys[1], keys[2])
	end
end

M.on_attach = function(_, buffer)
	local Keys = require("lazy.core.handler.keys")
	for _, keys in pairs(M.lsp) do
		local has = not keys.has or M.has(buffer, keys.has)
		local cond = not (keys.cond == false or ((type(keys.cond) == "function") and not keys.cond()))

		if has and cond then
			local opts = Keys.opts(keys)
			opts.cond = nil
			opts.has = nil
			opts.silent = opts.silent ~= false
			opts.buffer = buffer
			vim.keymap.set(keys.mode or "n", keys[1], keys[2])
		end
	end
end

return M
