require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

namespace :compare do
  desc "WS2: old-vs-new comparison over the baseline corpus " \
       "(ws1b-postrelease-baselines/); see tools/compare_old_new.rb"
  task :rfc do
    require_relative "tools/compare_old_new"
    base = "ws1b-postrelease-baselines"
    # antioch: the old leg is the patched baseline (non-RFC-7996
    # remote-SVG elided); the new leg gets the identical elision
    svg_elide = lambda do |xml|
      xml.gsub(
        %r{<artwork[^>]*upload\.wikimedia[^>]*/>|<artwork[^>]*upload\.wikimedia[^>]*></artwork>},
        "<artwork type=\"ascii-art\"><![CDATA[[artwork elided: " \
        "non-RFC-7996-profile SVG passthrough]]]></artwork>",
      )
    end
    corpus = {
      "rfc-3339" => { stem: "document", old: "old.rfc.xml" },
      "example" => { stem: "example", old: "old.rfc.xml" },
      "antioch" => { stem: "antioch", old: "old.patched.rfc.xml",
                     new_patch: svg_elide },
    }
    corpus.each do |dir, spec|
      semantic = File.join(base, dir, "#{spec[:stem]}.xml")
      old_rfc = File.join(base, dir, spec[:old])
      unless File.exist?(semantic) && File.exist?(old_rfc)
        puts "== #{dir}: SKIPPED (baselines not present)"
        next
      end
      res = CompareOldNew.run(semantic, old_rfc, "tmp/compare/#{dir}",
                              new_patch: spec[:new_patch])
      CompareOldNew.report(dir, res)
    end
  end
end
