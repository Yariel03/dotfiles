return {
  -- Configuración de Snacks Picker para búsqueda en todo el proyecto
  -- Insensible a mayúsculas/minúsculas y tildes/acentos
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      opts.picker = opts.picker or {}
      opts.picker.sources = opts.picker.sources or {}

      -- Función que expande vocales y caracteres con tilde para que coincidan con ambas variantes en regex
      local function fold_pattern(s)
        local res = vim.fn.substitute(s, "\\c[aáàäâã]", "[aáàäâã]", "g")
        res = vim.fn.substitute(res, "\\c[eéèëê]", "[eéèëê]", "g")
        res = vim.fn.substitute(res, "\\c[iíìïî]", "[iíìïî]", "g")
        res = vim.fn.substitute(res, "\\c[oóòöôõ]", "[oóòöôõ]", "g")
        res = vim.fn.substitute(res, "\\c[uúùüû]", "[uúùüû]", "g")
        res = vim.fn.substitute(res, "\\c[nñ]", "[nñ]", "g")
        return res
      end

      local function fold_accents(str)
        if not str or str == "" then
          return str
        end
        -- Si el usuario escribe expresiones regex avanzadas con corchetes, preservarlas
        if str:find("[", 1, true) or str:find("]", 1, true) then
          return str
        end
        -- Separar argumentos adicionales de grep si existen (ej. 'palabra -- -g *.lua')
        local pattern, pargs = str:match("^(.-)%s+(%-%-.*)$")
        if pattern and pargs then
          return fold_pattern(pattern) .. " " .. pargs
        else
          return fold_pattern(str)
        end
      end

      local grep_config = {
        args = { "-i" }, -- Totalmente insensible a mayúsculas y minúsculas
        filter = {
          transform = function(picker, filter)
            filter.search = fold_accents(filter.search)
          end,
        },
      }

      opts.picker.sources.grep = vim.tbl_deep_extend("force", opts.picker.sources.grep or {}, grep_config)
      opts.picker.sources.grep_buffers = vim.tbl_deep_extend("force", opts.picker.sources.grep_buffers or {}, grep_config)
      opts.picker.sources.grep_word = vim.tbl_deep_extend("force", opts.picker.sources.grep_word or {}, grep_config)
    end,
  },
}
