source "https://rubygems.org"

gemspec
gem "metanorma-mirror", "~> 1.0", github: "metanorma/metanorma-mirror", branch: "main"

# and the pubid-2 / relaton-bib 2.2 / metanorma-document 0.5 chain.
# Revert each pin once the corresponding PR merges:
#   - https://github.com/metanorma/metanorma-document/pull/45
gem "metanorma-standoc", github: "metanorma/metanorma-standoc", branch: "main"
gem "metanorma-document", github: "metanorma/metanorma-document", branch: "main"
gem "isodoc", github: "metanorma/isodoc", branch: "main" # merged as #825
gem "pubid", "~> 2.0.0.pre.alpha"

gem "canon"
gem "equivalent-xml"
gem "htmlentities"
gem "metanorma", github: "metanorma/metanorma", branch: "main"
gem "metanorma-standoc", github: "metanorma/metanorma-standoc", branch: "main"
gem "rake"
# Gemfile.devel may pin relaton-bib to a git branch (declaring the
# same gem twice aborts the rescued eval_gemfile silently)
gem "relaton-bib", "~>2.1" unless File.exist?(File.join(__dir__, "Gemfile.devel"))
gem "rspec"
gem "rubocop"
gem "rubocop-performance"
gem "simplecov"
gem "timecop"
gem "webmock"

eval_gemfile("Gemfile.devel") rescue nil

gem "metanorma-iso", github: "metanorma/metanorma-iso", branch: "main"
gem "metanorma-core", github: "metanorma/metanorma-core", branch: "main"
# leptris 1.9.359+ drops Declaration#to_xml and changes the validator
# surface (leptris#1733); pin the 1.9.356-era pair until leptris ships
gem "leptris", "1.9.356.0"
gem "moxml", ">= 0.5.113" # the < 0.5.138 cap is stale: the verified pair is moxml 0.5.139 + leptris 1.9.362.1 (relaton 3.0.0.pre.alpha.15)
