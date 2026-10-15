source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}" }

gemspec
gem "metanorma-mirror", "~> 1.0", github: "metanorma/metanorma-mirror", branch: "main"

# and the pubid-2 / relaton-bib 2.2 / metanorma-document 0.5 chain.
# Revert each pin once the corresponding PR merges:
#   - https://github.com/metanorma/metanorma-document/pull/45
gem "metanorma-standoc", github: "metanorma/metanorma-standoc", branch: "main"
gem "metanorma-document", github: "metanorma/metanorma-document", branch: "main"
gem "isodoc", github: "metanorma/isodoc", branch: "main" # merged as #825
gem "pubid", "~> 2.0.0.pre.alpha"

eval_gemfile("Gemfile.devel") rescue nil

gem "metanorma-iso", github: "metanorma/metanorma-iso", branch: "main"
gem "metanorma-core", github: "metanorma/metanorma-core", branch: "main"
