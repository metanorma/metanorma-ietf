require "spec_helper"

def remove_preptime(xml)
  xml.gsub(/ prepTime="[^"]+"/, "").gsub(/ prepTime='[^']+'/, "")
end

RSpec.describe Asciidoctor::Rfc::V3::Converter do
  # it "processes v3 sample biblio file" do
  #  system("rm -f spec/examples/refs-v3.new.xml")
  #  system("bin/asciidoctor-rfc3 -r asciidoctor-bibliography spec/examples/refs-v3.adoc -o spec/examples/refs-v3.new.xml")
  #  expect(remove_preptime(File.read("spec/examples/refs-v3.new.xml"))).to be_equivalent_to remove_prepTime(File.read("spec/examples/refs-v3.xml"))
  # end
end
