-- insprired from https://github.com/pandoc/lua-filters/blob/5686d96/diagram-generator/diagram-generator.lua

local function graphviz(code, filetype)
  return pandoc.pipe("dot", { "-T" .. filetype }, code)
end

local counter = 0

function Div(block)
  if block.classes[1] == "graphviz" then
    for i, el in pairs(block.content) do
      if el.t == "CodeBlock" and el.classes[1] == "dot" then
        local success, img = pcall(graphviz, el.text, "svg")

        if success then
          local file = io.open(tostring(counter) .. '.svg','w')
          counter = counter + 1
          file:write(img)
          io.close(file)
        else
          io.stderr:write(tostring(img))
          io.stderr:write('\n')
          error 'Image conversion failed. Aborting.'
        end
      end
    end
  end
end

return {
  { Div = Div }
}
