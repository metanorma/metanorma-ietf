require "spec_helper"

RSpec.describe Asciidoctor::Ietf do
  
    it "processes complex lists" do
    output = Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true)
      #{ASCIIDOC_BLANK_HDR}
      [[id]]
      [nobullet=true,spacing=compact]
      * First
      * Second
      +
      --
      entry1

      entry2
      --

      [[id1]]
      [loweralpha,group=6,spacing=normal,start=2]
      . First
      . Second
      [upperalpha,format=%d.]
      .. Third
      .. Fourth
      . Fifth
      . Sixth

      [newline=false,spacing=compact,indent=5]
      Notes1::
      Notes::  Note 1.
      +
      Note 2.
      +
      Note 3.

    INPUT
    expect(xmlpp(strip_guid(output))).to be_equivalent_to xmlpp(<<~"OUTPUT")
            #{BLANK_HDR}
            <sections>
           <ul id='id' nobullet='true' spacing='compact'>
             <li>
               <p id='_'>First</p>
             </li>
             <li>
               <p id='_'>Second</p>
               <p id='_'>entry1</p>
               <p id='_'>entry2</p>
             </li>
           </ul>
           <ol id='id1' type='alphabet' group='6' spacing='normal' start='2'>
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
             <dt>Notes1</dt>
             <dd/>
             <dt>Notes</dt>
             <dd>
               <p id='_'>Note 1.</p>
               <p id='_'>Note 2.</p>
               <p id='_'>Note 3.</p>
             </dd>
           </dl>
         </sections>
       </ietf-standard>
       OUTPUT
    end
end
