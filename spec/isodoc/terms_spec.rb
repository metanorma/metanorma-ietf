require "spec_helper"

RSpec.describe IsoDoc::Ietf::RfcConvert do
  it "processes IsoXML terms" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <sections>
    <terms id="_terms_and_definitions" obligation="normative"><title>Terms and Definitions</title>
    <p>For the purposes of this document, the following terms and definitions apply.</p>

<term id="paddy1"><preferred>paddy</preferred>
<domain>rice</domain>
<definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></definition>
<termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f892">
  <p id="_65c9a509-9a89-4b54-a890-274126aeb55c">Foreign seeds, husks, bran, sand, dust.</p>
  <ul>
  <li>A</li>
  </ul>
</termexample>
<termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f894">
  <ul>
  <li>A</li>
  </ul>
</termexample>

<termsource status="modified">
  <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
    <modification>
    <p id="_e73a417d-ad39-417d-a4c8-20e4e2529489">The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</p>
  </modification>
</termsource></term>

<term id="paddy"><preferred>paddy</preferred><admitted>paddy rice</admitted>
<admitted>rough rice</admitted>
<deprecates>cargo rice</deprecates>
<definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></definition>
<termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f893">
  <ul>
  <li>A</li>
  </ul>
</termexample>
<termnote id="_671a1994-4783-40d0-bc81-987d06ffb74e">
  <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
</termnote>
<termnote id="_671a1994-4783-40d0-bc81-987d06ffb74f">
<ul><li>A</li></ul>
  <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
</termnote>
<termsource status="identical">
  <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
</termsource></term>
</terms>
</sections>
</iso-standard>
    INPUT
    #{RFC_HDR}
  <middle>
           <section anchor='_terms_and_definitions'>
             <name>Terms and Definitions</name>
             <t>For the purposes of this document, the following terms and definitions apply.</t>
             <section anchor='paddy1'>
               <name>paddy</name>
               <t anchor='_eb29b35e-123e-4d1c-b50b-2714d41e747f'>&lt;rice&gt; rice retaining its husk after threshing</t>
               <t anchor='_bd57bbf1-f948-4bae-b0ce-73c00431f892' keepWithNext='true'>EXAMPLE 1</t>
               <t anchor='_65c9a509-9a89-4b54-a890-274126aeb55c'>Foreign seeds, husks, bran, sand, dust.</t>
               <ul>
                 <li>A</li>
               </ul>
               <t anchor='_bd57bbf1-f948-4bae-b0ce-73c00431f894' keepWithNext='true'>EXAMPLE 2</t>
               <ul>
                 <li>A</li>
               </ul>
               <t>
                 SOURCE: <relref target='ISO7301'  section='3.1' relative=''/> --
                  The term "cargo rice" is shown as deprecated, and Note 1 to entry is
                 not included here 
               </t>
             </section>
             <section anchor='paddy'>
               <name>paddy</name>
               <t>paddy rice</t>
               <t>rough rice</t>
               <t>DEPRECATED: cargo rice</t>
               <t anchor='_eb29b35e-123e-4d1c-b50b-2714d41e747f'>rice retaining its husk after threshing</t>
               <t anchor='_bd57bbf1-f948-4bae-b0ce-73c00431f893' keepWithNext='true'>EXAMPLE</t>
               <ul>
                 <li>A</li>
               </ul>
               <aside anchor='_671a1994-4783-40d0-bc81-987d06ffb74e'>
                 <t>
                   NOTE 1: The starch of waxy rice consists almost
                   entirely of amylopectin. The kernels have a tendency to stick
                   together after cooking.
                 </t>
               </aside>
               <aside anchor='_671a1994-4783-40d0-bc81-987d06ffb74f'>
                 <t>NOTE 2: </t>
                 <ul>
                   <li>A</li>
                 </ul>
                 <t anchor='_19830f33-e46c-42cc-94ca-a5ef101132d5'>
                   The starch of waxy rice consists almost entirely of amylopectin. The
                   kernels have a tendency to stick together after cooking.
                 </t>
               </aside>
               <t>
                 SOURCE: <relref target='ISO7301'  section='3.1' relative=''/>
               </t>
             </section>
           </section>
         </middle>
  <back/>
</rfc>

OUTPUT
  end
end
