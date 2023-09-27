" TODO only show error. E.g. js-beautify not found when formatting JSON
let g:autoformat_verbosemode=0

let g:formatdef_tidy_xml = '"tidy -q -xml --show-errors 0 --show-warnings 0 --indent auto --indent-spaces ".shiftwidth()." --vertical-space yes --tidy-mark no -wrap ".&textwidth." -utf8"'
