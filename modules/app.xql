xquery version "3.0";

module namespace app="http://localhost:8080/exist/apps/manuscripta.se/templates";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://localhost:8080/exist/apps/manuscripta.se/config" at "config.xqm";
import module namespace kwic="http://exist-db.org/xquery/kwic" at "resource:org/exist/xquery/lib/kwic.xql";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare function app:list_authors($node as node(), $model as map(*)) { 
        <table class="table table-striped">
        <tr>
            <th>Author</th>
            <th>Work</th>
            <th>Shelfmark</th>
            <th>Locus</th>
        </tr>{
            for $mss in collection("/db/apps/manuscripta.se/data/xml"), 
                $msitem in $mss//tei:msContents/tei:msItem, 
                $author in $msitem/tei:author,
                $title in $msitem/tei:title[not(@type="alt")],
                $locus in $msitem/tei:locus,
                $idno in $mss//tei:msIdentifier/tei:idno
            order by $author ascending 
            return
                <tr>
                    <td>{$author}</td>
                    <td><em>{$title//text()}</em></td>
                    <td>{$idno/text()}</td>
                    <td><a href="data/xml/{replace(base-uri($mss), '.+/(.+)$', '$1')}">f. {data($locus/@from)}–{data($locus/@to)}</a></td>
                </tr>
        }
        </table>
};

declare function app:list_incipit($node as node(), $model as map(*)) { 
        <table class="table table-striped">
        <tr>
            <th>Incipit</th>            
            <th>Shelfmark</th>
            <th>Locus</th>
        </tr>{
            for $mss in collection("/db/apps/manuscripta.se/data/xml"), 
                $msitem in $mss//tei:msContents/tei:msItem, 
                $incipit in $msitem/tei:incipit, 
                $locus in $msitem/tei:locus,
                $idno in $mss//tei:msIdentifier/tei:idno
            order by $incipit ascending collation "?lang=el" 
            return
                <tr>
                    <td>{$incipit//text()}</td>
                    <td>{$idno/text()}</td>
                    <td><a href="data/xml/{replace(base-uri($mss), '.+/(.+)$', '$1')}">f. {data($locus/@from)}</a></td>
                </tr>
        }
        </table>
};

declare function app:list_mss($node as node(), $model as map(*)) { 
    <table class="table table-striped">
        <tr>
            <th>Shelfmark</th>
            <th>Date</th>
            <th>Support</th>
            <th>Contents</th>
        </tr>{
        for $mss in collection("/db/apps/manuscripta.se/data/xml")
        for $material in $mss//tei:supportDesc
        for $date in $mss//tei:origin//tei:origDate
        for $idno in $mss//tei:msIdentifier/tei:idno
        for $contents in $mss//tei:msContents/tei:summary
        order by $mss//tei:msDesc/@xml:id
        return
            <tr>
                <td><a href="data/xml/{replace(base-uri($mss), '.+/(.+)$', '$1')}">{$idno/text()}</a></td>
                <td>{$date/text()}</td>
                <td>{data($material/@material)}</td>
                <td>{$contents/text()}</td>
            </tr>
        }
        </table>
};

declare function app:list_scribes($node as node(), $model as map(*)) { 
        <table class="table table-striped">
        <tr>
            <th>Scribe</th>            
            <th>Shelfmark</th>
            <th>Locus</th>
        </tr>{
            for $mss in collection("/db/apps/manuscripta.se/data/xml") 
            for $scribe in $mss//tei:handNote//tei:persName[@role="scribe"]
            (:for $locus in $scribe//tei:locus:)
            for $idno in $mss//tei:msIdentifier/tei:idno
            order by $scribe ascending
            return
                <tr>
                    <td>{$scribe}</td>
                    <td><a href="data/xml/{replace(base-uri($mss), '.+/(.+)$', '$1')}">{$idno}</a></td>
                </tr>
        }
        </table>
};


(:declare function app:list_works($node as node(), $model as map(*)) { 
        <ul class="list-unstyled">{
            for $mss in collection("/db/apps/manuscripta/data/xml"), 
                $msitem in $mss//tei:msContents/tei:msItem, 
                $title in $msitem/tei:title[@type="uniform"],
                $locus in $msitem/tei:locus,
                $idno in $mss//tei:msIdentifier/tei:idno
            order by $title ascending 
            return
                <li>{$title//text()} (<a href="data/xml/{replace(base-uri($mss), '.+/(.+)$', '$1')}">{$idno/text()}: f. {data($locus/@from)}</a>)</li>
        }
        </ul>
};:)


declare function app:search($node as node(), $model as map(*), $au as xs:string?, $ti as xs:string?) {
    <table class="table table-striped">
        <tr>
            <th>Author</th>
            <th>Work</th>            
            <th>Shelfmark</th>
            <th>Locus</th>
        </tr>{
        for $mss in collection("/db/apps/manuscripta.se/data/xml")
        for $msitem in $mss//tei:msContents/tei:msItem
        for $title in $msitem/tei:title
        for $locus in $msitem/tei:locus
        for $idno in $mss//tei:msIdentifier/tei:idno
        return
            if (exists($au) and $au !='') then
                for $author in $msitem/tei:author[ft:query(., $au)] 
                order by $author ascending 
                return
                    <tr>
                        <td>{$author}</td>
                        <td><em>{$title//text()}</em></td>
                        <td>{$idno/text()}</td>
                        <td><a href="data/xml/{replace(base-uri($mss), '.+/(.+)$', '$1')}">f. {data($locus/@from)}–{data($locus/@to)}</a></td>
                    </tr>               
            else if (exists($ti) and $ti !='') then          
                for $title in $msitem//tei:title[ft:query(., $ti)] 
                order by $title ascending 
                return
                    <li>{$title} (<a href="data/xml/{replace(base-uri($mss), '.+/(.+)$', '$1')}">{$idno/text()}: f. {data($locus/@from)}</a>)</li>
            else
                ()
        }
    </table>
};