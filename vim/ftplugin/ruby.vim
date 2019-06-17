" By default, ale will start brakeman if available. Explicitly only enable
" rubocop to avoid high cpu load.
let b:ale_linters = ['rubocop']

let b:ale_fixers = ['rubocop']
