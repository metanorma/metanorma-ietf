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

namespace :guards do
  desc "Diff the bundled v3.rng against xml2rfc's current grammar " \
       "(metanorma-ietf#359; the grammar mirrors the reference toolchain)"
  task :schema_sync do
    require "open3"
    require "tmpdir"
    Dir.mktmpdir("xml2rfc-sync") do |dir|
      _, status = Open3.capture2e(
        "git", "clone", "--depth", "1",
        "https://github.com/ietf-tools/xml2rfc", dir,
      )
      status.success? or abort "xml2rfc clone failed"
      normalise = lambda do |path|
        File.read(path).gsub(/^[ \t]+/, "").gsub(/\n+\z/, "\n")
      end
      ours = normalise.call("lib/metanorma/ietf/schema/v3.rng")
      theirs = normalise.call(File.join(dir, "xml2rfc", "data", "v3.rng"))
      if ours == theirs
        puts "v3.rng in sync with xml2rfc's grammar"
      else
        diff = (ours.lines - theirs.lines).first(10).join
        abort "v3.rng has drifted from xml2rfc's grammar; sync it " \
              "(#359). First differing lines:\n#{diff}"
      end
    end
  end

  desc "Render the idnits3 corpus into submission filenames (#358)"
  task :"idnits3_render" do
    require_relative "lib/metanorma/ietf"
    require "nokogiri"
    out = ENV["IDNITS3_CORPUS"] || File.join(Dir.pwd, "tmp", "idnits-corpus")
    FileUtils.rm_rf(out)
    FileUtils.mkdir_p(out)
    %w[antioch example rfc3339-current].each do |name|
      input = File.read("spec/fixtures/transformer/input/#{name}.xml")
      rfc = Metanorma::Ietf::Transformer.convert(input, direction: :forward)
      doc = Nokogiri::XML(rfc).root
      number = doc["number"]
      filename = doc["docName"] ||
                 (number && "rfc#{number}") || name
      File.write(File.join(out, "#{filename}.xml"), rfc)
      puts "  #{name} -> #{filename}.xml"
    end
    ENV["IDNITS3_CORPUS"] = out
  end

  desc "Run idnits3 in submission mode over the corpus; fails on any " \
       "error-severity finding (#358). Set IDNITS3_DIR to a checkout of " \
       "https://github.com/ietf-tools/idnits (built with npm ci), or let " \
       "the task clone it."
  task idnits3: [:"idnits3_render"] do
    dir = ENV["IDNITS3_DIR"]
    unless dir && File.exist?(File.join(dir, "cli.js"))
      dir = File.expand_path("tmp/idnits", Dir.pwd)
      sh "git clone --depth 1 https://github.com/ietf-tools/idnits #{dir}" unless File.exist?(File.join(dir, ".git"))
      sh "npm ci --prefix #{dir}"
    end
    cli = File.join(dir, "cli.js")
    corpus = ENV["IDNITS3_CORPUS"]
    failures = []
    Dir.glob(File.join(corpus, "*.xml")).sort.each do |file|
      ok = system("node", cli, "--offline", "--mode", "submission",
                  "--no-progress", "--fail-on", "errors", "-o", "count",
                  file)
      failures << file unless ok
    end
    if failures.empty?
      puts "idnits3: corpus clean (no error-severity findings)"
    else
      failures.each do |file|
        system("node", cli, "--offline", "--mode", "submission",
               "--no-progress", file) || true
      end
      abort "idnits3 found error-severity findings in: " \
            "#{failures.join(', ')}"
    end
  end
end
