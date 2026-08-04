#!/usr/bin/env ruby
# frozen_string_literal: true

# WS5 heritage-corpus sweep driver (issue #233 QA, PR #257).
#
# Walks a directory of released-stack compile outputs: for every
# BASE.adoc with a semantic BASE.xml, pairs it with the old-leg RFC
# XML — BASE.rfc.xml, or BASE.rfc.xml.err when the released path's
# own content validator aborted the document (the output is still
# the released path's RFC XML; the abort itself is corpus data) —
# and runs the WS2 three-surface comparison (tools/compare_old_new)
# into OUTROOT/<base>. Documents with no semantic XML (released
# compile failed outright) are reported as OLD-COMPILE-FAIL rows.
#
# Usage:
#   bundle exec ruby tools/ws5_sweep.rb WORKDIR OUTROOT
#
# Emits a TSV summary (OUTROOT/summary.tsv) with one row per
# document: base, old_leg (ok/err/none), renders old/new, xml/txt
# delta line counts, nits added/removed. Per the WS5 no-autopilot
# rule, this script only MEASURES; findings are classified and
# adjudicated by hand from the per-document artefacts.

require "fileutils"
require_relative "compare_old_new"

workdir, outroot = ARGV
abort "usage: ws5_sweep.rb WORKDIR OUTROOT" unless outroot
FileUtils.mkdir_p(outroot)

rows = []
Dir[File.join(workdir, "*.adoc")].sort.each do |adoc|
  base = File.basename(adoc, ".adoc")
  next if base =~ /README/i

  semantic = File.join(workdir, "#{base}.xml")
  old_ok  = File.join(workdir, "#{base}.rfc.xml")
  old_err = File.join(workdir, "#{base}.rfc.xml.err")
  old_leg, old_kind =
    if File.exist?(old_ok) then [old_ok, "ok"]
    elsif File.exist?(old_err) then [old_err, "err"]
    end

  unless File.exist?(semantic)
    warn "== #{base}: OLD-COMPILE-FAIL (no semantic XML)"
    rows << [base, "none", "-", "-", "-", "-", "-", "-"]
    next
  end

  outdir = File.join(outroot, base)

  if old_leg.nil?
    # semantic exists but the released path never emitted RFC XML
    # (not even an .err): render the new leg alone so the document
    # still contributes a renders-and-nits row
    begin
      FileUtils.mkdir_p(outdir)
      new_rfc = Metanorma::Ietf::Transformer.convert(File.read(semantic))
      File.write(File.join(outdir, "new.rfc.xml"), new_rfc)
      ok, nits = CompareOldNew.xml2rfc(File.join(outdir, "new.rfc.xml"),
                                       File.join(outdir, "new.txt"))
      warn "== #{base}: old leg ABSENT; new renders=#{ok} nits=#{nits.size}"
      rows << [base, "none", "-", ok, "-", "-", nits.size, "-"]
    rescue StandardError => e
      warn "== #{base}: NEW-LEG CRASH #{e.class}: #{e.message[0, 120]}"
      rows << [base, "none", "-", "CRASH:#{e.class}", "-", "-", "-", "-"]
    end
    next
  end
  begin
    res = CompareOldNew.run(semantic, old_leg, outdir)
    CompareOldNew.report("#{base} (old=#{old_kind})", res)
    rows << [base, old_kind, res[:old_renders], res[:new_renders],
             res[:xml_delta], res[:txt_delta] || "-",
             res[:nits_added].size, res[:nits_removed].size]
  rescue StandardError => e
    warn "== #{base}: NEW-LEG CRASH #{e.class}: #{e.message[0, 120]}"
    rows << [base, old_kind, "-", "CRASH:#{e.class}", "-", "-", "-", "-"]
  end
end

File.open(File.join(outroot, "summary.tsv"), "w") do |f|
  f.puts %w[base old_leg old_renders new_renders xml_delta txt_delta
            nits_added nits_removed].join("\t")
  rows.each { |r| f.puts r.join("\t") }
end
puts "\nSummary: #{File.join(outroot, 'summary.tsv')} (#{rows.size} documents)"
