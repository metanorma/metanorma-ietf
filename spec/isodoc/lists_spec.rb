require "spec_helper"

RSpec.describe IsoDoc do
  it "processes unordered lists" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <ul id="_61961034-0fb1-436b-b281-828857a59ddb" nobullet="true" spacing="compact" indent="5" bare="true">
        <li>
          <p id="_cb370dd3-8463-4ec7-aa1a-96f644e2e9a2">updated normative references;</p>
        </li>
        <li>
          <p id="_60eb765c-1f6c-418a-8016-29efa06bf4f9">deletion of 4.3.</p>
        </li>
      </ul>
      </foreword></preface>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
          #{XML_HDR}
          <ul anchor='_61961034-0fb1-436b-b281-828857a59ddb' empty='true' spacing='compact' indent="5" bare="true">
        <li>
          <t anchor='_cb370dd3-8463-4ec7-aa1a-96f644e2e9a2'>updated normative references;</t>
        </li>
        <li>
          <t anchor='_60eb765c-1f6c-418a-8016-29efa06bf4f9'>deletion of 4.3.</t>
        </li>
      </ul>
      </abstract></front><middle/><back/></rfc>
    OUTPUT
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(output)
  end

  it "processes ordered lists" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <ol id="_ae34a226-aab4-496d-987b-1aa7b6314026" type="alphabet" start="7" spacing="compact" group="X" indent="5">
        <li>
          <p id="_0091a277-fb0e-424a-aea8-f0001303fe78">all information necessary for the complete identification of the sample;</p>
        </li>
        <ol>
        <li>
          <p id="_8a7b6299-db05-4ff8-9de7-ff019b9017b2">a reference to this document (i.e. ISO 17301-1);</p>
        </li>
        <ol>
        <li>
          <p id="_ea248b7f-839f-460f-a173-a58a830b2abe">the sampling method used;</p>
        </li>
        </ol>
        </ol>
      </ol>
      </foreword></preface>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      #{XML_HDR}
         <ol anchor='_ae34a226-aab4-496d-987b-1aa7b6314026' spacing='compact' type='a' group='X' start='7' indent="5">
             <li>
               <t anchor='_0091a277-fb0e-424a-aea8-f0001303fe78'>all information necessary for the complete identification of the sample;</t>
             </li>
             <ol>
               <li>
                 <t anchor='_8a7b6299-db05-4ff8-9de7-ff019b9017b2'>a reference to this document (i.e. ISO 17301-1);</t>
               </li>
               <ol>
                 <li>
                   <t anchor='_ea248b7f-839f-460f-a173-a58a830b2abe'>the sampling method used;</t>
                 </li>
               </ol>
             </ol>
           </ol>
        </abstract></front><middle/><back/></rfc>
    OUTPUT
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(output)
  end

  it "processes Roman Upper ordered lists" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <ol id="_ae34a226-aab4-496d-987b-1aa7b6314026" type="roman_upper">
        <li id="_ae34a226-aab4-496d-987b-1aa7b6314027">
          <p id="_0091a277-fb0e-424a-aea8-f0001303fe78">all information necessary for the complete identification of the sample;</p>
        </li>
        <li>
          <p id="_8a7b6299-db05-4ff8-9de7-ff019b9017b2">a reference to this document (i.e. ISO 17301-1);</p>
        </li>
        <li>
          <p id="_ea248b7f-839f-460f-a173-a58a830b2abe">the sampling method used;</p>
        </li>
      </ol>
      </foreword></preface>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      #{XML_HDR}
                              <ol anchor='_ae34a226-aab4-496d-987b-1aa7b6314026' type='I'>
                 <li id='_ae34a226-aab4-496d-987b-1aa7b6314027'>
                   <t anchor='_0091a277-fb0e-424a-aea8-f0001303fe78'>all information necessary for the complete identification of the sample;</t>
                 </li>
                 <li>
                   <t anchor='_8a7b6299-db05-4ff8-9de7-ff019b9017b2'>a reference to this document (i.e. ISO 17301-1);</t>
                 </li>
                 <li>
                   <t anchor='_ea248b7f-839f-460f-a173-a58a830b2abe'>the sampling method used;</t>
                 </li>
               </ol>
            </abstract></front><middle/><back/></rfc>
    OUTPUT
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(output)
  end

  it "processes definition lists" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <dl id="_732d3f57-4f88-40bf-9ae9-633891edc395" newline="true" spacing="compact" indent="5">
        <dt>
          W
        </dt>
        <dd>
          <p id="_05d81174-3a41-44af-94d8-c78b8d2e175d">mass fraction of gelatinized kernels, expressed in per cent</p>
        </dd>
        <dt><stem type="AsciiMath">w</stem></dt>
        <dd><p>??</p></dd>
        <note><p>This is a note</p></note>
        </dl>
      </foreword></preface>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      #{XML_HDR}
                 <dl anchor='_732d3f57-4f88-40bf-9ae9-633891edc395' newline='true' spacing='compact' indent='5'>
                 <dt>
                   W
                 </dt>
                 <dd>
                   <t anchor='_05d81174-3a41-44af-94d8-c78b8d2e175d'>mass fraction of gelatinized kernels, expressed in per cent</t>
                 </dd>
                 <dt>$$ w $$</dt>
                 <dd>
                   <t>??</t>
                 </dd>
               </dl>
               <aside>
               <t>NOTE: This is a note</t>
               </aside>
        </abstract></front><middle/><back/></rfc>
    OUTPUT
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(output)
  end
end
