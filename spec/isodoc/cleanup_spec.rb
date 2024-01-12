require "spec_helper"
require "nokogiri"
RSpec.describe IsoDoc::Ietf::RfcConvert do
  it "cleans up footnotes" do
    input = <<~INPUT
      <rfc xmlns:xi='http://www.w3.org/2001/XInclude' version='3'>
               <front>
                 <abstract>
                   <t>
                     A.
                     <fnref>2</fnref>
                     <fn>
                       <t anchor='_1e228e29-baef-4f38-b048-b05a051747e4'><ref>2</ref>
                         Formerly denoted as 15 % (m/m).
                       </t>
                     </fn>
                   </t>
                   <t>
                     B.
                     <fnref>2</fnref>
                   </t>
                   <t>
                     C.
                     <fnref>1</fnref>
                     <fn>
                       <t anchor='_1e228e29-baef-4f38-b048-b05a051747e4'><ref>1</ref>
                         Hello! denoted as 15 % (m/m).
                       </t>
                     </fn>
                   </t>
                 </abstract>
               </front>
               <middle/>
               <back/>
             </rfc>
    INPUT
    output = <<~OUTPUT
      <rfc xmlns:xi='http://www.w3.org/2001/XInclude' version='3'>
               <front>
                 <abstract>
                   <t> A. [1] </t>
                   <t> B. [1] </t>
                   <t> C. [2] </t>
                 </abstract>
               </front>
               <middle/>
               <back>
                 <section>
                   <name>Endnotes</name>
                   <t anchor='_1e228e29-baef-4f38-b048-b05a051747e4'>[1] Formerly denoted as 15 % (m/m). </t>
                   <t anchor='_1e228e29-baef-4f38-b048-b05a051747e4'>[2] Hello! denoted as 15 % (m/m). </t>
                 </section>
               </back>
             </rfc>
    OUTPUT
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({})
      .cleanup(Nokogiri::XML(input)).to_s)).to be_equivalent_to xmlpp(output)
  end

  it "cleans up footnotes in a section" do
    input = <<~INPUT
      <rfc xmlns:xi='http://www.w3.org/2001/XInclude' version='3'>
               <front/>
               <middle>
                 <section>
                   <t>
                     A.
                     <fnref>2</fnref>
                     <fn>
                       <t anchor='_1e228e29-baef-4f38-b048-b05a051747e4'><ref>2</ref>
                         Formerly denoted as 15 % (m/m).
                       </t>
                     </fn>
                   </t>
                   <section>
                   <t>
                     B.
                     <fnref>2</fnref>
                   </t>
                   </section>
                   </section>
               </middle>
               <back>
               <section>
                   <t>
                     C.
                     <fnref>1</fnref>
                     <fn>
                       <t anchor='_1e228e29-baef-4f38-b048-b05a051747e4'><ref>1</ref>
                         Hello! denoted as 15 % (m/m).
                       </t>
                     </fn>
                   </t>
                 </section>
               </back>
             </rfc>
    INPUT
    output = <<~OUTPUT
      <rfc xmlns:xi='http://www.w3.org/2001/XInclude' version='3'>
               <front/>
               <middle>
                 <section>
                   <t> A. [1] </t>
                   <section>
                     <t> B. [1] </t>
                   </section>
                 </section>
               </middle>
               <back>
                 <section>
                   <t> C. [2] </t>
                 </section>
                 <section>
                   <name>Endnotes</name>
                   <t anchor='_1e228e29-baef-4f38-b048-b05a051747e4'>[1] Formerly denoted as 15 % (m/m). </t>
                   <t anchor='_1e228e29-baef-4f38-b048-b05a051747e4'>[2] Hello! denoted as 15 % (m/m). </t>
                 </section>
               </back>
             </rfc>
    OUTPUT
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({})
      .cleanup(Nokogiri::XML(input)).to_s)).to be_equivalent_to xmlpp(output)
  end

  it "cleans up table footnotes" do
    input = <<~INPUT
          #{XML_HDR}
                 </abstract>
               </front>
               <middle>
              <section>
                   <table anchor='tableD-1'>
                     <name>
                       Repeatability and reproducibility of
                       <em>husked</em>
                        rice yield
                     </name>
                     <thead>
                       <tr>
                         <td rowspan='2' align='left'>Description</td>
                         <td colspan='4' align='center'>Rice sample</td>
                       </tr>
                       <tr>
                         <td align='left'>Arborio</td>
                         <td align='center'>
        Drago [a]
        <fn>
          <t anchor='_0fe65e9a-5531-408e-8295-eeff35f41a55'>[a] Parboiled rice.</t>
        </fn>
      </td>
      <td align='center'>Balilla [a]</td>
                         <td align='center'>Thaibonnet</td>
                       </tr>
                     </thead>
                     <tbody>
                       <tr>
                         <th align='left'>Number of laboratories retained after eliminating outliers</th>
                         <td align='center'>13</td>
                         <td align='center'>11</td>
                         <td align='center'>13</td>
                         <td align='center'>13</td>
                       </tr>
                       <tr>
                         <td align='left'>Mean value, g/100 g</td>
                         <td align='center'>81,2</td>
                         <td align='center'>82,0</td>
                         <td align='center'>81,8</td>
                         <td align='center'>77,7</td>
                       </tr>
                     </tbody>
                     <tfoot>
                       <tr>
                       <td align='left'>Reproducibility limit, $$ R $$ (= 2,83 $$ s_R $$)</td>
                         <td align='center'>2,89</td>
                         <td align='center'>0,57</td>
                         <td align='center'>2,26</td>
                         <td align='center'>6,06</td>
                       </tr>
                     </tfoot>
                   </table>
                   <dl>
                     <dt>
                       <p>Drago</p>
                     </dt>
                     <dd>A type of rice</dd>
                   </dl>
                   <aside>
                   <t>NOTE: This is a table about rice</t>
                   </aside>
                   <table anchor='tableD-2'>
                     <tbody>
                       <tr>
                         <td>A</td>
                       </tr>
                     </tbody>
                   </table>
                 </section>
               </middle>
               <back/>
             </rfc>
    INPUT
    output = <<~OUTPUT
      #{XML_HDR}
      </abstract></front><middle><section>
               <table anchor='tableD-1'>
                 <name>
                    Repeatability and reproducibility of
                   <em>husked</em>
                    rice yield
                 </name>
                 <thead>
                   <tr>
                     <td rowspan='2' align='left'>Description</td>
                     <td colspan='4' align='center'>Rice sample</td>
                   </tr>
                   <tr>
                     <td align='left'>Arborio</td>
                     <td align='center'> Drago [a] </td>
                     <td align='center'>Balilla [a]</td>
                     <td align='center'>Thaibonnet</td>
                   </tr>
                 </thead>
                 <tbody>
                   <tr>
                     <th align='left'>Number of laboratories retained after eliminating outliers</th>
                     <td align='center'>13</td>
                     <td align='center'>11</td>
                     <td align='center'>13</td>
                     <td align='center'>13</td>
                   </tr>
                   <tr>
                     <td align='left'>Mean value, g/100 g</td>
                     <td align='center'>81,2</td>
                     <td align='center'>82,0</td>
                     <td align='center'>81,8</td>
                     <td align='center'>77,7</td>
                   </tr>
                 </tbody>
                 <tfoot>
                   <tr>
                     <td align='left'>Reproducibility limit, $$ R $$ (= 2,83 $$ s_R $$)</td>
                     <td align='center'>2,89</td>
                     <td align='center'>0,57</td>
                     <td align='center'>2,26</td>
                     <td align='center'>6,06</td>
                   </tr>
                 </tfoot>
               </table>
               <aside>
                 <t anchor='_0fe65e9a-5531-408e-8295-eeff35f41a55'>[a] Parboiled rice.</t>
               </aside>
               <dl>
                 <dt>
                   <p>Drago</p>
                 </dt>
                 <dd>A type of rice</dd>
               </dl>
               <aside>
                 <t>NOTE: This is a table about rice</t>
               </aside>
               <table anchor='tableD-2'>
                 <tbody>
                   <tr>
                     <td>A</td>
                   </tr>
                 </tbody>
               </table>
                 </section>
               </middle>
               <back/>
             </rfc>
    OUTPUT
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({})
      .cleanup(Nokogiri::XML(input)).to_s)).to be_equivalent_to xmlpp(output)
  end

  it "cleans up figures" do
    input = <<~INPUT
      <rfc xmlns:xi='http://www.w3.org/2001/XInclude' version='3'>
               <front>
                 <abstract>
           <figure anchor='figureA-0'>
           <name>Unnested figure</name>
           <figure anchor="figureA-00">
           </figure>
           </figure>
           <figure anchor="figureA-001">
           <aside><t>X</t></aside>
           </figure>
           <artwork src="spec/assets/Example.svg" align="right" anchor="_56cb3ff4-1775-40c6-b75d-d5c2283e8338" type="svg" alt="Orb"/>
           <sourcecode/>
           <figure anchor='figureA-1'>
                     <name>
                       Split-it-right
                       <em>sample</em>
                        divider
                     </name>
                     <t anchor='AAA'>Random text</t>
                     <artwork src='rice_images/rice_image1.png' title='titletxt' anchor='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' type='svg' alt='alttext'/>
                     <artwork src='rice_images/rice_image1.png' anchor='_8357ede4-6d44-4672-bac4-9a85e82ab7f1' type='svg'/>
                     <artwork src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0nMS4wJyBlbmNvZGluZz0ndXRmLTgnPz4KPHN2ZyB4bWxuczpzdmc9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiIHhtbG5zOmlua3NjYXBlPSJodHRwOi8vd3d3Lmlua3NjYXBlLm9yZy9uYW1lc3BhY2VzL2lua3NjYXBlIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOmNjPSJodHRwOi8vY3JlYXRpdmVjb21tb25zLm9yZy9ucyMiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiIHZlcnNpb249IjEuMSIgaWQ9InN2ZzIiIHg9IjBweCIgeT0iMHB4IiB3aWR0aD0iMTgycHgiIGhlaWdodD0iMjkxLjgzNHB4IiB2aWV3Qm94PSIwIDAgMTgyIDI5MS44MzQiIHhtbDpzcGFjZT0icHJlc2VydmUiIHByZXNlcnZlQXNwZWN0UmF0aW89InhNaWRZTWlkIG1lZXQiPgo8ZGVmcz4KCQoJPC9kZWZzPgo8ZyBpZD0iZzkwODYiIHRyYW5zZm9ybT0idHJhbnNsYXRlKC0xNzQ2Ljg4MDA4NjU0ODI2NiwtNTczLjAwODc4MjkwODgzNzkpIj4KPC9nPgo8ZyBpZD0iZzkwODgiIHRyYW5zZm9ybT0idHJhbnNsYXRlKC0xNjkwLjQ1MTM2NjU0ODI2NiwtNjQ5LjY0OTEyMjkwODgzNzgpIj4KPC9nPgo8ZyBpZD0ibGF5ZXIyIiB0cmFuc2Zvcm09InRyYW5zbGF0ZSgtMTY5MC40NTEzNjY1NDgyNjYsLTY0OS42NDkxMjI5MDg4Mzc4KSI+CjwvZz4KPGcgaWQ9Imc5Mjg5IiB0cmFuc2Zvcm09InRyYW5zbGF0ZSgtMTY5MC40NTEzNjY1NDgyNjYsLTY0OS42NDkxMjI5MDg4Mzc4KSI+CjwvZz4KPGcgaWQ9ImczNzAzNSIgdHJhbnNmb3JtPSJtYXRyaXgoMC45MjM3Mzc3MTE4ODg0Nzk5LDAsMCwwLjk0Mjk1MzkzMDg1MjE5OTksNDgzLjY4ODA1Nzc4NDY4NjQsMS41NzU0Njk1NDg2MzY5MzEpIj4KCTxnIGlkPSJnNjM1NCIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoLTYwLjc3MzUxOSwtMTI1LjIwNjkzKSI+CgkJPGcgaWQ9ImcxNzkyNCI+CgkJCTxnIGlkPSJsYXllcjEtNiIgdHJhbnNmb3JtPSJtYXRyaXgoMS4yMjIxLDAsMCwxLjIyMjEsLTE2NS43MDQzOSwxOTcuMTA5MzgpIj4KCQkJCTxnIGlkPSJnMTE1MTkiIHRyYW5zZm9ybT0ibWF0cml4KDAuNzQ0NDA5MywwLDAsMC44MzA0Mzg5OTk5OTk5OTk5LDE5My4yNjIwNyw3My4xNDkyMzQpIj4KCQkJCQk8ZyBpZD0iZzExNTIxIiB0cmFuc2Zvcm09InRyYW5zbGF0ZSgtMjAuNDY5NjU1LC0yNzguMTEyMzUpIj4KCQkJCQkJPGcgaWQ9ImcxMjExMSIgdHJhbnNmb3JtPSJtYXRyaXgoMSwwLDAsMC45LC05NC4yNDAxMTY5OTk5OTk5OCwtNy4xMDY5NTAzMDAwMDAwMDIpIj4KCQkJCQkJPC9nPgoJCQkJCTwvZz4KCQkJCTwvZz4KCQkJPC9nPgoJCTwvZz4KCTwvZz4KPC9nPgo8ZyBpZD0iRmllbGQiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTI2NTAuNjkyODM5Njk4MzUzLDE0ODguNzcxNzU0NjIzNjE0KSI+CjwvZz4KPGcgaWQ9IlRyaWNrIiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC0yNjUwLjY5MjgzOTY5ODM1MywxNDg4Ljc3MTc1NDYyMzYxNCkiPgo8L2c+CjxnIGlkPSJCb3JkZXIiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTI2NTAuNjkyODM5Njk4MzUzLDE0ODguNzcxNzU0NjIzNjE0KSI+CjwvZz4KPGcgaWQ9IkZpZWxkLTUiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTI2NjguNDMwMTM5Njk4MzUzLDE0NjQuODcxMDU0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9IlRyaWNrLTAiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTI2NjguNDMwMTM5Njk4MzUzLDE0NjQuODcxMDU0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9IkJvcmRlci03IiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC0yNjY4LjQzMDEzOTY5ODM1MywxNDY0Ljg3MTA1NDYyMzYxMykiPgo8L2c+CjxnIGlkPSJGaWVsZC0zIiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC0yNjY4LjQ2NDAzOTY5ODM1NCwxNDg4LjA1NTI1NDYyMzYxNCkiPgo8L2c+CjxnIGlkPSJCb3JkZXItNSIgdHJhbnNmb3JtPSJtYXRyaXgoMC4yMjgwNDEyNCwwLDAsMC4yMjgwNDEyNCwtMjY2OC40NjQwMzk2OTgzNTQsMTQ4OC4wNTUyNTQ2MjM2MTQpIj4KPC9nPgo8ZyBpZD0idXNlMzEwNCIgdHJhbnNmb3JtPSJtYXRyaXgoMC4yMjgwNDEyNCwwLDAsMC4yMjgwNDEyNCwtMjY2OC40MTQxMzk2OTgzNTQsMTQ4OC4wNjkwNTQ2MjM2MTMpIj4KPC9nPgo8ZyBpZD0iVHJpY2stNCIgdHJhbnNmb3JtPSJtYXRyaXgoMC4yMjgwNDEyNCwwLDAsMC4yMjgwNDEyNCwtMjY2OC4yODIxMzk2OTgzNTQsMTQ4OC4wMTg4NTQ2MjM2MTMpIj4KPC9nPgo8ZyBpZD0iRmllbGQtMiIgdHJhbnNmb3JtPSJtYXRyaXgoMC4yMjgwNDEyNCwwLDAsMC4yMjgwNDEyNCwtMjY2OC40MzAxMzk2OTgzNTMsMTUxMS4yMzk0NTQ2MjM2MTMpIj4KPC9nPgo8ZyBpZD0iVHJpY2stMiIgdHJhbnNmb3JtPSJtYXRyaXgoMC4yMjgwNDEyNCwwLDAsMC4yMjgwNDEyNCwtMjY2OC40MzAxMzk2OTgzNTMsMTUxMS4yMzk0NTQ2MjM2MTMpIj4KPC9nPgo8ZyBpZD0iQm9yZGVyLTEiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTI2NjguNDMwMTM5Njk4MzUzLDE1MTEuMjM5NDU0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9IkZpZWxkLTM2IiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC0yNjY4LjQzMDEzOTY5ODM1MywxNTM0LjQyMzY1NDYyMzYxMykiPgo8L2c+CjxnIGlkPSJUcmljay0wOCIgdHJhbnNmb3JtPSJtYXRyaXgoMC4yMjgwNDEyNCwwLDAsMC4yMjgwNDEyNCwtMjY2OC40MzAxMzk2OTgzNTMsMTUzNC40MjM2NTQ2MjM2MTMpIj4KPC9nPgo8ZyBpZD0iQm9yZGVyLTgiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTI2NjguNDMwMTM5Njk4MzUzLDE1MzQuNDIzNjU0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9IkZpZWxkLTkiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTI2NjguNDMwMTM5Njk4MzUzLDE1NTcuNjA3ODU0NjIzNjE0KSI+CjwvZz4KPGcgaWQ9IlRyaWNrLTgiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTI2NjguNDMwMTM5Njk4MzUzLDE1NTcuNjA3ODU0NjIzNjE0KSI+CjwvZz4KPGcgaWQ9IkJvcmRlci00IiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC0yNjY4LjQzMDEzOTY5ODM1MywxNTU3LjYwNzg1NDYyMzYxNCkiPgo8L2c+CjxnIGlkPSJGaWVsZC0xIiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC0yNjUwLjM3MDEzOTY5ODM1MywxNTU1LjYzNzE1NDYyMzYxMykiPgo8L2c+CjxnIGlkPSJUcmljay01IiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC0yNjUwLjM3MDEzOTY5ODM1MywxNTU1LjYzNzE1NDYyMzYxMykiPgo8L2c+CjxnIGlkPSJCb3JkZXItOSIgdHJhbnNmb3JtPSJtYXRyaXgoMC4yMjgwNDEyNCwwLDAsMC4yMjgwNDEyNCwtMjY1MC4zNzAxMzk2OTgzNTMsMTU1NS42MzcxNTQ2MjM2MTMpIj4KPC9nPgo8ZyBpZD0iRmllbGQtMTciIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTI2NDkuNzI1MjM5Njk4MzU0LDE1MzMuMzQ4OTU0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9IlRyaWNrLTEiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTI2NDkuNzI1MjM5Njk4MzU0LDE1MzMuMzQ4OTU0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9IkJvcmRlci05OSIgdHJhbnNmb3JtPSJtYXRyaXgoMC4yMjgwNDEyNCwwLDAsMC4yMjgwNDEyNCwtMjY0OS43MjUyMzk2OTgzNTQsMTUzMy4zNDg5NTQ2MjM2MTMpIj4KPC9nPgo8ZyBpZD0iRmllbGQtNTMiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTI2ODkuMDcwMTM5Njk4MzU0LDE0ODkuNzc1ODU0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9IlRyaWNrLTEyIiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC0yNjg5LjA3MDEzOTY5ODM1NCwxNDg5Ljc3NTg1NDYyMzYxMykiPgo8L2c+CjxnIGlkPSJCb3JkZXItMTIiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTI2ODkuMDcwMTM5Njk4MzU0LDE0ODkuNzc1ODU0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9IkZpZWxkLTk0IiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC0yNjQ4Ljc1NzYzOTY5ODM1NCwxNTExLjAyNTA1NDYyMzYxMykiPgo8L2c+CjxnIGlkPSJUcmljay0wOSIgdHJhbnNmb3JtPSJtYXRyaXgoMC4yMjgwNDEyNCwwLDAsMC4yMjgwNDEyNCwtMjY0OC43NTc2Mzk2OTgzNTQsMTUxMS4wMjUwNTQ2MjM2MTMpIj4KPC9nPgo8ZyBpZD0iQm9yZGVyLTUxIiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC0yNjQ4Ljc1NzYzOTY5ODM1NCwxNTExLjAyNTA1NDYyMzYxMykiPgo8L2c+CjxnIGlkPSJGaWVsZC0yMSIgdHJhbnNmb3JtPSJtYXRyaXgoMC4yMjgwNDEyNCwwLDAsMC4yMjgwNDEyNCwtMjY2Ni4xNzI3Mzk2OTgzNTMsMTU4Mi4yMjU4NTQ2MjM2MTMpIj4KPC9nPgo8ZyBpZD0iVHJpY2stNDYiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTI2NjYuMTcyNzM5Njk4MzUzLDE1ODIuMjI1ODU0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9IkJvcmRlci0wIiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC0yNjY2LjE3MjczOTY5ODM1MywxNTgyLjIyNTg1NDYyMzYxMykiPgo8L2c+CjxlbGxpcHNlIGlkPSJlbGxpcHNlNTY3OSIgZmlsbD0iYmxhY2siIGN4PSIxMzIyLjEyMSIgY3k9IjEwNTQuMTUxIiByeD0iMCIgcnk9IjAiLz4KPGVsbGlwc2UgaWQ9ImVsbGlwc2U1NjgzIiBmaWxsPSIjRkZGRkZGIiBjeD0iMTMyMi4xMjEiIGN5PSIxMDUzLjkyMyIgcng9IjAiIHJ5PSIwIi8+CjxlbGxpcHNlIGlkPSJlbGxpcHNlNTc0OSIgZmlsbD0iYmxhY2siIGN4PSIxMzUzLjU0NiIgY3k9IjEwNTMuNDY4IiByeD0iMCIgcnk9IjAiLz4KPGVsbGlwc2UgaWQ9ImVsbGlwc2U1NzUzIiBmaWxsPSIjRkZGRkZGIiBjeD0iMTM1My41NDYiIGN5PSIxMDUzLjQ2OCIgcng9IjAiIHJ5PSIwIi8+CjxlbGxpcHNlIGlkPSJlbGxpcHNlNTgxOSIgZmlsbD0iYmxhY2siIGN4PSIxMzM3LjYwNiIgY3k9IjEwODEuNDc3IiByeD0iMCIgcnk9IjAiLz4KPGVsbGlwc2UgaWQ9ImVsbGlwc2U1ODIzIiBmaWxsPSIjRkZGRkZGIiBjeD0iMTMzNy42MDYiIGN5PSIxMDgxLjI0OSIgcng9IjAiIHJ5PSIwIi8+CjxnIGlkPSJGaWVsZC0yMyIgdHJhbnNmb3JtPSJtYXRyaXgoMC4yMjgwNDEyNCwwLDAsMC4yMjgwNDEyNCwtODg2LjM4MzkzOTY5ODM1MzgsMTQwMi42MDg3NDQ2MjM2MTMpIj4KPC9nPgo8ZyBpZD0iVHJpY2stMTgiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTg4Ni4zODM5Mzk2OTgzNTM4LDE0MDIuNjA4NzQ0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9IkJvcmRlci03NCIgdHJhbnNmb3JtPSJtYXRyaXgoMC4yMjgwNDEyNCwwLDAsMC4yMjgwNDEyNCwtODg2LjM4MzkzOTY5ODM1MzgsMTQwMi42MDg3NDQ2MjM2MTMpIj4KPC9nPgo8ZyBpZD0iRmllbGQtNS02IiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC05MDQuMTIxMTM5Njk4MzUzNSwxMzc4LjcwODA2NDYyMzYxMykiPgo8L2c+CjxnIGlkPSJUcmljay0wLTMiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTkwNC4xMjExMzk2OTgzNTM1LDEzNzguNzA4MDY0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9IkJvcmRlci03LTgiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTkwNC4xMjExMzk2OTgzNTM1LDEzNzguNzA4MDY0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9IkZpZWxkLTMtNSIgdHJhbnNmb3JtPSJtYXRyaXgoMC4yMjgwNDEyNCwwLDAsMC4yMjgwNDEyNCwtOTA0LjE1NTEzOTY5ODM1MzYsMTQwMS44OTIyMTQ2MjM2MTMpIj4KPC9nPgo8ZyBpZD0iQm9yZGVyLTUtMCIgdHJhbnNmb3JtPSJtYXRyaXgoMC4yMjgwNDEyNCwwLDAsMC4yMjgwNDEyNCwtOTA0LjE1NTEzOTY5ODM1MzYsMTQwMS44OTIyMTQ2MjM2MTMpIj4KPC9nPgo8ZyBpZD0idXNlMzEwNC0xIiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC05MDQuMTA1MTM5Njk4MzUzOCwxNDAxLjkwNjAzNDYyMzYxMykiPgo8L2c+CjxnIGlkPSJUcmljay00LTIiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTkwMy45NzMxMzk2OTgzNTM3LDE0MDEuODU1ODI0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9IkZpZWxkLTItNCIgdHJhbnNmb3JtPSJtYXRyaXgoMC4yMjgwNDEyNCwwLDAsMC4yMjgwNDEyNCwtOTA0LjEyMTEzOTY5ODM1MzUsMTQyNS4wNzY0NTQ2MjM2MTMpIj4KPC9nPgo8ZyBpZD0iVHJpY2stMi04IiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC05MDQuMTIxMTM5Njk4MzUzNSwxNDI1LjA3NjQ1NDYyMzYxMykiPgo8L2c+CjxnIGlkPSJCb3JkZXItMS01IiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC05MDQuMTIxMTM5Njk4MzUzNSwxNDI1LjA3NjQ1NDYyMzYxMykiPgo8L2c+CjxnIGlkPSJGaWVsZC0zNi0yIiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC05MDQuMTIxMTM5Njk4MzUzNSwxNDQ4LjI2MDY1NDYyMzYxMykiPgo8L2c+CjxnIGlkPSJUcmljay0wOC01IiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC05MDQuMTIxMTM5Njk4MzUzNSwxNDQ4LjI2MDY1NDYyMzYxMykiPgo8L2c+CjxnIGlkPSJCb3JkZXItOC0yIiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC05MDQuMTIxMTM5Njk4MzUzNSwxNDQ4LjI2MDY1NDYyMzYxMykiPgo8L2c+CjxnIGlkPSJGaWVsZC05LTkiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTkwNC4xMjExMzk2OTgzNTM1LDE0NzEuNDQ0NzU0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9IlRyaWNrLTgtMSIgdHJhbnNmb3JtPSJtYXRyaXgoMC4yMjgwNDEyNCwwLDAsMC4yMjgwNDEyNCwtOTA0LjEyMTEzOTY5ODM1MzUsMTQ3MS40NDQ3NTQ2MjM2MTMpIj4KPC9nPgo8ZyBpZD0iQm9yZGVyLTQtMyIgdHJhbnNmb3JtPSJtYXRyaXgoMC4yMjgwNDEyNCwwLDAsMC4yMjgwNDEyNCwtOTA0LjEyMTEzOTY5ODM1MzUsMTQ3MS40NDQ3NTQ2MjM2MTMpIj4KPC9nPgo8ZyBpZD0iRmllbGQtMS0xIiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC04ODYuMDYxMjM5Njk4MzUzMywxNDY5LjQ3NDE1NDYyMzYxMykiPgo8L2c+CjxnIGlkPSJUcmljay01LTUiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTg4Ni4wNjEyMzk2OTgzNTMzLDE0NjkuNDc0MTU0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9IkJvcmRlci05LTIiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTg4Ni4wNjEyMzk2OTgzNTMzLDE0NjkuNDc0MTU0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9IkZpZWxkLTE3LTkiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTg4NS40MTYzMzk2OTgzNTM0LDE0NDcuMTg1OTU0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9IlRyaWNrLTEtNCIgdHJhbnNmb3JtPSJtYXRyaXgoMC4yMjgwNDEyNCwwLDAsMC4yMjgwNDEyNCwtODg1LjQxNjMzOTY5ODM1MzQsMTQ0Ny4xODU5NTQ2MjM2MTMpIj4KPC9nPgo8ZyBpZD0iQm9yZGVyLTk5LTQiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTg4NS40MTYzMzk2OTgzNTM0LDE0NDcuMTg1OTU0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9IkZpZWxkLTUzLTAiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTkyNC43NjExMzk2OTgzNTM2LDE0MDMuNjEyNzg0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9IlRyaWNrLTEyLTciIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTkyNC43NjExMzk2OTgzNTM2LDE0MDMuNjEyNzg0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9IkJvcmRlci0xMi00IiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC05MjQuNzYxMTM5Njk4MzUzNiwxNDAzLjYxMjc4NDYyMzYxMykiPgo8L2c+CjxnIGlkPSJGaWVsZC05NC03IiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC04ODQuNDQ4NzM5Njk4MzUzNiwxNDI0Ljg2MjA1NDYyMzYxMykiPgo8L2c+CjxnIGlkPSJUcmljay0wOS05IiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC04ODQuNDQ4NzM5Njk4MzUzNiwxNDI0Ljg2MjA1NDYyMzYxMykiPgo8L2c+CjxnIGlkPSJCb3JkZXItNTEtMCIgdHJhbnNmb3JtPSJtYXRyaXgoMC4yMjgwNDEyNCwwLDAsMC4yMjgwNDEyNCwtODg0LjQ0ODczOTY5ODM1MzYsMTQyNC44NjIwNTQ2MjM2MTMpIj4KPC9nPgo8ZyBpZD0iRmllbGQtMjEtMiIgdHJhbnNmb3JtPSJtYXRyaXgoMC4yMjgwNDEyNCwwLDAsMC4yMjgwNDEyNCwtOTAxLjg2MzczOTY5ODM1MzMsMTQ5Ni4wNjI4NTQ2MjM2MTMpIj4KPC9nPgo8ZyBpZD0iVHJpY2stNDYtMiIgdHJhbnNmb3JtPSJtYXRyaXgoMC4yMjgwNDEyNCwwLDAsMC4yMjgwNDEyNCwtOTAxLjg2MzczOTY5ODM1MzMsMTQ5Ni4wNjI4NTQ2MjM2MTMpIj4KPC9nPgo8ZyBpZD0iQm9yZGVyLTAtNiIgdHJhbnNmb3JtPSJtYXRyaXgoMC4yMjgwNDEyNCwwLDAsMC4yMjgwNDEyNCwtOTAxLjg2MzczOTY5ODM1MzMsMTQ5Ni4wNjI4NTQ2MjM2MTMpIj4KPC9nPgo8cGF0aCBpZD0icGF0aDQxNTYiIGZpbGw9IiNGRkZGRkYiIGQ9Ik0wLTQuNSIvPgo8ZyBpZD0iRmllbGQtMjAiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTI1MTkuOTYyMDM5Njk4MzU0LDE5OTAuODkwOTU0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9IlRyaWNrLTMiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTI1MTkuOTYyMDM5Njk4MzU0LDE5OTAuODkwOTU0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9IkJvcmRlci0wNCIgdHJhbnNmb3JtPSJtYXRyaXgoMC4yMjgwNDEyNCwwLDAsMC4yMjgwNDEyNCwtMjUxOS45NjIwMzk2OTgzNTQsMTk5MC44OTA5NTQ2MjM2MTMpIj4KPC9nPgo8ZyBpZD0iRmllbGQtNS0wIiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC0yNTM3LjY5OTMzOTY5ODM1MywxOTY2Ljk5MDM1NDYyMzYxMykiPgo8L2c+CjxnIGlkPSJUcmljay0wLTAiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTI1MzcuNjk5MzM5Njk4MzUzLDE5NjYuOTkwMzU0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9IkJvcmRlci03LTUiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTI1MzcuNjk5MzM5Njk4MzUzLDE5NjYuOTkwMzU0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9IkZpZWxkLTMtNTciIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTI1MzcuNzMzMjM5Njk4MzUzLDE5OTAuMTc0NDU0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9IkJvcmRlci01LTAzIiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC0yNTM3LjczMzIzOTY5ODM1MywxOTkwLjE3NDQ1NDYyMzYxMykiPgo8L2c+CjxnIGlkPSJ1c2UzMTA0LTgiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTI1MzcuNjgzMzM5Njk4MzUzLDE5OTAuMTg4MzU0NjIzNjE0KSI+CjwvZz4KPGcgaWQ9IlRyaWNrLTQtNiIgdHJhbnNmb3JtPSJtYXRyaXgoMC4yMjgwNDEyNCwwLDAsMC4yMjgwNDEyNCwtMjUzNy41NTEzMzk2OTgzNTMsMTk5MC4xMzgwNTQ2MjM2MTMpIj4KPC9nPgo8ZyBpZD0iRmllbGQtMi05IiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC0yNTM3LjY5OTMzOTY5ODM1MywyMDEzLjM1ODc1NDYyMzYxNCkiPgo8L2c+CjxnIGlkPSJUcmljay0yLTEiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTI1MzcuNjk5MzM5Njk4MzUzLDIwMTMuMzU4NzU0NjIzNjE0KSI+CjwvZz4KPGcgaWQ9IkJvcmRlci0xLTAiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTI1MzcuNjk5MzM5Njk4MzUzLDIwMTMuMzU4NzU0NjIzNjE0KSI+CjwvZz4KPGcgaWQ9IkZpZWxkLTM2LTAiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTI1MzcuNjk5MzM5Njk4MzUzLDIwMzYuNTQyODU0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9IlRyaWNrLTA4LTU4IiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC0yNTM3LjY5OTMzOTY5ODM1MywyMDM2LjU0Mjg1NDYyMzYxMykiPgo8L2c+CjxnIGlkPSJCb3JkZXItOC01IiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC0yNTM3LjY5OTMzOTY5ODM1MywyMDM2LjU0Mjg1NDYyMzYxMykiPgo8L2c+CjxnIGlkPSJGaWVsZC05LTciIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTI1MzcuNjk5MzM5Njk4MzUzLDIwNTkuNzI3MDU0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9IlRyaWNrLTgtOSIgdHJhbnNmb3JtPSJtYXRyaXgoMC4yMjgwNDEyNCwwLDAsMC4yMjgwNDEyNCwtMjUzNy42OTkzMzk2OTgzNTMsMjA1OS43MjcwNTQ2MjM2MTMpIj4KPC9nPgo8ZyBpZD0iQm9yZGVyLTQtNiIgdHJhbnNmb3JtPSJtYXRyaXgoMC4yMjgwNDEyNCwwLDAsMC4yMjgwNDEyNCwtMjUzNy42OTkzMzk2OTgzNTMsMjA1OS43MjcwNTQ2MjM2MTMpIj4KPC9nPgo8ZyBpZD0iRmllbGQtMS05IiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC0yNTE5LjYzOTMzOTY5ODM1MywyMDU3Ljc1NjM1NDYyMzYxMykiPgo8L2c+CjxnIGlkPSJUcmljay01LTYiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTI1MTkuNjM5MzM5Njk4MzUzLDIwNTcuNzU2MzU0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9IkJvcmRlci05LTI4IiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC0yNTE5LjYzOTMzOTY5ODM1MywyMDU3Ljc1NjM1NDYyMzYxMykiPgo8L2c+CjxnIGlkPSJGaWVsZC0xNy04IiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC0yNTE4Ljk5NDQzOTY5ODM1MywyMDM1LjQ2ODE1NDYyMzYxMykiPgo8L2c+CjxnIGlkPSJUcmljay0xLTQzIiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC0yNTE4Ljk5NDQzOTY5ODM1MywyMDM1LjQ2ODE1NDYyMzYxMykiPgo8L2c+CjxnIGlkPSJCb3JkZXItOTktMiIgdHJhbnNmb3JtPSJtYXRyaXgoMC4yMjgwNDEyNCwwLDAsMC4yMjgwNDEyNCwtMjUxOC45OTQ0Mzk2OTgzNTMsMjAzNS40NjgxNTQ2MjM2MTMpIj4KPC9nPgo8ZyBpZD0iRmllbGQtNTMtNiIgdHJhbnNmb3JtPSJtYXRyaXgoMC4yMjgwNDEyNCwwLDAsMC4yMjgwNDEyNCwtMjU1OC4zMzkzMzk2OTgzNTMsMTk5MS44OTUwNTQ2MjM2MTMpIj4KPC9nPgo8ZyBpZD0iVHJpY2stMTItOCIgdHJhbnNmb3JtPSJtYXRyaXgoMC4yMjgwNDEyNCwwLDAsMC4yMjgwNDEyNCwtMjU1OC4zMzkzMzk2OTgzNTMsMTk5MS44OTUwNTQ2MjM2MTMpIj4KPC9nPgo8ZyBpZD0iQm9yZGVyLTEyLTIiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTI1NTguMzM5MzM5Njk4MzUzLDE5OTEuODk1MDU0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9IkZpZWxkLTk0LTEiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTI1MTguMDI2ODM5Njk4MzUzLDIwMTMuMTQ0MjU0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9IlRyaWNrLTA5LTgiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTI1MTguMDI2ODM5Njk4MzUzLDIwMTMuMTQ0MjU0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9IkJvcmRlci01MS0zIiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC0yNTE4LjAyNjgzOTY5ODM1MywyMDEzLjE0NDI1NDYyMzYxMykiPgo8L2c+CjxnIGlkPSJGaWVsZC0yMS02IiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC0yNTM1LjQ0MTkzOTY5ODM1MywyMDg0LjM0NTA1NDYyMzYxNCkiPgo8L2c+CjxnIGlkPSJUcmljay00Ni01IiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC0yNTM1LjQ0MTkzOTY5ODM1MywyMDg0LjM0NTA1NDYyMzYxNCkiPgo8L2c+CjxnIGlkPSJCb3JkZXItMC0wIiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC0yNTM1LjQ0MTkzOTY5ODM1MywyMDg0LjM0NTA1NDYyMzYxNCkiPgo8L2c+CjxlbGxpcHNlIGlkPSJlbGxpcHNlNTY3OS0wIiBmaWxsPSJibGFjayIgY3g9IjE0NTIuODUzIiBjeT0iMTU1Ni4yNzEiIHJ4PSIwIiByeT0iMCIvPgo8ZWxsaXBzZSBpZD0iZWxsaXBzZTU2ODMtMSIgZmlsbD0iI0ZGRkZGRiIgY3g9IjE0NTIuODUzIiBjeT0iMTU1Ni4wNDMiIHJ4PSIwIiByeT0iMCIvPgo8ZWxsaXBzZSBpZD0iZWxsaXBzZTU3NDktNyIgZmlsbD0iYmxhY2siIGN4PSIxNDg0LjI3NiIgY3k9IjE1NTUuNTg3IiByeD0iMCIgcnk9IjAiLz4KPGVsbGlwc2UgaWQ9ImVsbGlwc2U1NzUzLTAiIGZpbGw9IiNGRkZGRkYiIGN4PSIxNDg0LjI3NiIgY3k9IjE1NTUuNTg3IiByeD0iMCIgcnk9IjAiLz4KPGVsbGlwc2UgaWQ9ImVsbGlwc2U1ODE5LTYiIGZpbGw9ImJsYWNrIiBjeD0iMTQ2OC4zMzciIGN5PSIxNTgzLjU5NiIgcng9IjAiIHJ5PSIwIi8+CjxlbGxpcHNlIGlkPSJlbGxpcHNlNTgyMy03IiBmaWxsPSIjRkZGRkZGIiBjeD0iMTQ2OC4zMzciIGN5PSIxNTgzLjM2OCIgcng9IjAiIHJ5PSIwIi8+CjxnIGlkPSJGaWVsZC0yMy03IiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC03NTUuNjUzMDM5Njk4MzUzNywxOTA0LjcyNzk1NDYyMzYxMykiPgo8L2c+CjxnIGlkPSJUcmljay0xOC02IiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC03NTUuNjUzMDM5Njk4MzUzNywxOTA0LjcyNzk1NDYyMzYxMykiPgo8L2c+CjxnIGlkPSJCb3JkZXItNzQtNyIgdHJhbnNmb3JtPSJtYXRyaXgoMC4yMjgwNDEyNCwwLDAsMC4yMjgwNDEyNCwtNzU1LjY1MzAzOTY5ODM1MzcsMTkwNC43Mjc5NTQ2MjM2MTMpIj4KPC9nPgo8ZyBpZD0iRmllbGQtNS02LTUiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTc3My4zOTAyMzk2OTgzNTM3LDE4ODAuODI3MjU0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9IlRyaWNrLTAtMy01IiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC03NzMuMzkwMjM5Njk4MzUzNywxODgwLjgyNzI1NDYyMzYxMykiPgo8L2c+CjxnIGlkPSJCb3JkZXItNy04LTMiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTc3My4zOTAyMzk2OTgzNTM3LDE4ODAuODI3MjU0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9IkZpZWxkLTMtNS04IiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC03NzMuNDI0MjM5Njk4MzUzNywxOTA0LjAxMTQ1NDYyMzYxMykiPgo8L2c+CjxnIGlkPSJCb3JkZXItNS0wLTYiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTc3My40MjQyMzk2OTgzNTM3LDE5MDQuMDExNDU0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9InVzZTMxMDQtMS00IiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC03NzMuMzc0MjM5Njk4MzUzNCwxOTA0LjAyNTI1NDYyMzYxMykiPgo8L2c+CjxnIGlkPSJUcmljay00LTItMiIgdHJhbnNmb3JtPSJtYXRyaXgoMC4yMjgwNDEyNCwwLDAsMC4yMjgwNDEyNCwtNzczLjI0MjIzOTY5ODM1MzgsMTkwMy45NzUwNTQ2MjM2MTMpIj4KPC9nPgo8ZyBpZD0iRmllbGQtMi00LTkiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTc3My4zOTAyMzk2OTgzNTM3LDE5MjcuMTk1NjU0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9IlRyaWNrLTItOC02IiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC03NzMuMzkwMjM5Njk4MzUzNywxOTI3LjE5NTY1NDYyMzYxMykiPgo8L2c+CjxnIGlkPSJCb3JkZXItMS01LTkiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTc3My4zOTAyMzk2OTgzNTM3LDE5MjcuMTk1NjU0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9IkZpZWxkLTM2LTItOSIgdHJhbnNmb3JtPSJtYXRyaXgoMC4yMjgwNDEyNCwwLDAsMC4yMjgwNDEyNCwtNzczLjM5MDIzOTY5ODM1MzcsMTk1MC4zNzk4NTQ2MjM2MTMpIj4KPC9nPgo8ZyBpZD0iVHJpY2stMDgtNS05IiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC03NzMuMzkwMjM5Njk4MzUzNywxOTUwLjM3OTg1NDYyMzYxMykiPgo8L2c+CjxnIGlkPSJCb3JkZXItOC0yLTIiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTc3My4zOTAyMzk2OTgzNTM3LDE5NTAuMzc5ODU0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9IkZpZWxkLTktOS05IiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC03NzMuMzkwMjM5Njk4MzUzNywxOTczLjU2NDA1NDYyMzYxMykiPgo8L2c+CjxnIGlkPSJUcmljay04LTEtMiIgdHJhbnNmb3JtPSJtYXRyaXgoMC4yMjgwNDEyNCwwLDAsMC4yMjgwNDEyNCwtNzczLjM5MDIzOTY5ODM1MzcsMTk3My41NjQwNTQ2MjM2MTMpIj4KPC9nPgo8ZyBpZD0iQm9yZGVyLTQtMy0wIiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC03NzMuMzkwMjM5Njk4MzUzNywxOTczLjU2NDA1NDYyMzYxMykiPgo8L2c+CjxnIGlkPSJGaWVsZC0xLTEtNCIgdHJhbnNmb3JtPSJtYXRyaXgoMC4yMjgwNDEyNCwwLDAsMC4yMjgwNDEyNCwtNzU1LjMzMDMzOTY5ODM1MzUsMTk3MS41OTMzNTQ2MjM2MTMpIj4KPC9nPgo8ZyBpZD0iVHJpY2stNS01LTQiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTc1NS4zMzAzMzk2OTgzNTM1LDE5NzEuNTkzMzU0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9IkJvcmRlci05LTItOCIgdHJhbnNmb3JtPSJtYXRyaXgoMC4yMjgwNDEyNCwwLDAsMC4yMjgwNDEyNCwtNzU1LjMzMDMzOTY5ODM1MzUsMTk3MS41OTMzNTQ2MjM2MTMpIj4KPC9nPgo8ZyBpZD0iRmllbGQtMTctOS01IiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC03NTQuNjg1Mzg5Njk4MzUzNCwxOTQ5LjMwNTE1NDYyMzYxMykiPgo8L2c+CjxnIGlkPSJUcmljay0xLTQtNCIgdHJhbnNmb3JtPSJtYXRyaXgoMC4yMjgwNDEyNCwwLDAsMC4yMjgwNDEyNCwtNzU0LjY4NTM4OTY5ODM1MzQsMTk0OS4zMDUxNTQ2MjM2MTMpIj4KPC9nPgo8ZyBpZD0iQm9yZGVyLTk5LTQtNSIgdHJhbnNmb3JtPSJtYXRyaXgoMC4yMjgwNDEyNCwwLDAsMC4yMjgwNDEyNCwtNzU0LjY4NTM4OTY5ODM1MzQsMTk0OS4zMDUxNTQ2MjM2MTMpIj4KPC9nPgo8ZyBpZD0iRmllbGQtNTMtMC03IiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC03OTQuMDMwMjM5Njk4MzUzNiwxOTA1LjczMjA1NDYyMzYxMykiPgo8L2c+CjxnIGlkPSJUcmljay0xMi03LTUiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTc5NC4wMzAyMzk2OTgzNTM2LDE5MDUuNzMyMDU0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9IkJvcmRlci0xMi00LTIiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTc5NC4wMzAyMzk2OTgzNTM2LDE5MDUuNzMyMDU0NjIzNjEzKSI+CjwvZz4KPGcgaWQ9IkZpZWxkLTk0LTctNyIgdHJhbnNmb3JtPSJtYXRyaXgoMC4yMjgwNDEyNCwwLDAsMC4yMjgwNDEyNCwtNzUzLjcxNzgwOTY5ODM1MzQsMTkyNi45ODEyNTQ2MjM2MTMpIj4KPC9nPgo8ZyBpZD0iVHJpY2stMDktOS00IiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC03NTMuNzE3ODA5Njk4MzUzNCwxOTI2Ljk4MTI1NDYyMzYxMykiPgo8L2c+CjxnIGlkPSJCb3JkZXItNTEtMC0yIiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC03NTMuNzE3ODA5Njk4MzUzNCwxOTI2Ljk4MTI1NDYyMzYxMykiPgo8L2c+CjxnIGlkPSJGaWVsZC0yMS0yLTYiIHRyYW5zZm9ybT0ibWF0cml4KDAuMjI4MDQxMjQsMCwwLDAuMjI4MDQxMjQsLTc3MS4xMzI4Mzk2OTgzNTM0LDE5OTguMTgyMDU0NjIzNjE0KSI+CjwvZz4KPGcgaWQ9IlRyaWNrLTQ2LTItMCIgdHJhbnNmb3JtPSJtYXRyaXgoMC4yMjgwNDEyNCwwLDAsMC4yMjgwNDEyNCwtNzcxLjEzMjgzOTY5ODM1MzQsMTk5OC4xODIwNTQ2MjM2MTQpIj4KPC9nPgo8ZyBpZD0iQm9yZGVyLTAtNi05IiB0cmFuc2Zvcm09Im1hdHJpeCgwLjIyODA0MTI0LDAsMCwwLjIyODA0MTI0LC03NzEuMTMyODM5Njk4MzUzNCwxOTk4LjE4MjA1NDYyMzYxNCkiPgo8L2c+CjxwYXRoIGlkPSJwYXRoNDE1Ni0yIiBmaWxsPSIjRkZGRkZGIiBkPSJNMC00LjUiLz4KPGcgaWQ9Imc0MjI4IiB0cmFuc2Zvcm09InRyYW5zbGF0ZSgxMzguNzcyMDA1MzcxMTIzMiw4Ljk2NzU5NTIxMDY4ODk1NSkiPgoJPGcgaWQ9Imc0MjIzIiB0cmFuc2Zvcm09Im1hdHJpeCgxLjI2NjM0NDg4MDEyMTc5MSwwLDAsMS4yNjYzNDQ4ODAxMjE3OTEsMzUuMzIxODg4ODg4MTA0NDcsLTc1Ljc4Mzc1Mzk2NjQ1MjgyKSI+CgkJPHBhdGggaWQ9InBhdGgzMDY5IiBmaWxsPSJibGFjayIgc3Ryb2tlPSIjMDAwMDAwIiBzdHJva2Utd2lkdGg9IjIuMzY5IiBkPSJNLTAuNTUyLDIxNi44MTkgICAgYy0wLjAxMiwzNS42MjMtMjguOSw2NC40OTEtNjQuNTIyLDY0LjQ3OWMtMzUuNjA2LTAuMDEyLTY0LjQ2Ny0yOC44NzItNjQuNDc4LTY0LjQ3OWMwLTM1LjYyMiwyOC44NzctNjQuNSw2NC41LTY0LjUgICAgQy0yOS40MzEsMTUyLjMxOS0wLjU1MiwxODEuMTk3LTAuNTUyLDIxNi44MTl6Ii8+CgkJPHBhdGggaWQ9InBhdGgzODUzIiBmaWxsPSJibGFjayIgc3Ryb2tlPSIjMDAwMDAwIiBzdHJva2Utd2lkdGg9IjIuMzY5IiBkPSJNLTY0LjQ5Myw1NC42ODNjLTQuOTcxLDAtOSw0LjAyOS05LDkgICAgYzAsMi44OTIsMS4zOCw1LjQ0NywzLjUsNy4wOTR2MjguOTA2aC0zMS4wNjNjLTEuNjQ2LTIuMTItNC4yMDItMy41LTcuMDk0LTMuNWMtNC45NzEsMC05LDQuMDMtOSw5YzAsNC45NzEsNC4wMjksOSw5LDkgICAgYzIuODkyLDAsNS40NDgtMS4zOCw3LjA5NC0zLjVoMzEuMDYzdjU1LjcxOWgxMXYtNTUuNzE5aDMxLjAzMmMxLjY0NiwyLjEyMiw0LjIzMSwzLjUsNy4xMjQsMy41YzQuOTcxLDAsOS00LjAyOSw5LTkgICAgYzAtNC45Ny00LjAyOS05LTktOWMtMi44OTMsMC01LjQ3OCwxLjM3OC03LjEyNCwzLjVoLTMxLjAzMlY3MC43NzZjMi4xMTktMS42NDcsMy41LTQuMjAyLDMuNS03LjA5NCAgICBDLTU1LjQ5Myw1OC43MTItNTkuNTIyLDU0LjY4My02NC40OTMsNTQuNjgzeiIvPgoJCTxwYXRoIGlkPSJwYXRoMzA3MSIgZmlsbD0iYmxhY2siIHN0cm9rZT0iIzAwMDAwMCIgc3Ryb2tlLXdpZHRoPSIyLjM2OSIgZD0iTS02NS4wNTYsMTQ5LjgwN2MtNC42NTksMC05LjIwMiwwLjUwMS0xMy41OTMsMS40MDYgICAgdjQ4Ljg3NWMtMTkuMTgsMS4wMTEtMzcuMTIsNC4xNTMtNTIuOTM3LDguOTM4Yy0wLjI5NywyLjU1Ny0wLjQ2OSw1LjE0NC0wLjQ2OSw3Ljc4MWMwLDUuODAyLDAuNzM4LDExLjQ0MywyLjEyNSwxNi44MTIgICAgYzE5LjEyMy01LjU5Niw0MS4yNjgtOC44MTIsNjQuODc1LTguODEyYzIzLjYwNSwwLDQ1Ljc1MiwzLjIxNiw2NC44NzUsOC44MTJjMS4zODgtNS4zNzIsMi4xMjUtMTEuMDA3LDIuMTI1LTE2LjgxMiAgICBjMC0yLjYzNy0wLjE3My01LjIyNC0wLjQ2OS03Ljc4MWMtMTUuODE3LTQuNzg1LTMzLjc1Ny03LjkyNy01Mi45MzctOC45Mzh2LTQ4Ljg3NSAgICBDLTU1Ljg1MywxNTAuMzA4LTYwLjM5NiwxNDkuODA3LTY1LjA1NiwxNDkuODA3eiIvPgoJPC9nPgo8L2c+Cjwvc3ZnPgo=" align="right" anchor="_94add58a-df35-4222-9808-5271f56712fb" type="svg" alt="Orb"></artwork>
                      [a]
                     <fn>
                       <t anchor='_ef2c85b8-5a5a-4ecd-a1e6-92acefaaa852'>[a] The time $$ t_90 $$ was estimated to be 18,2 min for this example.</t>
                     </fn>
                     <dl>
                       <dt>
                         <p>A</p>
                       </dt>
                       <dd>
                         <t>B</t>
                       </dd>
                     </dl>
                   </figure>
                   <figure anchor='figure-B'>
                     <artwork anchor='BC' alt='hello' type='ascii-art'><![CDATA[A <
             B]]></artwork>
                   </figure>
                   <figure anchor='figure-C'>
                     <artwork type='ascii-art'><![CDATA[A <
             B]]></artwork>
                   </figure>
                   </abstract>
               </front>
               <middle/>
               <back/>
             </rfc>
    INPUT
    output = <<~OUTPUT
             <rfc xmlns:xi='http://www.w3.org/2001/XInclude' version='3'>
               <front>
                 <abstract>
      <figure anchor='figureA-00'>
        <name>Unnested figure</name>
      </figure>
      <figure anchor='figureA-001'> </figure>
      <aside>
        <t>X</t>
      </aside>
                     <artwork src='spec/assets/Example.svg' align='right' anchor='_56cb3ff4-1775-40c6-b75d-d5c2283e8338' type='svg' alt='Orb'/>
        <sourcecode><![CDATA[]]></sourcecode>
                       <t anchor='AAA'>Random text</t>
                   <figure anchor='figureA-1'>
                      [a]
                     <name>
                        Split-it-right
                       <em>sample</em>
                        divider
                     </name>
                     <artwork src='rice_images/rice_image1.png' title='titletxt' anchor='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' type='svg' alt='alttext'/>
                     </figure>
                       <artwork src='rice_images/rice_image1.png' anchor='_8357ede4-6d44-4672-bac4-9a85e82ab7f1' type='svg'/>
                       <artwork align='right' anchor='_94add58a-df35-4222-9808-5271f56712fb' type='svg' alt='Orb'>
                       <svg xmlns:svg='http://www.w3.org/2000/svg' xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#' xmlns:inkscape='http://www.inkscape.org/namespaces/inkscape' xmlns:dc='http://purl.org/dc/elements/1.1/' xmlns:cc='http://creativecommons.org/ns#' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' version='1.1' id='svg2' x='0px' y='0px' width='182px' height='291.834px' viewBox='0 0 182 291.834' xml:space='preserve' preserveAspectRatio='xMidYMid meet'>
                 <defs> </defs>
                 <g id='g9086' transform='translate(-1746.880086548266,-573.0087829088379)'> </g>
                 <g id='g9088' transform='translate(-1690.451366548266,-649.6491229088378)'> </g>
                 <g id='layer2' transform='translate(-1690.451366548266,-649.6491229088378)'> </g>
                 <g id='g9289' transform='translate(-1690.451366548266,-649.6491229088378)'> </g>
                 <g id='g37035' transform='matrix(0.9237377118884799,0,0,0.9429539308521999,483.6880577846864,1.575469548636931)'>
                   <g id='g6354' transform='translate(-60.773519,-125.20693)'>
                     <g id='g17924'>
                       <g id='layer1-6' transform='matrix(1.2221,0,0,1.2221,-165.70439,197.10938)'>
                         <g id='g11519' transform='matrix(0.7444093,0,0,0.8304389999999999,193.26207,73.149234)'>
                           <g id='g11521' transform='translate(-20.469655,-278.11235)'>
                             <g id='g12111' transform='matrix(1,0,0,0.9,-94.24011699999998,-7.106950300000002)'> </g>
                           </g>
                         </g>
                       </g>
                     </g>
                   </g>
                 </g>
                 <g id='Field' transform='matrix(0.22804124,0,0,0.22804124,-2650.692839698353,1488.771754623614)'> </g>
                 <g id='Trick' transform='matrix(0.22804124,0,0,0.22804124,-2650.692839698353,1488.771754623614)'> </g>
                 <g id='Border' transform='matrix(0.22804124,0,0,0.22804124,-2650.692839698353,1488.771754623614)'> </g>
                 <g id='Field-5' transform='matrix(0.22804124,0,0,0.22804124,-2668.430139698353,1464.871054623613)'> </g>
                 <g id='Trick-0' transform='matrix(0.22804124,0,0,0.22804124,-2668.430139698353,1464.871054623613)'> </g>
                 <g id='Border-7' transform='matrix(0.22804124,0,0,0.22804124,-2668.430139698353,1464.871054623613)'> </g>
                 <g id='Field-3' transform='matrix(0.22804124,0,0,0.22804124,-2668.464039698354,1488.055254623614)'> </g>
                 <g id='Border-5' transform='matrix(0.22804124,0,0,0.22804124,-2668.464039698354,1488.055254623614)'> </g>
                 <g id='use3104' transform='matrix(0.22804124,0,0,0.22804124,-2668.414139698354,1488.069054623613)'> </g>
                 <g id='Trick-4' transform='matrix(0.22804124,0,0,0.22804124,-2668.282139698354,1488.018854623613)'> </g>
                 <g id='Field-2' transform='matrix(0.22804124,0,0,0.22804124,-2668.430139698353,1511.239454623613)'> </g>
                 <g id='Trick-2' transform='matrix(0.22804124,0,0,0.22804124,-2668.430139698353,1511.239454623613)'> </g>
                 <g id='Border-1' transform='matrix(0.22804124,0,0,0.22804124,-2668.430139698353,1511.239454623613)'> </g>
                 <g id='Field-36' transform='matrix(0.22804124,0,0,0.22804124,-2668.430139698353,1534.423654623613)'> </g>
                 <g id='Trick-08' transform='matrix(0.22804124,0,0,0.22804124,-2668.430139698353,1534.423654623613)'> </g>
                 <g id='Border-8' transform='matrix(0.22804124,0,0,0.22804124,-2668.430139698353,1534.423654623613)'> </g>
                 <g id='Field-9' transform='matrix(0.22804124,0,0,0.22804124,-2668.430139698353,1557.607854623614)'> </g>
                 <g id='Trick-8' transform='matrix(0.22804124,0,0,0.22804124,-2668.430139698353,1557.607854623614)'> </g>
                 <g id='Border-4' transform='matrix(0.22804124,0,0,0.22804124,-2668.430139698353,1557.607854623614)'> </g>
                 <g id='Field-1' transform='matrix(0.22804124,0,0,0.22804124,-2650.370139698353,1555.637154623613)'> </g>
                 <g id='Trick-5' transform='matrix(0.22804124,0,0,0.22804124,-2650.370139698353,1555.637154623613)'> </g>
                 <g id='Border-9' transform='matrix(0.22804124,0,0,0.22804124,-2650.370139698353,1555.637154623613)'> </g>
                 <g id='Field-17' transform='matrix(0.22804124,0,0,0.22804124,-2649.725239698354,1533.348954623613)'> </g>
                 <g id='Trick-1' transform='matrix(0.22804124,0,0,0.22804124,-2649.725239698354,1533.348954623613)'> </g>
                 <g id='Border-99' transform='matrix(0.22804124,0,0,0.22804124,-2649.725239698354,1533.348954623613)'> </g>
                 <g id='Field-53' transform='matrix(0.22804124,0,0,0.22804124,-2689.070139698354,1489.775854623613)'> </g>
                 <g id='Trick-12' transform='matrix(0.22804124,0,0,0.22804124,-2689.070139698354,1489.775854623613)'> </g>
                 <g id='Border-12' transform='matrix(0.22804124,0,0,0.22804124,-2689.070139698354,1489.775854623613)'> </g>
                 <g id='Field-94' transform='matrix(0.22804124,0,0,0.22804124,-2648.757639698354,1511.025054623613)'> </g>
                 <g id='Trick-09' transform='matrix(0.22804124,0,0,0.22804124,-2648.757639698354,1511.025054623613)'> </g>
                 <g id='Border-51' transform='matrix(0.22804124,0,0,0.22804124,-2648.757639698354,1511.025054623613)'> </g>
                 <g id='Field-21' transform='matrix(0.22804124,0,0,0.22804124,-2666.172739698353,1582.225854623613)'> </g>
                 <g id='Trick-46' transform='matrix(0.22804124,0,0,0.22804124,-2666.172739698353,1582.225854623613)'> </g>
                 <g id='Border-0' transform='matrix(0.22804124,0,0,0.22804124,-2666.172739698353,1582.225854623613)'> </g>
                 <ellipse id='ellipse5679' fill='black' cx='1322.121' cy='1054.151' rx='0' ry='0'/>
                 <ellipse id='ellipse5683' fill='#FFFFFF' cx='1322.121' cy='1053.923' rx='0' ry='0'/>
                 <ellipse id='ellipse5749' fill='black' cx='1353.546' cy='1053.468' rx='0' ry='0'/>
                 <ellipse id='ellipse5753' fill='#FFFFFF' cx='1353.546' cy='1053.468' rx='0' ry='0'/>
                 <ellipse id='ellipse5819' fill='black' cx='1337.606' cy='1081.477' rx='0' ry='0'/>
                 <ellipse id='ellipse5823' fill='#FFFFFF' cx='1337.606' cy='1081.249' rx='0' ry='0'/>
                 <g id='Field-23' transform='matrix(0.22804124,0,0,0.22804124,-886.3839396983538,1402.608744623613)'> </g>
                 <g id='Trick-18' transform='matrix(0.22804124,0,0,0.22804124,-886.3839396983538,1402.608744623613)'> </g>
                 <g id='Border-74' transform='matrix(0.22804124,0,0,0.22804124,-886.3839396983538,1402.608744623613)'> </g>
                 <g id='Field-5-6' transform='matrix(0.22804124,0,0,0.22804124,-904.1211396983535,1378.708064623613)'> </g>
                 <g id='Trick-0-3' transform='matrix(0.22804124,0,0,0.22804124,-904.1211396983535,1378.708064623613)'> </g>
                 <g id='Border-7-8' transform='matrix(0.22804124,0,0,0.22804124,-904.1211396983535,1378.708064623613)'> </g>
                 <g id='Field-3-5' transform='matrix(0.22804124,0,0,0.22804124,-904.1551396983536,1401.892214623613)'> </g>
                 <g id='Border-5-0' transform='matrix(0.22804124,0,0,0.22804124,-904.1551396983536,1401.892214623613)'> </g>
                 <g id='use3104-1' transform='matrix(0.22804124,0,0,0.22804124,-904.1051396983538,1401.906034623613)'> </g>
                 <g id='Trick-4-2' transform='matrix(0.22804124,0,0,0.22804124,-903.9731396983537,1401.855824623613)'> </g>
                 <g id='Field-2-4' transform='matrix(0.22804124,0,0,0.22804124,-904.1211396983535,1425.076454623613)'> </g>
                 <g id='Trick-2-8' transform='matrix(0.22804124,0,0,0.22804124,-904.1211396983535,1425.076454623613)'> </g>
                 <g id='Border-1-5' transform='matrix(0.22804124,0,0,0.22804124,-904.1211396983535,1425.076454623613)'> </g>
                 <g id='Field-36-2' transform='matrix(0.22804124,0,0,0.22804124,-904.1211396983535,1448.260654623613)'> </g>
                 <g id='Trick-08-5' transform='matrix(0.22804124,0,0,0.22804124,-904.1211396983535,1448.260654623613)'> </g>
                 <g id='Border-8-2' transform='matrix(0.22804124,0,0,0.22804124,-904.1211396983535,1448.260654623613)'> </g>
                 <g id='Field-9-9' transform='matrix(0.22804124,0,0,0.22804124,-904.1211396983535,1471.444754623613)'> </g>
                 <g id='Trick-8-1' transform='matrix(0.22804124,0,0,0.22804124,-904.1211396983535,1471.444754623613)'> </g>
                 <g id='Border-4-3' transform='matrix(0.22804124,0,0,0.22804124,-904.1211396983535,1471.444754623613)'> </g>
                 <g id='Field-1-1' transform='matrix(0.22804124,0,0,0.22804124,-886.0612396983533,1469.474154623613)'> </g>
                 <g id='Trick-5-5' transform='matrix(0.22804124,0,0,0.22804124,-886.0612396983533,1469.474154623613)'> </g>
                 <g id='Border-9-2' transform='matrix(0.22804124,0,0,0.22804124,-886.0612396983533,1469.474154623613)'> </g>
                 <g id='Field-17-9' transform='matrix(0.22804124,0,0,0.22804124,-885.4163396983534,1447.185954623613)'> </g>
                 <g id='Trick-1-4' transform='matrix(0.22804124,0,0,0.22804124,-885.4163396983534,1447.185954623613)'> </g>
                 <g id='Border-99-4' transform='matrix(0.22804124,0,0,0.22804124,-885.4163396983534,1447.185954623613)'> </g>
                 <g id='Field-53-0' transform='matrix(0.22804124,0,0,0.22804124,-924.7611396983536,1403.612784623613)'> </g>
                 <g id='Trick-12-7' transform='matrix(0.22804124,0,0,0.22804124,-924.7611396983536,1403.612784623613)'> </g>
                 <g id='Border-12-4' transform='matrix(0.22804124,0,0,0.22804124,-924.7611396983536,1403.612784623613)'> </g>
                 <g id='Field-94-7' transform='matrix(0.22804124,0,0,0.22804124,-884.4487396983536,1424.862054623613)'> </g>
                 <g id='Trick-09-9' transform='matrix(0.22804124,0,0,0.22804124,-884.4487396983536,1424.862054623613)'> </g>
                 <g id='Border-51-0' transform='matrix(0.22804124,0,0,0.22804124,-884.4487396983536,1424.862054623613)'> </g>
                 <g id='Field-21-2' transform='matrix(0.22804124,0,0,0.22804124,-901.8637396983533,1496.062854623613)'> </g>
                 <g id='Trick-46-2' transform='matrix(0.22804124,0,0,0.22804124,-901.8637396983533,1496.062854623613)'> </g>
                 <g id='Border-0-6' transform='matrix(0.22804124,0,0,0.22804124,-901.8637396983533,1496.062854623613)'> </g>
                 <path id='path4156' fill='#FFFFFF' d='M0-4.5'/>
                 <g id='Field-20' transform='matrix(0.22804124,0,0,0.22804124,-2519.962039698354,1990.890954623613)'> </g>
                 <g id='Trick-3' transform='matrix(0.22804124,0,0,0.22804124,-2519.962039698354,1990.890954623613)'> </g>
                 <g id='Border-04' transform='matrix(0.22804124,0,0,0.22804124,-2519.962039698354,1990.890954623613)'> </g>
                 <g id='Field-5-0' transform='matrix(0.22804124,0,0,0.22804124,-2537.699339698353,1966.990354623613)'> </g>
                 <g id='Trick-0-0' transform='matrix(0.22804124,0,0,0.22804124,-2537.699339698353,1966.990354623613)'> </g>
                 <g id='Border-7-5' transform='matrix(0.22804124,0,0,0.22804124,-2537.699339698353,1966.990354623613)'> </g>
                 <g id='Field-3-57' transform='matrix(0.22804124,0,0,0.22804124,-2537.733239698353,1990.174454623613)'> </g>
                 <g id='Border-5-03' transform='matrix(0.22804124,0,0,0.22804124,-2537.733239698353,1990.174454623613)'> </g>
                 <g id='use3104-8' transform='matrix(0.22804124,0,0,0.22804124,-2537.683339698353,1990.188354623614)'> </g>
                 <g id='Trick-4-6' transform='matrix(0.22804124,0,0,0.22804124,-2537.551339698353,1990.138054623613)'> </g>
                 <g id='Field-2-9' transform='matrix(0.22804124,0,0,0.22804124,-2537.699339698353,2013.358754623614)'> </g>
                 <g id='Trick-2-1' transform='matrix(0.22804124,0,0,0.22804124,-2537.699339698353,2013.358754623614)'> </g>
                 <g id='Border-1-0' transform='matrix(0.22804124,0,0,0.22804124,-2537.699339698353,2013.358754623614)'> </g>
                 <g id='Field-36-0' transform='matrix(0.22804124,0,0,0.22804124,-2537.699339698353,2036.542854623613)'> </g>
                 <g id='Trick-08-58' transform='matrix(0.22804124,0,0,0.22804124,-2537.699339698353,2036.542854623613)'> </g>
                 <g id='Border-8-5' transform='matrix(0.22804124,0,0,0.22804124,-2537.699339698353,2036.542854623613)'> </g>
                 <g id='Field-9-7' transform='matrix(0.22804124,0,0,0.22804124,-2537.699339698353,2059.727054623613)'> </g>
                 <g id='Trick-8-9' transform='matrix(0.22804124,0,0,0.22804124,-2537.699339698353,2059.727054623613)'> </g>
                 <g id='Border-4-6' transform='matrix(0.22804124,0,0,0.22804124,-2537.699339698353,2059.727054623613)'> </g>
                 <g id='Field-1-9' transform='matrix(0.22804124,0,0,0.22804124,-2519.639339698353,2057.756354623613)'> </g>
                 <g id='Trick-5-6' transform='matrix(0.22804124,0,0,0.22804124,-2519.639339698353,2057.756354623613)'> </g>
                 <g id='Border-9-28' transform='matrix(0.22804124,0,0,0.22804124,-2519.639339698353,2057.756354623613)'> </g>
                 <g id='Field-17-8' transform='matrix(0.22804124,0,0,0.22804124,-2518.994439698353,2035.468154623613)'> </g>
                 <g id='Trick-1-43' transform='matrix(0.22804124,0,0,0.22804124,-2518.994439698353,2035.468154623613)'> </g>
                 <g id='Border-99-2' transform='matrix(0.22804124,0,0,0.22804124,-2518.994439698353,2035.468154623613)'> </g>
                 <g id='Field-53-6' transform='matrix(0.22804124,0,0,0.22804124,-2558.339339698353,1991.895054623613)'> </g>
                 <g id='Trick-12-8' transform='matrix(0.22804124,0,0,0.22804124,-2558.339339698353,1991.895054623613)'> </g>
                 <g id='Border-12-2' transform='matrix(0.22804124,0,0,0.22804124,-2558.339339698353,1991.895054623613)'> </g>
                 <g id='Field-94-1' transform='matrix(0.22804124,0,0,0.22804124,-2518.026839698353,2013.144254623613)'> </g>
                 <g id='Trick-09-8' transform='matrix(0.22804124,0,0,0.22804124,-2518.026839698353,2013.144254623613)'> </g>
                 <g id='Border-51-3' transform='matrix(0.22804124,0,0,0.22804124,-2518.026839698353,2013.144254623613)'> </g>
                 <g id='Field-21-6' transform='matrix(0.22804124,0,0,0.22804124,-2535.441939698353,2084.345054623614)'> </g>
                 <g id='Trick-46-5' transform='matrix(0.22804124,0,0,0.22804124,-2535.441939698353,2084.345054623614)'> </g>
                 <g id='Border-0-0' transform='matrix(0.22804124,0,0,0.22804124,-2535.441939698353,2084.345054623614)'> </g>
                 <ellipse id='ellipse5679-0' fill='black' cx='1452.853' cy='1556.271' rx='0' ry='0'/>
                 <ellipse id='ellipse5683-1' fill='#FFFFFF' cx='1452.853' cy='1556.043' rx='0' ry='0'/>
                 <ellipse id='ellipse5749-7' fill='black' cx='1484.276' cy='1555.587' rx='0' ry='0'/>
                 <ellipse id='ellipse5753-0' fill='#FFFFFF' cx='1484.276' cy='1555.587' rx='0' ry='0'/>
                 <ellipse id='ellipse5819-6' fill='black' cx='1468.337' cy='1583.596' rx='0' ry='0'/>
                 <ellipse id='ellipse5823-7' fill='#FFFFFF' cx='1468.337' cy='1583.368' rx='0' ry='0'/>
                 <g id='Field-23-7' transform='matrix(0.22804124,0,0,0.22804124,-755.6530396983537,1904.727954623613)'> </g>
                 <g id='Trick-18-6' transform='matrix(0.22804124,0,0,0.22804124,-755.6530396983537,1904.727954623613)'> </g>
                 <g id='Border-74-7' transform='matrix(0.22804124,0,0,0.22804124,-755.6530396983537,1904.727954623613)'> </g>
                 <g id='Field-5-6-5' transform='matrix(0.22804124,0,0,0.22804124,-773.3902396983537,1880.827254623613)'> </g>
                 <g id='Trick-0-3-5' transform='matrix(0.22804124,0,0,0.22804124,-773.3902396983537,1880.827254623613)'> </g>
                 <g id='Border-7-8-3' transform='matrix(0.22804124,0,0,0.22804124,-773.3902396983537,1880.827254623613)'> </g>
                 <g id='Field-3-5-8' transform='matrix(0.22804124,0,0,0.22804124,-773.4242396983537,1904.011454623613)'> </g>
                 <g id='Border-5-0-6' transform='matrix(0.22804124,0,0,0.22804124,-773.4242396983537,1904.011454623613)'> </g>
                 <g id='use3104-1-4' transform='matrix(0.22804124,0,0,0.22804124,-773.3742396983534,1904.025254623613)'> </g>
                 <g id='Trick-4-2-2' transform='matrix(0.22804124,0,0,0.22804124,-773.2422396983538,1903.975054623613)'> </g>
                 <g id='Field-2-4-9' transform='matrix(0.22804124,0,0,0.22804124,-773.3902396983537,1927.195654623613)'> </g>
                 <g id='Trick-2-8-6' transform='matrix(0.22804124,0,0,0.22804124,-773.3902396983537,1927.195654623613)'> </g>
                 <g id='Border-1-5-9' transform='matrix(0.22804124,0,0,0.22804124,-773.3902396983537,1927.195654623613)'> </g>
                 <g id='Field-36-2-9' transform='matrix(0.22804124,0,0,0.22804124,-773.3902396983537,1950.379854623613)'> </g>
                 <g id='Trick-08-5-9' transform='matrix(0.22804124,0,0,0.22804124,-773.3902396983537,1950.379854623613)'> </g>
                 <g id='Border-8-2-2' transform='matrix(0.22804124,0,0,0.22804124,-773.3902396983537,1950.379854623613)'> </g>
                 <g id='Field-9-9-9' transform='matrix(0.22804124,0,0,0.22804124,-773.3902396983537,1973.564054623613)'> </g>
                 <g id='Trick-8-1-2' transform='matrix(0.22804124,0,0,0.22804124,-773.3902396983537,1973.564054623613)'> </g>
                 <g id='Border-4-3-0' transform='matrix(0.22804124,0,0,0.22804124,-773.3902396983537,1973.564054623613)'> </g>
                 <g id='Field-1-1-4' transform='matrix(0.22804124,0,0,0.22804124,-755.3303396983535,1971.593354623613)'> </g>
                 <g id='Trick-5-5-4' transform='matrix(0.22804124,0,0,0.22804124,-755.3303396983535,1971.593354623613)'> </g>
                 <g id='Border-9-2-8' transform='matrix(0.22804124,0,0,0.22804124,-755.3303396983535,1971.593354623613)'> </g>
                 <g id='Field-17-9-5' transform='matrix(0.22804124,0,0,0.22804124,-754.6853896983534,1949.305154623613)'> </g>
                 <g id='Trick-1-4-4' transform='matrix(0.22804124,0,0,0.22804124,-754.6853896983534,1949.305154623613)'> </g>
                 <g id='Border-99-4-5' transform='matrix(0.22804124,0,0,0.22804124,-754.6853896983534,1949.305154623613)'> </g>
                 <g id='Field-53-0-7' transform='matrix(0.22804124,0,0,0.22804124,-794.0302396983536,1905.732054623613)'> </g>
                 <g id='Trick-12-7-5' transform='matrix(0.22804124,0,0,0.22804124,-794.0302396983536,1905.732054623613)'> </g>
                 <g id='Border-12-4-2' transform='matrix(0.22804124,0,0,0.22804124,-794.0302396983536,1905.732054623613)'> </g>
                 <g id='Field-94-7-7' transform='matrix(0.22804124,0,0,0.22804124,-753.7178096983534,1926.981254623613)'> </g>
                 <g id='Trick-09-9-4' transform='matrix(0.22804124,0,0,0.22804124,-753.7178096983534,1926.981254623613)'> </g>
                 <g id='Border-51-0-2' transform='matrix(0.22804124,0,0,0.22804124,-753.7178096983534,1926.981254623613)'> </g>
                 <g id='Field-21-2-6' transform='matrix(0.22804124,0,0,0.22804124,-771.1328396983534,1998.182054623614)'> </g>
                 <g id='Trick-46-2-0' transform='matrix(0.22804124,0,0,0.22804124,-771.1328396983534,1998.182054623614)'> </g>
                 <g id='Border-0-6-9' transform='matrix(0.22804124,0,0,0.22804124,-771.1328396983534,1998.182054623614)'> </g>
                 <path id='path4156-2' fill='#FFFFFF' d='M0-4.5'/>
                 <g id='g4228' transform='translate(138.7720053711232,8.967595210688955)'>
                   <g id='g4223' transform='matrix(1.266344880121791,0,0,1.266344880121791,35.32188888810447,-75.78375396645282)'>
                     <path id='path3069' fill='black' stroke='#000000' stroke-width='2.369' d='M-0.552,216.819    c-0.012,35.623-28.9,64.491-64.522,64.479c-35.606-0.012-64.467-28.872-64.478-64.479c0-35.622,28.877-64.5,64.5-64.5    C-29.431,152.319-0.552,181.197-0.552,216.819z'/>
                     <path id='path3853' fill='black' stroke='#000000' stroke-width='2.369' d='M-64.493,54.683c-4.971,0-9,4.029-9,9    c0,2.892,1.38,5.447,3.5,7.094v28.906h-31.063c-1.646-2.12-4.202-3.5-7.094-3.5c-4.971,0-9,4.03-9,9c0,4.971,4.029,9,9,9    c2.892,0,5.448-1.38,7.094-3.5h31.063v55.719h11v-55.719h31.032c1.646,2.122,4.231,3.5,7.124,3.5c4.971,0,9-4.029,9-9    c0-4.97-4.029-9-9-9c-2.893,0-5.478,1.378-7.124,3.5h-31.032V70.776c2.119-1.647,3.5-4.202,3.5-7.094    C-55.493,58.712-59.522,54.683-64.493,54.683z'/>
                     <path id='path3071' fill='black' stroke='#000000' stroke-width='2.369' d='M-65.056,149.807c-4.659,0-9.202,0.501-13.593,1.406    v48.875c-19.18,1.011-37.12,4.153-52.937,8.938c-0.297,2.557-0.469,5.144-0.469,7.781c0,5.802,0.738,11.443,2.125,16.812    c19.123-5.596,41.268-8.812,64.875-8.812c23.605,0,45.752,3.216,64.875,8.812c1.388-5.372,2.125-11.007,2.125-16.812    c0-2.637-0.173-5.224-0.469-7.781c-15.817-4.785-33.757-7.927-52.937-8.938v-48.875    C-55.853,150.308-60.396,149.807-65.056,149.807z'/>
                   </g>
                 </g>
               </svg>
             </artwork>
                       <dl>
                         <dt>
                           <p>A</p>
                         </dt>
                         <dd>
                           <t>B</t>
                         </dd>
                       </dl>
                   <figure anchor='figure-B'>
                     <artwork anchor='BC' alt='hello' type='ascii-art'><![CDATA[A <
             B]]></artwork>
                   </figure>
                   <figure anchor='figure-C'>
                     <artwork type='ascii-art'><![CDATA[A <
             B]]></artwork>
                   </figure>
                 </abstract>
               </front>
               <middle/>
                <back>
                 <section>
                   <name>Endnotes</name>
                   <t anchor='_ef2c85b8-5a5a-4ecd-a1e6-92acefaaa852'>[a] The time $$ t_90 $$ was estimated to be 18,2 min for this example.</t>
                 </section>
               </back>
             </rfc>
    OUTPUT
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({})
      .cleanup(Nokogiri::XML(input)).to_s)).to be_equivalent_to xmlpp(output)
  end

  it "cleans up inline figures" do
    input = <<~INPUT
           #{XML_HDR}
          <t>
                     <artwork src='rice_images/rice_image1.png' title='titletxt 1' anchor='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' type='svg' alt='alttext'/>
                     <artwork src='rice_images/rice_image1.png' title='titletxt 2' anchor='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' type='svg' alt='alttext'/>
                   </t>
      </abstract></front><middle/><back/></rfc>
    INPUT
    output = <<~OUTPUT
      #{XML_HDR}
              <t> [IMAGE 1] [IMAGE 2] </t>
              <artwork src='rice_images/rice_image1.png' title='titletxt 1' anchor='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' type='svg' alt='alttext'/>
              <artwork src='rice_images/rice_image1.png' title='titletxt 2' anchor='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' type='svg' alt='alttext'/>
            </abstract>
          </front>
          <middle/>
          <back/>
        </rfc>
    OUTPUT
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({})
      .cleanup(Nokogiri::XML(input)).to_s)).to be_equivalent_to xmlpp(output)
  end

  it "cleans up sourcecode" do
    input = <<~INPUT
            #{XML_HDR}
                   <figure anchor='_'>
                     <name>Label</name>
                     <sourcecode>
                       <t anchor="_">&#xA0;&#xA0;<strong><em>A</em></strong><br/>
      &#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;B<br/>B1</t>
      <t anchor="_">&#xA0;&#xA0;<em>C &gt; E</em></t>
                     </sourcecode>
                   </figure>
                   <figure anchor='samplecode'>
                     <name>
                       Ruby
                       <em>code</em>
                     </name>
                   <sourcecode type='ruby'>
               puts x;
               puts y;
               puts z
             </sourcecode></figure>
      </abstract></front><middle/><back/></rfc>
    INPUT
    output = <<~OUTPUT
      #{XML_HDR}
                          <figure anchor="_">
                          <name>Label</name><sourcecode><![CDATA[  A
              B
      B1

        C  E]]></sourcecode></figure>
                          <figure anchor="samplecode">
                          <name>
                              Ruby
                              <em>code</em>
                            </name><sourcecode type="ruby"><![CDATA[         puts x;
               puts y;
               puts z
             ]]></sourcecode></figure>
             </abstract></front><middle/><back/></rfc>
    OUTPUT
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({})
      .cleanup(Nokogiri::XML(input)).to_s)).to be_equivalent_to xmlpp(output)
  end

  it "cleans up annotated bibliography" do
    input = <<~INPUT
      <rfc xmlns:xi='http://www.w3.org/2001/XInclude' xml:lang='en' version='3'>
         <front>
           <abstract>
             <t anchor='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f'>
               <xref target='ISO712'/>
               <xref target='ISBN'/>
               <xref target='ISSN'/>
               <xref target='ISO16634'/>
               <xref target='ref1'/>
               <xref target='ref10'/>
               <xref target='ref12'/>
             </t>
           </abstract>
         </front>
         <middle/>
         <back>
           <references anchor='_normative_references'>
             <name>Normative References</name>
             <reference anchor='ISO712'>
               <front>
                 <title>ISO 712, Cereals or cereal products</title>
               </front>
             </reference>
             <reference anchor='ISO16634'>
               <front>
                 <title>
                   ISO 16634:-- (all parts), Cereals, pulses, milled cereal products,
                   xxxx, oilseeds and animal feeding stuffs
                 </title>
                 <author>
                   <organization asciiName='International Supporters of Odium' abbrev='ISO1'>International Supporters of Odium</organization>
                 </author>
                 <keyword>keyword1</keyword>
                 <keyword>keyword2</keyword>
                 <abstract>
                   <t>This is an abstract</t>
                 </abstract>
               </front>
             </reference>
             <reference anchor='ISO20483'>
               <front>
                 <title>ISO 20483:2013-2014, Cereals and pulses</title>
                 <author fullname='&#xD6;laf N&#xFC;rk' asciiFullname='Olaf Nurk' surname='N&#xFC;rk' asciiSurname='Nurk'/>
                 <author>
                   <organization/>
                 </author>
                 <date year='2013'/>
               </front>
             </reference>
             <reference anchor='ref1'>
               <front>
                 <title>
                   ICC 167, Standard No I.C.C 167.
                   <em>
                     Determination of the protein content in cereal and cereal products
                     for food and animal feeding stuffs according to the Dumas
                     combustion method
                   </em>
                    (see
                   <eref target='http://www.icc.or.at'/>
                   )
                 </title>
               </front>
             </reference>
             <aside>
               <t>NOTE: This is an annotation of ISO 20483:2013-2014</t>
             </aside>
           </references>
           <references anchor='_bibliography'>
             <name>Bibliography</name>
             <reference anchor='ISBN'>
               <front>
                 <title>1, Chemicals for analytical laboratory use</title>
               </front>
             </reference>
             <reference anchor='ISSN'>
               <front>
                 <title>2, Instruments for analytical laboratory use</title>
               </front>
             </reference>
             <aside>
               <t>NOTE: This is an annotation of document ISSN.</t>
             </aside>
             <aside>
               <t>NOTE: This is another annotation of document ISSN.</t>
             </aside>
             <reference anchor='ISO3696'>
               <front>
                 <title>ISO 3696, Water for analytical laboratory use</title>
               </front>
             </reference>
             <reference anchor='ref10'>
               <front>
                 <title>
                   10, Standard No I.C.C 167.
                   <em>
                     Determination of the protein content in cereal and cereal products
                     for food and animal feeding stuffs according to the Dumas
                     combustion method
                   </em>
                    (see
                   <eref target='http://www.icc.or.at'/>
                   )
                 </title>
               </front>
             </reference>
             <xi:include href='https://xml2rfc.tools.ietf.org/10.xml'/>
             <reference anchor='ref12'>
               <front>
                 <title>
                   Citn, CitationWorks. 2019.
                   <em>How to cite a reference</em>
                   .
                 </title>
               </front>
             </reference>
           </references>
         </back>
       </rfc>
    INPUT
    output = <<~OUTPUT
      <rfc xmlns:xi="http://www.w3.org/2001/XInclude" xml:lang="en" version="3">
          <front>
            <abstract>
              <t anchor="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">
                <xref target="ISO712"/>
                <xref target="ISBN"/>
                <xref target="ISSN"/>
                <xref target="ISO16634"/>
                <xref target="ref1"/>
                <xref target="ref10"/>
                <xref target="ref12"/>
              </t>
            </abstract>
          </front>
          <middle/>
          <back>
            <references anchor="_normative_references">
              <name>Normative References</name>
              <reference anchor="ISO712">
                <front>
                  <title>ISO 712, Cereals or cereal products</title>
                 <author surname="Unknown"/>
                </front>
              </reference>
              <reference anchor="ISO16634">
                <front>
                  <title>
                    ISO 16634:-- (all parts), Cereals, pulses, milled cereal products,
                    xxxx, oilseeds and animal feeding stuffs
                  </title>
                  <author>
                    <organization asciiName="International Supporters of Odium" abbrev="ISO1">International Supporters of Odium</organization>
                  </author>
                  <keyword>keyword1</keyword>
                  <keyword>keyword2</keyword>
                  <abstract>
                    <t>This is an abstract</t>
                  </abstract>
                </front>
              </reference>
              <reference anchor="ISO20483">
                <front>
                  <title>ISO 20483:2013-2014, Cereals and pulses</title>
                  <author fullname="&#xD6;laf N&#xFC;rk" asciiFullname="Olaf Nurk" surname="N&#xFC;rk" asciiSurname="Nurk"/>
                  <author>
                    <organization/>
                  </author>
                  <date year="2013"/>
                </front>
              </reference>
              <reference anchor="ref1">
                <front>
                  <title>
                    ICC 167, Standard No I.C.C 167.
                      Determination of the protein content in cereal and cereal products
                      for food and animal feeding stuffs according to the Dumas
                      combustion method
                     (see
                    )
                  </title>
                 <author surname="Unknown"/>
                </front>
              <annotation>
                NOTE: This is an annotation of ISO 20483:2013-2014
              </annotation></reference>
            </references>
            <references anchor="_bibliography">
              <name>Bibliography</name>
              <reference anchor="ISBN">
                <front>
                  <title>1, Chemicals for analytical laboratory use</title>
                 <author surname="Unknown"/>
                </front>
              </reference>
              <reference anchor="ISSN">
                <front>
                  <title>2, Instruments for analytical laboratory use</title>
                 <author surname="Unknown"/>
                </front>
              <annotation>
                NOTE: This is an annotation of document ISSN.
              </annotation>
               <annotation>
              NOTE: This is another annotation of document ISSN.
                </annotation>
              </reference>
              <reference anchor="ISO3696">
                <front>
                  <title>ISO 3696, Water for analytical laboratory use</title>
                 <author surname="Unknown"/>
                </front>
              </reference>
              <reference anchor="ref10">
                <front>
                  <title>
                    10, Standard No I.C.C 167.
                      Determination of the protein content in cereal and cereal products
                      for food and animal feeding stuffs according to the Dumas
                      combustion method
                     (see
                    )
                  </title>
                 <author surname="Unknown"/>
                </front>
              </reference>
              <xi:include href="https://xml2rfc.tools.ietf.org/10.xml"/>
              <reference anchor="ref12">
                <front>
                  <title>
                    Citn, CitationWorks. 2019.
                    How to cite a reference
                    .
                  </title>
                 <author surname="Unknown"/>
                </front>
              </reference>
            </references>
          </back>
        </rfc>
    OUTPUT
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({})
      .cleanup(Nokogiri::XML(input)).to_s)).to be_equivalent_to xmlpp(output)
  end

  it "cleans up definition lists" do
    input = <<~INPUT
      <rfc xmlns:xi='http://www.w3.org/2001/XInclude' version='3'>
               <front>
                 <abstract>
                 <t id="id0"><bookmark anchor="id1"/>A</t>
                 <dl>
                 <dt><bookmark anchor="id1"/>A</dt>
                 <dd><t anchor="id2">B</t></dd>
                 <dt><t anchor="id3"><strong>C</strong></t><t anchor="id4">D</t></dt>
                 <dd><t anchor="id5">E</t></dd>
                 </dl>
                 </abstract>
               </front>
               <middle/>
               <back/>
             </rfc>
    INPUT
    output = <<~OUTPUT
      <rfc xmlns:xi='http://www.w3.org/2001/XInclude' version='3'>
        <front>
          <abstract>
          <t id='id0'>A</t>
            <dl>
              <dt anchor='id1'>A</dt>
              <dd>
                <t anchor='id2'>B</t>
              </dd>
              <dt anchor='id3'>
                <strong>C</strong>
                D
              </dt>
              <dd>
                <t anchor='id5'>E</t>
              </dd>
            </dl>
          </abstract>
        </front>
        <middle/>
        <back/>
      </rfc>
    OUTPUT
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({})
      .cleanup(Nokogiri::XML(input)).to_s)).to be_equivalent_to xmlpp(output)
  end

  it "reports parsing errors on RFC XML output" do
    FileUtils.rm_f "test.rfc.xml"
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword>
      <p>
      <passthrough>&lt;abc&gt;X &amp;gt; Y</passthrough>
      A
      <passthrough>&lt;/abc&gt;</passthrough>
      </p>
      </preface>
      </iso-standard>
    INPUT
    expect do
      IsoDoc::Ietf::RfcConvert.new({}).convert("test", input,
                                               false)
    end.to output(/RFC XML: Line/).to_stderr
  end

  it "inserts u tags to wrap unicode" do
    input = <<~INPUT
      <rfc xmlns:xi='http://www.w3.org/2001/XInclude' version='3'>
               <front>
                 <abstract>
                 <author>Hello Χello</author>
                 <t>Hello Χello</t>
                 </abstract>
               </front>
               <middle/>
               <back/>
             </rfc>
    INPUT
    output = <<~OUTPUT
      <rfc xmlns:xi='http://www.w3.org/2001/XInclude' version='3'>
      <front>
      <abstract>
      <author>
        Hello &#x3A7;ello
      </author>
      <t>
        Hello
        <u>&#x3A7;</u>
        ello
      </t>
      </abstract> </front> <middle/> <back/> </rfc>
    OUTPUT
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({})
      .cleanup(Nokogiri::XML(input)).to_s)).to be_equivalent_to xmlpp(output)
  end

  it "cleans up lists with single paragraphs" do
    input = <<~INPUT
      <rfc xmlns:xi='http://www.w3.org/2001/XInclude' version='3'>
               <front>
                 <abstract>
                 <ol>
                 <li><t>ABC</t></li>
                 <li><t>DEF</t><t>GHI</t></li>
                 <li><figure>A</figure></li>
                 <li>JKL</li>
                 </ol>
                 </abstract>
               </front>
               <middle/>
               <back/>
             </rfc>
    INPUT
    output = <<~OUTPUT
      <rfc xmlns:xi='http://www.w3.org/2001/XInclude' version='3'>
      <front>
      <abstract>
      <ol>
        <li>ABC</li>
        <li>
          <t>DEF</t>
          <t>GHI</t>
        </li>
        <li>
          <figure>A</figure>
        </li>
        <li>JKL</li>
      </ol>
      </abstract> </front> <middle/> <back/> </rfc>
    OUTPUT
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({})
      .cleanup(Nokogiri::XML(input)).to_s)).to be_equivalent_to xmlpp(output)
  end

  it "cleans up crefs" do
    input = <<~INPUT
           <rfc xmlns:xi='http://www.w3.org/2001/XInclude' category='std' submissionType='IETF' version='3'>
         <front>
           <seriesInfo value='' name='RFC' asciiName='RFC'/>
           <abstract>
             <t anchor='A'>A.</t>
             <t anchor='B'>B.</t>
             <cref anchor='_4f4dff63-23c1-4ecb-8ac6-d3ffba93c711' display='false' source='ISO'>
               Title 
               <t anchor='_c54b9549-369f-4f85-b5b2-9db3fd3d4c07'>
                 A Foreword shall appear in each document. The generic text is shown
                 here. It does not contain requirements, recommendations or
                 permissions.
               </t>
               <t anchor='_f1a8b9da-ca75-458b-96fa-d4af7328975e'>
                 For further information on the Foreword, see 
                 <strong>ISO/IEC Directives, Part 2, 2016, Clause 12.</strong>
               </t>
             </cref>
             <t anchor='C'>C.</t>
             <cref anchor='_4f4dff63-23c1-4ecb-8ac6-d3ffba93c712' source='ISO'>
               <t anchor='_c54b9549-369f-4f85-b5b2-9db3fd3d4c08'>Second note.</t>
             </cref>
           </abstract>
         </front>
         <middle>
           <section>
             <cref anchor='_4f4dff63-23c1-4ecb-8ac6-d3ffba93c712' source='ISO'>
               <t anchor='_c54b9549-369f-4f85-b5b2-9db3fd3d4c08'>Second note.</t>
             </cref>
           </section>
         </middle>
         <back/>
       </rfc>
    INPUT
    output = <<~OUTPUT
       <rfc xmlns:xi='http://www.w3.org/2001/XInclude' category='std' submissionType='IETF' version='3'>
         <front>
           <seriesInfo value='' name='RFC' asciiName='RFC'/>
           <abstract>
             <t anchor='A'>A.</t>
             <t anchor='B'>B.</t>
             <t>
             <cref anchor='_4f4dff63-23c1-4ecb-8ac6-d3ffba93c711' display='false' source='ISO'>
                Title A Foreword shall appear in each document. The generic text is
               shown here. It does not contain requirements, recommendations or
               permissions. For further information on the Foreword, see 
               <strong>ISO/IEC Directives, Part 2, 2016, Clause 12.</strong>
             </cref>
             </t>
             <t anchor='C'>C.</t>
             <t>
             <cref anchor='_4f4dff63-23c1-4ecb-8ac6-d3ffba93c712' source='ISO'> Second note. </cref>
             </t>
           </abstract>
         </front>
         <middle>
           <section>
           <t>
             <cref anchor='_4f4dff63-23c1-4ecb-8ac6-d3ffba93c712' source='ISO'> Second note. </cref>
             </t>
           </section>
         </middle>
         <back/>
       </rfc>
    OUTPUT
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({})
      .cleanup(Nokogiri::XML(input)).to_s)).to be_equivalent_to xmlpp(output)
  end

end
