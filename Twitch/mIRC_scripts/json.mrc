/*
	$json
	Written by Timi
	http://timscripts.com/

	JSON, JavaScript Object Notation, is a popular format by which data is read and written.
	Many sites and APIs, such as Google's AJAX APIs, use this format, as it easy to parse and
	is widely supported.

	This snippet can read any value from valid JSON. It uses the MSScriptControl.ScriptControl object
	to input the data where is can be parsed using JavaScript. Calls are made to this object to
	retrieve the needed value.

	This script identifier also has the ability to get JSON data from a http://siteaddress.com
	source. This can be done by specifying a URL beginning with http://. Files on your computer can
	also be used. With URLs, the data will also be cached so multiple calls to the same data won't
	require getting the data over again. The cache will be cleared every 5 mins, but it can be cleared
	manually using /jsonclearcache. The URL must be encoded or else the query may not be completed correctly.

	Also included are two identifiers used for encoding URLs. One is for encoding an entire URL, and the other
	is used for encoding a specific component of a url.

	Syntax:
		$json(<valid JSON, file, or URL>,name/index,name/index2,...,name/indexN)[.count]
		Note: When inputting JSON, it is recommended that a variable is used because JSON uses commas
		to separate values. Also, URLs must begin with http://

		/clearjsoncache [URL]
		Clears the JSON cache created when JSON is retrieved from URLs
		If a URL is specified, the cache for that URL will be cleared.

		$json.enc(<URL>)
		Encodes a URL. Uses JavaScript's encodeURI().

		$json.enccomponent(<URL Component>)
		Encodes a URL component.

	Examples:
		var %json = {"mydata":"myvalue","mynumbers":[1,2,3,5],"mystuff":{"otherdata":{"2":"4","6":"blah"}}}

		$json(%json,mydata) == myvalue
		$json(%json,mynumbers,2) == 3 ;the array is indexed from 0
		$json(%json,mystuff,otherdata,"6") == blah      ;if a name is a number, quotes must be used as to not confuse
									;it with an array.

		http://site.com/?component= $+ $json.enccomponent(&)
		In the example, & is encoded because & usually separates other components. $json.enc would not
		encode this.
		----------
		Google Web Search example at end.


*/

alias json {
  if ($isid) {
    ;name of the com interface declared so I don't have to type it over and over again :D
    var %c = jsonidentifier,%x = 2,%str,%p,%v,%addr

    ;filter out some characters in $1 (address)
    if ($isfile($1)) { %addr = $qt($replace($1,\,\\,;,\u003b,",\u0022)) }
    else { %addr = $qt($replace($1,;,\u003b,",\u0022)) }

    ;if the interface hasnt been open and initialized, do it.
    json.comcheck
    if (!$timer(jsonclearcache)) { .timerjsonclearcache -o 0 60 jsonclearcache }

    ;get the list of parameters
    while (%x <= $0) {
      %p = $($+($,%x),2)
      if (%p == $null) { noop }
      elseif (%p isnum || $qt($noqt(%p)) == %p) { %str = $+(%str,[,%p,]) }
      else { %str = $+(%str,[",%p,"]) }
      inc %x
    }
    if ($prop == count) { %str = %str $+ .length }

    ;check to see if source is file
    if ($isfile($1)) {
      if ($com(%c,eval,1,bstr,$+(str2json,$chr(40),filejson,$chr(40),%addr,$chr(41),$chr(41),%str))) { return $com(%c).result }
    }
    ;check to see if source is url
    elseif (http://* iswm $1 || https://* iswm $1) {
      ;if url is in cache, used cached data
      if ($com(%c,eval,1,bstr,$+(str2json,$chr(40),urlcache[,%addr,],$chr(41),%str))) { return $com(%c).result }
      ;otherwise, get data
      elseif ($com(%c,eval,1,bstr,$+(urlcache[,%addr,]) = $+(httpjson,$chr(40),$qt($1),$chr(41)))) {
        if ($com(%c,eval,1,bstr,$+(str2json,$chr(40),urlcache[,%addr,],$chr(41),%str))) { return $com(%c).result }
      }
    }
    ;get data from inputted json
    elseif ($com(%c,eval,1,bstr,$+(x=,%addr,;,x,%str,;))) { return $com(%c).result }
  }
}
alias jsonclearcache {
  if ($com(jsonidentifier)) {
    if (!$1) { noop $com(jsonidentifier,executestatement,1,bstr,urlcache = {}) }
    else { echo -a $com(jsonidentifier,executestatement,1,bstr,urlcache[" $+ $1 $+ "] = "") }
  }
}
alias json.enc {
  json.comcheck
  if ($com(jsonidentifier,eval,1,bstr,encodeURI(" $+ $1- $+ "))) { return $com(jsonidentifier).result }
}
alias json.enccomponent {
  json.comcheck
  if ($com(jsonidentifier,eval,1,bstr,encodeURIComponent(" $+ $1- $+ "))) { return $com(jsonidentifier).result }
}
alias -l json.comcheck {
  var %c = jsonidentifier
  if (!$com(%c)) {
    .comopen %c MSScriptControl.ScriptControl
    ;add two javascript functions for getting json from urls and files
    noop $com(%c,language,4,bstr,jscript) $com(%c,addcode,1,bstr,function httpjson(url) $({,0) y=new ActiveXObject("Microsoft.XMLHTTP");y.open("GET",url,false);y.send();return y.responseText; $(},0))
    noop $com(%c,addcode,1,bstr,function filejson (file) $({,0) x = new ActiveXObject("Scripting.FileSystemObject"); txt1 = x.OpenTextFile(file,1); txt2 = txt1.ReadAll(); txt1.Close(); return txt2; $(},0))
    ;add function to securely evaluate json
    noop $com(%c,addcode,1,bstr,function str2json (json) $({,0) return !(/[^,:{}\[\]0-9.\-+Eaeflnr-u \n\r\t]/.test(json.replace(/"(\\.|[^"\\])*"/g, ''))) && eval('(' + json + ')'); $(},0))
    ;add a cache for urls
    noop $com(%c,addcode,1,bstr,urlcache = {})
  }
}
