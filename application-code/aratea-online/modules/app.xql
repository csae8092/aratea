xquery version "3.0";

module namespace app="http://www.digital-archiv.at/app/aratea-online/templates";
import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";
import module namespace config="http://www.digital-archiv.at/app/aratea-online/config" at "config.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace functx = "http://www.functx.com";

declare variable $app:pathToView := concat("http://",request:get-server-name(),":",request:get-server-port(), request:get-effective-uri());
declare variable $app:collection := replace($app:pathToView, "modules/view.xql", "");
declare variable $app:data := replace(concat($app:collection, "data/"), "http://digital-archiv.at:8081/exist/rest", "");
declare variable $app:editions := replace(concat($app:collection, "data/editions"), "http://digital-archiv.at:8081/exist/rest", "");
declare variable $app:descriptions := replace(concat($app:collection, "data/descriptions"), "http://digital-archiv.at:8081/exist/rest", "");
declare variable $app:uri := request:get-effective-uri();
declare variable $app:pathToShow := concat(replace($app:collection, "rest/db/", ""), "pages/show.html");
declare variable $app:restBaseHardcoded := "http://127.0.0.1:8080/exist/rest/db/apps/aratea-online/";

(:
$app:pathToView http://127.0.0.1:8080/exist/rest/db/apps/aratea-online/modules/view.xql
$app:collection http://127.0.0.1:8080/exist/rest/db/apps/aratea-online/
$app:data http://127.0.0.1:8080/exist/rest/db/apps/aratea-online/data/
$app:uri /exist/rest/db/apps/aratea-online/modules/view.xql
$app:pathToShow http://127.0.0.1:8080/exist/apps/aratea-online/pages/show.html
$app:restBaseHardcoded http://127.0.0.1:8080/exist/rest/db/apps/aratea-online/
$config:app-root /db/apps/aratea-online
:)
(:~
 : see http://www.xqueryfunctions.com/xq/functx_substring-after-last.html
 :)
declare function functx:substring-after-last
  ( $arg as xs:string? ,
    $delim as xs:string )  as xs:string {
   replace ($arg,concat('^.*',$delim),'')
 } ;
 
 (:~
 : a helper function to check the values of the registered variables
 :)
 declare function app:returnVariables ($node as node(), $model as map (*), $query as xs:string?) {
 <ol>
    <li>$app:pathToView {$app:pathToView}</li>
    <li>$app:collection {$app:collection}</li>
    <li>$app:data {$app:data}</li>
    <li>$app:uri {$app:uri}</li>
    <li>$app:pathToShow {$app:pathToShow}</li>
     <li>$app:restBaseHardcoded {$app:restBaseHardcoded}</li>
     <li>$config:app-root {$config:app-root}</li>
</ol>
};

(:~
 : fetches the name of the document of a xml-node and the collection it is stored
 :)
  declare function app:href ($document_name as xs:string?) {
 let $parts := (tokenize($document_name, "/"))
 let $directory := $parts[(count($parts)-1)]
 let $filename := $parts[count($parts)]
 let $uri:= concat($app:pathToShow,"?document=",$filename, "&amp;directory=",$directory)

 return
$uri
};

(:~
 : Creates a <a href> link to show.html to render the surrounded document in html 
 :)
  declare function app:linkToShowHTML ($document_name as xs:string?) {
 let $parts := (tokenize($document_name, "/"))
 let $directory := $parts[(count($parts)-1)]
 let $filename := $parts[count($parts)]
 let $uri:= concat($app:pathToShow,"?document=",$filename, "&amp;directory=",$directory)

 return
<a href="{$uri}">
    <span class="fa fa-hand-o-right fa-lg"></span>
    <span class="fa fa-file-text-o fa-lg"></span>
    {$filename}
</a> 
};

(:~
 : Transforms an xml-document to an html-snippet using an xslt-stylesheet.
 : http://digital-archiv.at:8081/exist/apps/aratea-online/pages/show.html?document=HAB_Gud_lat_132.xml&directory=descriptions&stylesheet=hab_xslt.xsl
 :)
declare function app:XMLtoHTML ($node as node(), $model as map (*), $query as xs:string?) {
let $ref := xs:string(request:get-parameter("document", ""))
let $directory := xs:string(request:get-parameter("directory", "editions"))
let $stylesheet := xs:string(request:get-parameter("stylesheet", "xmlToHtml.xsl"))
return
if ($ref ="")
    then <div><h3 style="text-align:center">Bitte wählen Sie ein Dokument aus!</h3></div>
    else
let $doc := concat($app:collection,"data/",$directory,"/",$ref)
let $xml := doc($doc)
let $xsl := doc(concat($app:collection,"resources/xslt/",$stylesheet))
let $params := 
<parameters>
   {for $p in request:get-parameter-names()
    let $val := request:get-parameter($p,())
    where  not($p = ("document","directory","stylesheet"))
    return
       <param name="{$p}"  value="{$val}"/>
   }
</parameters>
     return
    if (not(exists($xml))) then
        <div>
            <h3 style="text-align:center">Sorry, the choosen xml-document <strong>{$directory}/{$ref}</strong><br/>does not exist.</h3>
        </div>
    else if (not(exists($xsl))) then
     <div>
            <h3 style="text-align:center">Sorry, the choosen xsl-stylesheet <strong>{$stylesheet}</strong><br/>does not exist.</h3>
     </div>
     else
        transform:transform($xml, $xsl, $params)
};

(:~
 : Extracts basic metadata from a collection xml-tei document (manuscript descriptions) and renders it as cells in a table row.
 :)
declare function app:tocMsDesc ($node as node(), $model as map (*), $query as xs:string?) {
for $msDesc in collection(concat($config:app-root, '/data/descriptions/'))//tei:msDesc
    let $shelfmark :=  $msDesc//tei:msIdentifier/*[text()]
    let $msItem := $msDesc/tei:msContents/tei:msItem
    let $uri := document-uri(root($msDesc))
    let $filename := functx:substring-after-last($uri, "/")
    let $directory := "editions/"
    
    return
    <tr style="font-size:small">
        <td>{for $x in $shelfmark return <abbr title="{name($x)}">{$x} | </abbr>} <br/>
        {app:linkToShowHTML($uri)}
        </td>
        <td>               
        {for $x in $msItem return 
        <div clas="panel panel-default">
            <div class="panel panel-body">
            <table class="table table-boardered table-hover">
                {for $y in $x/*[child::text()] 
                    return
                        <tr>
                            <th>{name($y)}</th>
                            <td>{$y}</td>
                        </tr>
             }</table>
             </div>
         </div>}
        </td>
        <td><a href="{concat($app:pathToShow,"?directory=descriptions&amp;document=",$filename)}">{$filename}</a></td>
    </tr>    
};


 
(:~
 : Extracts basic metadata from a collection xml-tei document (digital editions) and renders it as cells in a table row.
 :)
declare function app:toc ($node as node(), $model as map (*), $query as xs:string?) {
 
for $header in collection(concat($config:app-root, '/data/editions/'))//tei:teiHeader
    let $repository := $header//tei:msIdentifier//tei:repository/text()
    let $settlement := $header//tei:msIdentifier//tei:settlement/text()
    let $collection := if ( exists($header//tei:msIdentifier//tei:collection)) 
        then $header//tei:msIdentifier//tei:collection
        else "--"
    let $shelfmark :=  $header//tei:msIdentifier/*[text()]
    let $idno := $header//tei:msIdentifier//tei:idno
    let $title :=  $header//tei:msDesc/tei:head/tei:title/text()
    let $authors := $header//tei:msContents/tei:msItem//tei:author
    let $works := $header//tei:msContents/tei:msItem//tei:title
    let $origPlace := $header//tei:sourceDesc//tei:head/tei:origPlace
    let $prov := $header//tei:msDesc/tei:history/tei:provenance/tei:p/tei:rs
    let $century := $header//tei:msDesc/tei:head/tei:origDate
    let $uri := document-uri(root($header))
    let $filename := functx:substring-after-last($uri, "/")
    let $directory := "editions/"
    return
<tr style="font-size:small">
        <td>{for $x in $shelfmark return <abbr title="{name($x)}">{$x} | </abbr>} <br/>
        {app:linkToShowHTML($uri)}
        </td>
        <td>{$title}</td>
        <td>{for $author in $authors return <small>{$author/text()} <br/></small>}</td>
        <td>{for $work in $works return <small>{$work/text()} <br/></small>}</td>
        <td>{$origPlace}</td>
        <td>{$prov}</td>
        <td>{$century}</td>
        <td>{$filename}<br/><a href="{concat($app:collection,"data/", $directory,$filename)}"><i class="fa fa-download fa-lg"></i></a></td>
</tr>
};

(:
        <a href="{concat($app:pathToShow,"?document=",$filename)}"><span class="fa fa-hand-o-right fa-lg"></span>
        <span class="fa fa-file-text-o fa-lg"></span></a> 
http://digital-archiv.at:8081/exist/rest/db/apps/aratea-online/pages/show.html?document=AL_Paris_7887.xml shows a blank page
http://digital-archiv.at:8081/exist/apps/aratea-online/pages/show.html?document=AL_Paris_7886.xml&directory=editions
:)

(:~
 : This is a sample templating function. It will be called by the templating module if
 : it encounters an HTML element with an attribute data-template="app:test" 
 : or class="app:test" (deprecated). The function has to take at least 2 default
 : parameters. Additional parameters will be mapped to matching request or session parameters.
 : 
 : @param $node the HTML node with the attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
declare function app:test($node as node(), $model as map(*)) {
    <p>Dummy template output generated by function app:test at {current-dateTime()}. The templating
        function was triggered by the class attribute <code>class="app:test"</code>.</p>
};