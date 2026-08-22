Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}" }

gemspec

# TEMPORARY cross-PR pins (metanorma-core#18 wave)
gem "metanorma-core", github: "metanorma/metanorma-core", branch: "feat/flavor-table"
gem "metanorma-standoc", github: "metanorma/metanorma-standoc", branch: "feat/move-standard-document"
gem "metanorma-document", github: "metanorma/metanorma-document", branch: "feat/model-validation-l1-declarations"
gem "metanorma-iso", github: "metanorma/metanorma-iso", branch: "feat/model-validation-migration"

# pubid-2 / relaton-bib 2.2 chain (isodoc PR#825)
gem "isodoc",
    github: "metanorma/isodoc",
    branch: "rt-pubid-2-migration"
gem "relaton-cli", ">= 2.2.0.pre.alpha.1"
gem "relaton-bib", "~> 2.2.0.pre.alpha.1"
gem "pubid",
    github: "pubid/pubid",
    branch: "main"

eval_gemfile("Gemfile.devel") rescue nil
