source "https://rubygems.org"

gemspec
gem "metanorma-mirror", "~> 1.0", github: "metanorma/metanorma-mirror", branch: "main"

gem "metanorma-standoc", "~> 3.5.7" # Standoc::Document rename
gem "metanorma-document", "~> 0.5.3"
gem "isodoc", "~> 3.7.9"
gem "pubid", "~> 2.0"

gem "canon"
gem "htmlentities"
gem "metanorma", "~> 2.5.14"
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
gem "metanorma-core", "~> 0.2.7" # published flavor/taste table (metanorma-core#18)
# leptris 1.9.359+ drops Declaration#to_xml and changes the validator
# surface (leptris#1733); pin the 1.9.356-era pair until leptris ships
