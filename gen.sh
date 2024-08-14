#!/bin/bash

REPOS="autocerts flattenfs lazycontext lazyservice layerfs lazyapp lazyassets lazycontroller lazydispatch lazyhttp lazyml lazysupport lazyview memfs multihttp protocolmux router"

read -d '' HTMLHEAD <<'EOF'
	<!DOCTYPE html>
	<html lang=en>
	  <head>
	    <link rel="stylesheet" href="bulma.css" >
EOF

for repo in $REPOS; do
  FILE=$repo.html

  cat >$FILE <<-EOF
$HTMLHEAD
       <title>GoLazy</title>
       <meta name=go-import content="golazy.dev/$repo git https://github.com/golazy/$repo.git">
       <meta name=go-source content="golazy.dev/$repo https://github.com/golazy/$repo https://github.com/golazy/$repo/tree/master{/dir} https://github.com/golazy/$repo/blob/master{/dir}/{file}#L{line}">
	  <body>
	    <h1>golazy.dev/$repo</h1>
      <a href="https://github.com/golazy/$repo"><img src="https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white" alt="Github"></a>
      <a href="https://pkg.go.dev/golazy.dev/$repo"><img src="https://pkg.go.dev/badge/golazy.dev/$repo.svg" alt="Go Reference"></a>
	    

	EOF
done

FILE=index.html
cat >$FILE <<-EOF
$HTMLHEAD
    <title>GoLazy</title>
  <body>
    <h1>golazy.dev</h1>
    <ul>
EOF

for repo in $REPOS; do
  cat >>$FILE <<-EOF
              <li>
              <a href="$repo.html">$repo</a> 
              <a href="https://github.com/golazy/$repo"><img src="https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white" alt="Github"></a>
              <a href="https://pkg.go.dev/golazy.dev/$repo"><img src="https://pkg.go.dev/badge/golazy.dev/$repo.svg" alt="Go Reference"></a>


              </li>

EOF
done
