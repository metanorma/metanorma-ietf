# frozen_string_literal: true

require "metanorma/standoc"
module Metanorma
  module Ietf
  end
end

module Metanorma
  module Ietf::Document
  end
end

module Metanorma
  existing = defined?(Metanorma::IetfDocument) && Metanorma::IetfDocument
  if !existing.equal?(Metanorma::Ietf::Document)
    Metanorma.send(:remove_const, :IetfDocument) if existing
    IetfDocument = Metanorma::Ietf::Document
  end
end

require "metanorma/ietf/registers"
Metanorma::Ietf::Registers.setup

# OCP adoption: ONE registration in the metanorma-core flavor table
require "metanorma-core"

Metanorma::Core::Flavors.register(Metanorma::Core::Flavor.new(
  name: :ietf,
  gem: "metanorma-ietf",
  model_root: Metanorma::Ietf::Document::Root,
  pubid_module: nil,
  renderers: { html: Metanorma::Html::StandardRenderer },
))
