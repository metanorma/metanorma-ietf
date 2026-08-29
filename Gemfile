source "https://rubygems.org"

gemspec

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
