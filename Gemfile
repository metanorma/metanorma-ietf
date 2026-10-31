source "https://rubygems.org"

gemspec
gem "metanorma-mirror", "~> 1.0", github: "metanorma/metanorma-mirror", branch: "main"

gem "metanorma-standoc", "~> 3.5.1.pre.alpha" # Standoc::Document rename
gem "metanorma-document", "~> 0.5.2.pre.alpha"
gem "isodoc", "~> 3.7.4.pre.alpha"
gem "pubid", "~> 2.0"

gem "canon"
gem "htmlentities"
gem "metanorma", "~> 2.5.6.pre.alpha"
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
gem "metanorma-core", "~> 0.2.5.pre.alpha" # published flavor/taste table (metanorma-core#18)
# leptris 1.9.359+ drops Declaration#to_xml and changes the validator
# surface (leptris#1733); pin the 1.9.356-era pair until leptris ships
