require "open-uri"

module Asciidoctor
  module Ietf
    class Converter < ::Asciidoctor::Standoc::Converter
      def content_validate(doc)
        super
        image_validate(doc)
        workgroup_validate(doc)
      end

      def image_validate(doc)
        doc.xpath("//image").each do |i|
          next if i["mimetype"] == "image/svg+xml"

          @log.add("MIME", i, "image #{i['src'][0, 40]} is not SVG!")
        end
      end

      def workgroup_validate(doc)
        return if @workgroups.empty?

        doc.xpath("//bibdata/ext/editorialgroup/workgroup").each do |wg|
          wg_norm = wg.text.sub(/ (Working|Research) Group$/, "")
          next if @workgroups.include?(wg_norm)

          @log.add("Document Attributes", nil, "IETF: unrecognised working group #{wg.text}")
        end
      end

      def validate(doc)
        content_validate(doc)
        schema_validate(formattedstr_strip(doc.dup),
                        File.join(File.dirname(__FILE__), "ietf.rng"))
      end

      def wgcache_name
        "#{Dir.home}/.metanorma-ietf-workgroup-cache.json"
      end

      def open_wg_cache(node)
        node.attr("flush-caches") == "true" and
          FileUtils.rm wgcache_name, force: true
        wg = []
        if Pathname.new(wgcache_name).file?
          begin
            File.open(wgcache_name, "r") { |f| wg = JSON.parse(f.read) }
          rescue Exception => e
            warn "Cache #{wgcache_name} is invalid, drop it"
          end
        end
        [wg, wgcache_name]
      end

      def cache_workgroup_ietf(wg, _b)
        warn "Reading workgroups from https://tools.ietf.org/wg/..."
        URI.open("https://tools.ietf.org/wg/") do |f|
          f.each_line do |l|
            l.scan(%r{<td width="50%" style='padding: 0 1ex'>([^<]+)</td>}) do |w|
              wg << w[0].gsub(/\s+$/, "").gsub(/ Working Group$/, "")
            end
          end
        end
        wg
      end

      def cache_workgroup_irtf(wg, _b)
        warn "Reading workgroups from https://irtf.org/groups..."
        URI.open("https://irtf.org/groups", ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE) do |f|
          f.each_line do |l|
            l.scan(%r{<a title="([^"]+) Research Group"[^>]+>([^<]+)<}) do |w|
              wg << w[0].gsub(/\s+$/, "")
              wg << w[1].gsub(/\s+$/, "") # abbrev
            end
          end
        end
        wg
      end

      def cache_workgroup(node)
        wg, wgcache_name = open_wg_cache(node)
        if wg.empty?
          File.open(wgcache_name, "w") do |b|
            wg = cache_workgroup_ietf(wg, b)
            wg = cache_workgroup_irtf(wg, b)
            b << wg.to_json
          end
        end
        wg
      end
    end
  end
end
