Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}" }

gemspec

# TEMPORARY cross-PR pins (metanorma-core#18 wave) — identical block in
# every adoption PR; delete when the branches release.
gem "metanorma-core", github: "metanorma/metanorma-core", branch: "feat/flavor-table"
gem "metanorma-standoc", github: "metanorma/metanorma-standoc", branch: "feat/move-standard-document"
gem "metanorma-document", github: "metanorma/metanorma-document", branch: "feat/model-validation-l1-declarations"
gem "metanorma-iso", github: "metanorma/metanorma-iso", branch: "feat/model-validation-migration"

# relaton v3 monogem + pubid-2 prerelease chain (isodoc PR#825)
gem "isodoc",
    github: "metanorma/isodoc",
    branch: "rt-pubid-2-migration"
gem "relaton-cli", ">= 3.0.0.pre.alpha.1"
gem "pubid", "2.0.0.pre.alpha.8" # relaton 3.0.0.pre.alpha.1 pairs with pre-rename pubid; .alpha.9 renamed base_identifier->base
