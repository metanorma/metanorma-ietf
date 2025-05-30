require "spec_helper"

RSpec.describe Metanorma::Ietf do
  it "processes complex lists" do
    output = Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{ASCIIDOC_BLANK_HDR}
      [[id]]
      [nobullet=true,spacing=compact,indent=5,bare=true]
      * First
      * Second
      +
      --
      entry1

      entry2
      --

      [[id1]]
      [loweralpha,group=6,spacing=normal,start=2,indent=5]
      . First
      . Second
      [upperalpha,format=%d.]
      .. Third
      .. Fourth
      . Fifth
      . Sixth

      [newline=false,spacing=compact,indent=5]
      Notes1**:**::
      Notes::  Note 1.
      +
      Note 2.
      +
      Note 3.

    INPUT
    xml = <<~OUTPUT
           #{BLANK_HDR}
           <sections>
          <ul id="_" anchor="id" nobullet='true' spacing='compact' indent='5' bare='true'>
            <li>
              <p id='_'>First</p>
            </li>
            <li>
              <p id='_'>Second</p>
              <p id='_'>entry1</p>
              <p id='_'>entry2</p>
            </li>
          </ul>
          <ol id="_" anchor="id1" type='alphabet' group='6' spacing='normal' start='2' indent='5'>
            <li>
              <p id='_'>First</p>
            </li>
            <li>
              <p id='_'>Second</p>
              <ol id='_' type='%d.'>
                <li>
                  <p id='_'>Third</p>
                </li>
                <li>
                  <p id='_'>Fourth</p>
                </li>
              </ol>
            </li>
            <li>
              <p id='_'>Fifth</p>
            </li>
            <li>
              <p id='_'>Sixth</p>
            </li>
          </ol>
          <dl id='_' newline='false' spacing='compact' indent='5'>
            <dt>Notes1<strong>:</strong></dt>
            <dd/>
            <dt>Notes:</dt>
            <dd id="_">
              <p id='_'>Note 1.</p>
              <p id='_'>Note 2.</p>
              <p id='_'>Note 3.</p>
            </dd>
          </dl>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(output)))
      .to be_equivalent_to Xml::C14n.format(xml)
  end
end
