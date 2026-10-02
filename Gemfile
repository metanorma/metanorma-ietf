source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}" }

gemspec

# The cross-PR branch pins this block replaced are all merged:
#   - metanorma-standoc#1232 (2026-09-05), metanorma-document#45
#     (2026-09-06), isodoc #825/#824 — pin their mainlines instead, which
#     also carry the relaton 3.0.0.pre.alpha.6 chain allowance
#     (isodoc#846: relaton-render >= 1.3.0, < 1.5.0).
gem "metanorma-standoc", github: "metanorma/metanorma-standoc", branch: "main"
gem "metanorma-document", github: "metanorma/metanorma-document", branch: "main"
gem "isodoc", github: "metanorma/isodoc", branch: "main"
gem "relaton-bib", "~> 2.2.0.pre.alpha.1"
gem "pubid", github: "pubid/pubid", branch: "main"

eval_gemfile("Gemfile.devel") rescue nil
