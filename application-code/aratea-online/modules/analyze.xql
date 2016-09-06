xquery version "3.0";

module namespace analyze = "http://www.digital-archiv/ns/aratea/analyze";

import module namespace kwic = "http://exist-db.org/xquery/kwic" at "resource:org/exist/xquery/lib/kwic.xql";

import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";
import module namespace config="http://www.digital-archiv.at/app/aratea-online/config" at "config.xqm";
import module namespace app="http://www.digital-archiv.at/app/aratea-online/templates" at "app.xql";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $analyze:search-expression as xs:string := request:get-parameter("searchexpr", "");

(:~
 : return searchexpression
 :)
 declare function analyze:return_searchexpression($node as node(), $model as map (*)) {
 <span>{$analyze:search-expression}</span>
};

(:~
 : a fulltext-search function
 :)
 declare function analyze:ft_search($node as node(), $model as map (*)) {
 if ($analyze:search-expression !="") then
 let $searchterm as xs:string:= request:get-parameter("searchexpr", "")
 for $hit in collection(concat($config:app-root, '/data/'))//tei:p[ft:query(.,$searchterm)]
    let $document := document-uri(root($hit))
    let $score as xs:float := ft:score($hit)
    order by $score descending
    return
    <tr>
        <td>{$score}</td>
        <td>{kwic:summarize($hit, <config width="40" link="{app:href($document)}" />)}</td>
        <td>{$document}</td>
    </tr>
 else
    <div>Nothing to search for</div>
 };
