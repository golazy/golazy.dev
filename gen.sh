#!/bin/bash 


FILE=index.html

REPOS="autocerts flattenfs golazy layerfs lazyapp lazyassets lazycontroller lazydispatch lazyhttp lazyml lazysupport lazyview memfs multihttp protocolmux router"



cat > $FILE <<EOF
<!DOCTYPE html>
<html lang=en>
  <head>
    <title>GoLazy</title>
EOF


for repo in $REPOS; do
	echo Adding $repo
  echo "      <meta name=go-import content=\"golazy.dev/$repo git https://github.com/golazy/$repo.git\">" >> $FILE 
done

for repo in $REPOS; do
	echo Adding $repo
  echo "      <meta name=go-source content=\"golazy.dev/$repo https://github.com/golazy/$repo https://github.com/golazy/$repo/tree/master{/dir} https://github.com/golazy/$repo/blob/master{/dir}/{file}#L{line}\">" >> $FILE
done

cat >> $FILE <<EOF
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
    <h1>GoLazy</h1>
    <a href="https://github.com/golazy/golazy">Github</a>
    

EOF