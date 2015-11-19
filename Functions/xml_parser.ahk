/*xmldata =
(
<?xml version="1.0" encoding="utf-8" ?>
<Messages>
<Message id = "1" timestamp="11/11/2015 03:43:13.000000" length="193" message="5.0OD0315RNCHARLES TOWN                  54632TWN9704TWN 010191080111LLLLLLLLLLL0214LLLLLLLLLLLLLL0311LLLLLLLLLLL0413LLLLLLLLLLLLL0511LLLLLLLLLLL0608LLLLLLLL0708LLLLLLLL0813LLLLLLLLLLLLL11882"/>
<Message id = "2" timestamp="11/11/2015 03:43:13.000000" length="193" message="5.0OD0315RNCHARLES TOWN                  54632TWN9704TWN 010191080111LLLLLLLLLLL0214LLLLLLLLLLLLLL0311LLLLLLLLLLL0413LLLLLLLLLLLLL0511LLLLLLLLLLL0608LLLLLLLL0708LLLLLLLL0813LLLLLLLLLLLLL11882"/>
<Message id = "3" timestamp="11/11/2015 03:43:13.000000" length="170" message="5.0OD0315RNFINGER LAKES                  32345FIM0017FIM 010168090106LLLLLL0205LLLLL0306LLLLLL0407LLLLLLL0509LLLLLLLLL0607LLLLLLL0707LLLLLLL0806LLLLLL0909LLLLLLLLL09959"/>
<Message id = "4" timestamp="11/11/2015 03:43:13.000000" length="170" message="5.0OD0315RNFINGER LAKES                  32345FIM0017FIM 010168090106LLLLLL0205LLLLL0306LLLLLL0407LLLLLLL0509LLLLLLLLL0607LLLLLLL0707LLLLLLL0806LLLLLL0909LLLLLLLLL09959"/>
<Message id = "5" timestamp="11/11/2015 03:43:13.000000" length="170" message="5.0OD0315RNFINGER LAKES                  32345FIM0017FIM 010168090106LLLLLL0205LLLLL0306LLLLLL0407LLLLLLL0509LLLLLLLLL0607LLLLLLL0707LLLLLLL0806LLLLLL0909LLLLLLLLL09959"/>
<Message id = "6" timestamp="11/11/2015 03:43:13.000000" length="170" message="5.0OD0315RNFINGER LAKES                  32345FIM0017FIM 010168090106LLLLLL0205LLLLL0306LLLLLL0407LLLLLLL0509LLLLLLLLL0607LLLLLLL0707LLLLLLL0806LLLLLL0909LLLLLLLLL09959"/>
<Message id = "7" timestamp="11/11/2015 03:43:13.000000" length="175" message="5.0OD0315RNHAWTHORNE RACECOURSE          97979HAD3587HAD 010173080108LLLLLLLL0207LLLLLLL0306LLLLLL0409LLLLLLLLL0507LLLLLLL0611LLLLLLLLLLL0711LLLLLLLLLLL0812LLLLLLLLLLLL10797"/>
<Message id = "8" timestamp="11/11/2015 03:43:13.000000" length="200" message="5.0OD0315RNMAHONING VALLEY               44534MVD0425MVD 010198090108LLLLLLLL0210LLLLLLLLLL0310LLLLLLLLLL0410LLLLLLLLLL0508LLLLLLLL0610LLLLLLLLLL0712LLLLLLLLLLLL0812LLLLLLLLLLLL0912LLLLLLLLLLLL12384"/>
<Message id = "9" timestamp="11/11/2015 03:43:13.000000" length="177" message="5.0OD0315RNPENN NATIONAL RACE COURSE     24378PEN8097PEN 010175080108LLLLLLLL0211LLLLLLLLLLL0307LLLLLLL0412LLLLLLLLLLLL0509LLLLLLLLL0610LLLLLLLLLL0707LLLLLLL0809LLLLLLLLL11100"/>
<Message id = "10" timestamp="11/11/2015 03:43:13.000000" length="175" message="5.0OD0315RNHAWTHORNE RACECOURSE          97979HAD3587HAD 010173080108LLLLLLLL0207LLLLLLL0306LLLLLL0409LLLLLLLLL0507LLLLLLL0611LLLLLLLLLLL0711LLLLLLLLLLL0812LLLLLLLLLLLL10797"/>
<Message id = "11" timestamp="11/11/2015 03:43:13.000000" length="175" message="5.0OD0315RNHAWTHORNE RACECOURSE          97979HAD3587HAD 010173080108LLLLLLLL0207LLLLLLL0306LLLLLL0409LLLLLLLLL0507LLLLLLL0611LLLLLLLLLLL0711LLLLLLLLLLL0812LLLLLLLLLLLL10797"/>
<Message id = "12" timestamp="11/11/2015 03:43:13.000000" length="175" message="5.0OD0315RNHAWTHORNE RACECOURSE          97979HAD3587HAD 010173080108LLLLLLLL0207LLLLLLL0306LLLLLL0409LLLLLLLLL0507LLLLLLL0611LLLLLLLLLLL0711LLLLLLLLLLL0812LLLLLLLLLLLL10797"/>
  

  <?xml version="1.0"?>
    <compactdiscs>
      <compactdisc>
        <artist type="individual">Frank Sinatra</artist>
        <title numberoftracks="4">In The Wee Small Hours</title>
        <tracks>
          <track>In The Wee Small Hours</track>
          <track>Mood Indigo</track>
          <track>Glad To Be Unhappy</track>
          <track>I Get Along Without You Very Well</track>
        </tracks>
        <price>$12.99</price>
      </compactdisc>
      <compactdisc>
        <artist type="band">The Offspring</artist>
        <title numberoftracks="5">Americana</title>
        <tracks>
          <track>Welcome</track>
          <track>Have You Ever</track>
          <track>Staring At The Sun</track>
          <track>Pretty Fly (For A White Guy)</track>
        </tracks>
        <price>$12.99</price>
      </compactdisc>
    </compactdiscs>
)

doc := loadXML(xmldata)

; XPath
msgbox % doc.selectSingleNode("/compactdiscs/compactdisc[artist=""Frank Sinatra""]/title").text

; Manually retrieving nodes and values
msgbox % DisplayNode(doc.childNodes)
*/


DisplayNode(nodes, indent=0)
{
  for node in nodes
  {
    if node.nodeName != "#text"
      text .= spaces(indent) node.nodeName ": " node.nodeValue "`n"
    else
      text .= spaces(indent) node.nodeValue "`n"
    if node.hasChildNodes
      text .= DisplayNode(node.childNodes, indent+2)
  }
  return text
}

spaces(n)
{
  Loop, %n%
    t .= " "
  return t
}

loadXML(ByRef data)
{
  o := ComObjCreate("MSXML2.DOMDocument.6.0")
  o.async := false
  o.loadXML(data)
  return o
}