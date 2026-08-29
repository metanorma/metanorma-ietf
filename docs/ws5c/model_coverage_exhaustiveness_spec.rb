# frozen_string_literal: true

# PROTOTYPE — WS5c joint 2 deliverable (2026-08-08).
# Exhaustiveness spec: every lutaml-model attribute reachable from
# Metanorma::IetfDocument::Root must be either READ somewhere in the
# transformer sources or listed on an explicit IGNORED list with a reason.
# A model upgrade that adds an attribute, or renames one out from under a
# transformer read-site, fails this spec instead of silently dropping content.
#
# Intended home: spec/model_coverage_spec.rb in metanorma-ietf (branch
# qa/transformer-integration). Requires only the gems the suite already uses.
#
# Two examples:
#   1. coverage   — no reachable attribute is neither read nor ignored.
#   2. guard validity — every accessor name the transformer probes via
#      respond_to? / method_defined? / public_send-with-literal exists on at
#      least one reachable class. This is the dead-guard detector: it catches
#      the `:definition_lists`-vs-`:dl` class of bug (WS5b) and the
#      `:class_attr`-vs-`:figure_class` dead pseudocode dispatch (WS5c).

require "spec_helper"
require "set"

RSpec.describe "transformer model coverage" do
  TRANSFORMER_SOURCES = (
    Dir[File.expand_path("../lib/metanorma/ietf/transformer/**/*.rb", __dir__)] +
    [File.expand_path("../lib/metanorma/ietf/transformer.rb", __dir__)]
  ).freeze

  # --- reflection: BFS over model classes reachable from Root -------------

  def model_class?(klass)
    klass.is_a?(Class) && klass < Lutaml::Model::Serializable
  end

  def reachable_classes(root)
    seen = {}
    queue = [root]
    until queue.empty?
      klass = queue.shift
      next if seen.key?(klass)

      seen[klass] = klass.attributes
      klass.attributes.each_value do |attr|
        t = (attr.type rescue nil)
        queue << t if model_class?(t) && !seen.key?(t)
      end
    end
    # polymorphic use sites instantiate subclasses of reachable classes
    ObjectSpace.each_object(Class).select { |c| model_class?(c) && c.name }.each do |c|
      seen[c] = c.attributes if seen.key?(c.superclass) && !seen.key?(c)
    end
    seen
  end

  # --- read-site harvest ---------------------------------------------------

  # Tokens that count as a read: `.foo` method calls, `:foo` symbols,
  # words inside %i[...] / %w[...] (fed to public_send in this codebase),
  # and string literals in send/respond_to?/method_defined? calls.
  def harvested_tokens
    calls = Set.new
    syms  = Set.new
    TRANSFORMER_SOURCES.each do |path|
      File.foreach(path) do |line|
        code = line.lstrip.start_with?("#") ? "" : line.split("#", 1).first.to_s
        code.scan(/[\w)\]?!&]\s*(?:&\.|\.)\s*([a-z_][a-zA-Z0-9_]*[?!]?)/) { calls << $1 }
        code.scan(/:([a-z_][a-zA-Z0-9_]*[?!]?)/) { syms << $1 }
        code.scan(/%[iw]\[([^\]]*)\]/) do |(body)|
          body.split.each { |t| syms << t if t.match?(/\A[a-z_][a-zA-Z0-9_]*[?!]?\z/) }
        end
        code.scan(/(?:send|public_send|respond_to\?|method_defined\?)\s*\(?\s*["']([a-z_][a-zA-Z0-9_]*)["']/) { syms << $1 }
      end
    end
    calls + syms
  end

  # --- the ignore list -----------------------------------------------------
  # Key "*" applies to every class. Class keys are full names. Every entry
  # carries the reason it is legitimate to drop — keep the reasons honest;
  # they are the audit trail.
  IGNORED_EVERYWHERE = {
    "contrib_metadata" => "authoring provenance; no RFC v3 home (parity with released leg)",
    "semx_id" => "presentation carrier; consumed via the id/semx_id anchor fallback only where mapped",
    "original_id" => "presentation duplicate of id",
    "displayorder" => "presentation ordering hint; transformer emits source order",
    "schema_version" => "serialisation metadata",
    "json_type" => "JSON serialisation discriminator",
    "json_content" => "JSON serialisation carrier",
    "json_text" => "JSON serialisation carrier",
    "multilingual_rendering" => "rendering directive; no RFC v3 home",
    "keep_lines_together" => "layout hint; no RFC v3 home",
    "columns" => "layout hint; no RFC v3 home",
  }.freeze

  IGNORED_PREFIXES = {
    "fmt_" => "presentation-layer rendered duplicate; transformer reads semantic side " \
              "(EXCEPTIONS must be hand-listed as reads where fmt_* is the only carrier, " \
              "e.g. footnote/cref pipelines — see #291/#293)",
  }.freeze

  IGNORED_CLASS_FAMILIES = {
    /\AMml::/ => "MathML subtree is delegated wholesale to plurimath re-serialisation " \
                 "(build_stem_text); attributes are not hand-walked",
  }.freeze

  IGNORED_PER_CLASS = {
    "Metanorma::IetfDocument::Root" => {
      "flavor" => "register dispatch, not content",
      "boilerplate" => "xml2rfc generates RFC boilerplate from ipr= (released leg: empty #boilerplate)",
      "localized_strings" => "i18n scaffolding, render-time only",
      "colophon" => "no RFC v3 home; released leg did not render (parity)",
      "indexsect" => "xml2rfc generates the index from iref (parity)",
      "term_sources" => "root-level termdocsource provenance; not rendered on either leg",
      "metanorma_extension" => "presentation-metadata channel; cref render gate reads bibdata ext instead (see #291 cref deferral)",
    },
    # … extend per class as attributes are adjudicated. Every WS5b theme fix
    # that starts reading an attribute REMOVES its entry from this list.
  }.freeze

  def ignored?(klass, attr_name)
    name = attr_name.to_s
    return true if IGNORED_EVERYWHERE.key?(name)
    return true if IGNORED_PREFIXES.keys.any? { |p| name.start_with?(p) }
    return true if IGNORED_CLASS_FAMILIES.keys.any? { |re| klass.name&.match?(re) }

    IGNORED_PER_CLASS.fetch(klass.name, {}).key?(name)
  end

  it "reads or explicitly ignores every model attribute reachable from Root" do
    tokens = harvested_tokens
    offenders = []
    reachable_classes(Metanorma::IetfDocument::Root).each do |klass, attrs|
      attrs.each_key do |name|
        next if tokens.include?(name.to_s)
        next if ignored?(klass, name)

        offenders << "#{klass.name}##{name}"
      end
    end
    expect(offenders).to be_empty, lambda {
      "Model attributes neither read by the transformer nor on the IGNORED " \
      "list (silent-drop candidates — read them or adjudicate them):\n  " +
        offenders.sort.join("\n  ")
    }
  end

  it "probes only accessor names that exist on some reachable model class" do
    # dead-guard detector: respond_to?/method_defined? against a name no
    # reachable class defines means a dispatch branch can never fire
    # (WS5b :definition_lists; WS5c :class_attr pseudocode guard).
    probed = Set.new
    TRANSFORMER_SOURCES.each do |path|
      File.foreach(path) do |line|
        code = line.lstrip.start_with?("#") ? "" : line.split("#", 1).first.to_s
        code.scan(/(?:respond_to\?|method_defined\?)\s*\(?\s*:([a-z_][a-zA-Z0-9_]*[?!]?)/) { probed << $1 }
        code.scan(/(?:respond_to\?|method_defined\?)\s*\(?\s*["']([a-z_][a-zA-Z0-9_]*[?!]?)["']/) { probed << $1 }
      end
    end
    known = Set.new
    reachable_classes(Metanorma::IetfDocument::Root).each do |klass, attrs|
      attrs.each_key { |n| known << n.to_s }
      klass.instance_methods(false).each { |m| known << m.to_s }
    end
    dead = probed.reject { |name| known.include?(name) }
    expect(dead).to be_empty, lambda {
      "respond_to?/method_defined? guards probing names no reachable model " \
      "class defines (dead dispatch branches):\n  " + dead.sort.join("\n  ")
    }
  end
end
