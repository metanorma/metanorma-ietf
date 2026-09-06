# frozen_string_literal: true

require "bundler/setup"
require "rspec/matchers"
require "metanorma/ietf/document"
require_relative "support/roundtrip_helper"
require_relative "support/shared_roundtrip_examples"

RSpec.describe "IETF document XML round-trip" do
  it_behaves_like "xml round-trip", flavor_dir: "ietf",
                                    doc_class: Metanorma::Ietf::Document::Root
end
