
function flattenTable(t)
  s = ""
  for k,v in pairs(t) do
    if #s > 0 then s = s .. " " end
    s = s .. tostring(k) .. "=" .. tostring(v)
  end
  return s
end
