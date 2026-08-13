#!/usr/bin/env ruby
# frozen_string_literal: true

# WS2 old-vs-new comparison harness (issue #233 QA, PR #257).
#
# Compares the released path's RFC XML ("old", a durable baseline
# artefact — see ws1b-postrelease-baselines/) with the transformer
# pipeline's live output ("new": presentation stage -> model ->
# transformer, the default path) for ONE semantic document, on three
# surfaces:
#
#   (a) normalised RFC XML   -> OUTDIR/xml.diff
#   (b) xml2rfc --text       -> OUTDIR/txt.diff
#   (c) nit sets             -> OUTDIR/nits.diff
#       (xml2rfc stderr, plus idnits when installed)
#
# Corpus-agnostic by design so the WS5 mn-samples sweep reuses it.
# Every surviving delta belongs in docs/discrepancy-log.adoc with a
# classification (A new-transformer bug / B legitimate improvement /
# C old-path bug fixed / D cosmetic) and a nit-derived severity.
#
# Usage:
#   bundle exec ruby tools/compare_old_new.rb SEMANTIC.xml OLD.rfc.xml OUTDIR
#
# xml2rfc must be on PATH (the campaign installs it at ~/.local/bin).

require "nokogiri"
require "fileutils"
require "open3"

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "metanorma/ietf/transformer"

module CompareOldNew
  module_function

  # The spec suite's strip_guid convention, applied to both legs so
  # GUID churn never reads as a delta
  def normalize(xml)
    xml = xml.gsub(%r{ id="_[^"]+"}, ' id="_"')
      .gsub(%r{ from="_[^"]+"}, ' from="_"')
      .gsub(%r{ to="_[^"]+"}, ' to="_"')
      .gsub(%r{ target="_[^"]+"}, ' target="_"')
      .gsub(%r( anchor="_[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"), ' anchor="_"')
      .gsub(%r{<fetched>[^<]+</fetched>}, "<fetched/>")
      .gsub(%r{ schema-version="[^"]+"}, "")
    doc = Nokogiri::XML(xml, &:noblanks)
    # dates diverge run-to-run by construction; not a comparison surface
    doc.xpath("//date[@year]").each { |d| %w[day month year].each { |a| d[a] = "_" } }
    doc.to_xml(indent: 2)
  end

  def xml2rfc(rfc_xml_path, txt_path)
    out, err, status = Open3.capture3(
      "xml2rfc", "--text", "-o", txt_path, rfc_xml_path
    )
    nits = (out + err).lines.grep(/Warning|Error/)
      .map { |l| l.sub(/^[^:]*\(\d+\): /, "").strip }
      # line references shift with any content change; compare classes
      .map { |l| l.gsub(/\(L\d+\)/, "(L_)") }
      # document dates differ by construction between the legs
      .reject { |l| l.include?("away from today's date") }
      .sort.uniq
    [status.success?, nits]
  end

  def idnits(txt_path)
    return [] unless system("which idnits > /dev/null 2>&1")

    out, _err, = Open3.capture3("idnits", txt_path)
    out.lines.grep(/^  [*!o] /).map(&:strip).sort.uniq
  end

  def diff(a_path, b_path, out_path)
    out, = Open3.capture3("diff", "-u", a_path, b_path)
    File.write(out_path, out)
    out.lines.count { |l| l.start_with?("+", "-") } - 2
  end

  # new_patch: optional callable applied to the new leg's RFC XML
  # before rendering — for corpus entries whose old-leg baseline is
  # itself patched (e.g. antioch's non-RFC-7996 remote-SVG elision,
  # old.patched.rfc.xml), so both legs receive identical treatment
  def run(semantic_path, old_rfc_path, outdir, new_patch: nil)
    FileUtils.mkdir_p(outdir)

    new_rfc = Metanorma::Ietf::Transformer.convert(File.read(semantic_path))
    new_rfc = new_patch.call(new_rfc) if new_patch
    File.write(File.join(outdir, "new.rfc.xml"), new_rfc)

    # (a) normalised XML
    File.write(File.join(outdir, "old.norm.xml"),
               normalize(File.read(old_rfc_path)))
    File.write(File.join(outdir, "new.norm.xml"), normalize(new_rfc))
    xml_delta = diff(File.join(outdir, "old.norm.xml"),
                     File.join(outdir, "new.norm.xml"),
                     File.join(outdir, "xml.diff"))

    # (b) rendered text (both re-rendered locally: same xml2rfc version)
    old_ok, old_nits = xml2rfc(old_rfc_path, File.join(outdir, "old.txt"))
    new_ok, new_nits = xml2rfc(File.join(outdir, "new.rfc.xml"),
                               File.join(outdir, "new.txt"))
    txt_delta =
      if old_ok && new_ok
        diff(File.join(outdir, "old.txt"), File.join(outdir, "new.txt"),
             File.join(outdir, "txt.diff"))
      end

    # (c) nit sets: xml2rfc + idnits, diffed as sets
    old_nits += idnits(File.join(outdir, "old.txt")) if old_ok
    new_nits += idnits(File.join(outdir, "new.txt")) if new_ok
    File.write(File.join(outdir, "old.nits.txt"), old_nits.join("\n"))
    File.write(File.join(outdir, "new.nits.txt"), new_nits.join("\n"))
    nits_delta = diff(File.join(outdir, "old.nits.txt"),
                      File.join(outdir, "new.nits.txt"),
                      File.join(outdir, "nits.diff"))

    { xml_delta: xml_delta,
      old_renders: old_ok, new_renders: new_ok,
      txt_delta: txt_delta, nits_delta: nits_delta,
      nits_added: new_nits - old_nits, nits_removed: old_nits - new_nits }
  end

  def report(name, res)
    puts "== #{name}"
    puts "   xml.diff:  #{res[:xml_delta]} changed lines (normalised)"
    puts "   renders:   old=#{res[:old_renders]} new=#{res[:new_renders]}"
    puts "   txt.diff:  #{res[:txt_delta] || 'n/a'} changed lines"
    puts "   nits:      +#{res[:nits_added].size} -#{res[:nits_removed].size}"
    res[:nits_added].each { |n| puts "     + #{n}" }
    res[:nits_removed].each { |n| puts "     - #{n}" }
  end
end

if $PROGRAM_NAME == __FILE__
  semantic, old_rfc, outdir = ARGV
  abort "usage: compare_old_new.rb SEMANTIC.xml OLD.rfc.xml OUTDIR" unless outdir

  res = CompareOldNew.run(semantic, old_rfc, outdir)
  CompareOldNew.report(File.basename(semantic, ".xml"), res)
end
