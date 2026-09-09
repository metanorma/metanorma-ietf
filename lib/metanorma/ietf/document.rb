# frozen_string_literal: true

require "metanorma/standoc"
# Forward-declare parent namespace so this file is safe to require
# directly (without first requiring metanorma/ietf.rb).
module Metanorma
  module Ietf
  end
end


module Metanorma
  module Ietf::Document
    autoload :Metadata, "metanorma/ietf/document/metadata"
    autoload :Root, "metanorma/ietf/document/root"
    autoload :Sections, "metanorma/ietf/document/sections"
  end
end


# Backwards-compat alias so external consumers that reference
# Metanorma::IetfDocument keep resolving during the transition.
module Metanorma
  existing = defined?(Metanorma::IetfDocument) && Metanorma::IetfDocument
  if !existing.equal?(Metanorma::Ietf::Document)
    Metanorma.send(:remove_const, :IetfDocument) if existing
    IetfDocument = Metanorma::Ietf::Document
  end
end

if defined?(Metanorma::Registers::Setup.setup_ietf_register)
  Metanorma::Registers::Setup.setup_ietf_register
end

module Metanorma
  deprecate_constant :IetfDocument
end

require "metanorma-core"

# OCP adoption: ONE registration in the metanorma-core flavor table
# (metanorma-core#18). Lazy: the table exists only on the flavor-table
# line of metanorma-core; skip silently on resolutions without it.
if defined?(Metanorma::Core::Flavors)
  Metanorma::Core::Flavors.register(Metanorma::Core::Flavor.new(
                                      name: :ietf,
                                      gem: "metanorma-ietf",
                                      model_root: Metanorma::Ietf::Document::Root,
                                      pubid_module: nil,
                                      renderers: { html: lambda do |_document, **_options|
                                        require "metanorma/ietf/html"
                                        Metanorma::Ietf::Html::Renderer
                                      end },
                                    ))
end
