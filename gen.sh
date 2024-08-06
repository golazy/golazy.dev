#!/bin/bash 


FILE=index.html

REPOS="autocerts flattenfs golazy layerfs lazyapp lazyassets lazycontroller lazydispatch lazyhttp lazyml lazysupport lazyview memfs multihttp protocolmux router"


for repo in $REPOS; do
	FILE=$repo.html

	cat > $FILE <<-EOF
	<!DOCTYPE html>
	<html lang=en>
	  <head>
	    <title>GoLazy</title>
	       <meta name=go-import content="golazy.dev/$repo git https://github.com/golazy/$repo.git">
	       <meta name=go-source content="golazy.dev/$repo https://github.com/golazy/$repo https://github.com/golazy/$repo/tree/master{/dir} https://github.com/golazy/$repo/blob/master{/dir}/{file}#L{line}">
	    <style>
	      html {
		max-width: 70ch;
		padding: 3em 1em;
		margin: auto;
		line-height: 1.75;
		font-size: 1.25em;
	      }
	    </style>
	  <body>
	    <h1>golazy.dev/$repo</h1>
	    <a href="https://github.com/golazy/$repo">Golazy $repo</a>
	    

	EOF
done
