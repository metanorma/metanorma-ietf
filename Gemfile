Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}" }

gemspec

# Dependencies needed for lutaml-model 0.8 migration (not yet released)
gem "relaton-bib", github: "relaton/relaton-bib", branch: "fix/lutaml-model-0.8"

# metanorma-plugin-lutaml pins ogc-gml ~> 1.0.0; use branch that relaxes to allow 1.1.x
gem "metanorma-plugin-lutaml", github: "metanorma/metanorma-plugin-lutaml", branch: "relax-ogc-gml-dep"

# Used directly by Transformer (not yet a transitive dependency)
gem "metanorma-document", "~> 0.2.0"
gem "rfcxml", "~> 0.4.0"

eval_gemfile("Gemfile.devel") rescue nil
