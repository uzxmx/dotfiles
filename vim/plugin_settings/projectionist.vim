let file = expand('~/.projections.global.json')
if filereadable(file)
  let g:projectionist_heuristics = json_decode(join(readfile(file)))
endif
