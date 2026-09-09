source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}" }

gemspec

# TEMPORARY: cross-PR branch pins so CI can resolve the in-flight
# metanorma-standoc namespace rename (Metanorma::Standoc::Document)
# and the pubid-2 / relaton-bib 2.2 / metanorma-document 0.5 chain.
# Revert each pin once the corresponding PR merges:
#   - https://github.com/metanorma/metanorma-standoc/pull/1232
#   - https://github.com/metanorma/metanorma-document/pull/45
gem "metanorma-standoc", github: "metanorma/metanorma-standoc", branch: "feat/term-grammar-coverage" # TEMPORARY audit chain (stacked)
gem "metanorma-document", github: "metanorma/metanorma-document", branch: "feat/render-new-vocabulary" # TEMPORARY audit chain
gem "isodoc", github: "metanorma/isodoc", branch: "main" # merged as #825
gem "relaton-bib", "~> 2.2.0.pre.alpha.1"
gem "pubid", github: "pubid/pubid", branch: "main"

eval_gemfile("Gemfile.devel") rescue nil

gem "metanorma-mirror", github: "metanorma/metanorma-mirror", branch: "feat/svgmap-imagemap-handlers" # TEMPORARY audit chain
gem "metanorma-iso", github: "metanorma/metanorma-iso", branch: "feat/model-validation-migration" # TEMPORARY audit chain
gem "metanorma-core", github: "metanorma/metanorma-core", branch: "feat/flavor-table" # TEMPORARY audit chain
