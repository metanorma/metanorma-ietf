# coding: utf-8

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "metanorma/ietf/version"

Gem::Specification.new do |spec|
  spec.name          = "metanorma-ietf"
  spec.version       = Metanorma::Ietf::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["open.source@ribose.com"]

  spec.summary       = "metanorma-ietf lets you write IETF documents, such as Internet-Drafts and RFCs, in AsciiDoc."
  spec.description   = <<~DESCRIPTION
    metanorma-ietf lets you write IETF documents, such as Internet-Drafts and RFCs,
    in native AsciiDoc syntax. This is part of the Metanorma publishing framework.

    RFC XML ("xml2rfc" Vocabulary XML, RFC 7991) is the XML-based language used for
    writing Internet-Drafts and RFCs, but not everyone likes hand-crafting XML,
    especially when the focus should be on the content.

    This gem is in active development.

    Formerly known as asciidoctor-ietf.
  DESCRIPTION

  spec.homepage      = "https://github.com/metanorma/metanorma-ietf"
  spec.license       = "BSD-2-Clause"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features|bin|.github)/}) \
    || f.match(%r{Rakefile|bin/rspec})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = Gem::Requirement.new(">= 3.1.0")

  spec.add_dependency "metanorma-document"
  spec.add_dependency "metanorma-ietf-data"
  spec.add_dependency "metanorma-standoc", "~> 3.4.2"
  spec.add_dependency "relaton-render"

  spec.metadata["rubygems_mfa_required"] = "true"
end
