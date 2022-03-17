require "isodoc"

module IsoDoc
  module Ietf
    class Xref < IsoDoc::Xref
      def termnote_anchor_names(docxml)
        docxml.xpath(ns("//term[descendant::termnote]")).each do |t|
          c = IsoDoc::XrefGen::Counter.new
          notes = t.xpath(ns("./termnote"))
          notes.each do |n|
            next if n["id"].nil? || n["id"].empty?

            idx = notes.size == 1 ? "" : " #{c.increment(n).print}"
            @anchors[n["id"]] =
              anchor_struct(idx, n, @labels["note_xref"], "note", false)
          end
        end
      end
    end
  end
end
