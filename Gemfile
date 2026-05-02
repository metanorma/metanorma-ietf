Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}" }

gemspec

# Local gems for development
gem "lutaml-model", github: "lutaml/lutaml-model", branch: "feat/processing-instructions"
gem "unitsml", path: "../../unitsml/unitsml-ruby"
gem "rfcxml", path: "../rfcxml"
gem "metanorma-document", path: "../metanorma-document"
gem "metanorma-plugin-lutaml", path: "../metanorma-plugin-lutaml"
gem "relaton-bib", path: "../../relaton/relaton-bib"

eval_gemfile("Gemfile.devel") rescue nil
