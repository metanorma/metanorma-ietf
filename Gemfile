source "https://rubygems.org"

gemspec

gem "relaton-bib", "~>2.1"

# ogc-gml 1.0.x uses string namespace URIs incompatible with lutaml-model 0.8+
# metanorma-plugin-lutaml 0.7.38 pins ogc-gml ~> 1.0.0; use fix/ruby-4.0 branch
gem "metanorma-plugin-lutaml", github: "metanorma/metanorma-plugin-lutaml", branch: "fix/ruby-4.0"

gem "canon"
gem "equivalent-xml"
gem "htmlentities"
gem "guard"
gem "guard-rspec"
gem "rake"
gem "rspec"
gem "rubocop"
gem "metanorma-standoc", github: "metanorma/metanorma-standoc", branch: "main"
gem "metanorma", github: "metanorma/metanorma", branch: "main"
gem "rubocop-performance"
gem "simplecov"
gem "timecop"
gem "webmock"

eval_gemfile("Gemfile.devel") rescue nil
