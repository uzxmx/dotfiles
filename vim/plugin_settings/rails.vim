let g:rails_projections = {
      \ "app/*.rb": {
      \   "alternate": "spec/{}_spec.rb"
      \ },
      \ "app/views/*.json.jbuilder": {
      \   "template": [
      \     "# frozen_string_literal: true"
      \   ]
      \ },
      \ "config/routes.rb": {
      \   "command": "routes"
      \ },
      \ "config/routes/*.rb": {
      \   "command": "routes"
      \ },
      \ "spec/spec_helper.rb": {
      \   "alternate": "spec/rails_helper.rb",
      \   "related": "spec/rails_helper.rb"
      \ },
      \ "spec/rails_helper.rb": {
      \   "command": "railshelper",
      \   "alternate": "spec/rails_helper.rb",
      \   "related": "spec/spec_helper.rb"
      \ },
      \ "spec/factories/*.rb": {
      \   "command": "factory",
      \   "alternate": "app/models/{singular}.rb"
      \ },
      \ "spec/controllers/*_spec.rb": {
      \   "template": [
      \     "# frozen_string_literal: true",
      \     "",
      \     "RSpec.describe {camelcase|capitalize|colons}, type: :controller do",
      \     "end"
      \   ]
      \ },
      \ "spec/models/*_spec.rb": {
      \   "template": [
      \     "# frozen_string_literal: true",
      \     "",
      \     "RSpec.describe {camelcase|capitalize|colons}, type: :model do",
      \     "end"
      \   ]
      \ }}
