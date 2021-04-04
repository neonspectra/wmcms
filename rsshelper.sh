#!/bin/bash
# This script is designed to help you update the rss feed for your site running WebmasterCMS. Run this script whenever you upload a new post to your site and it will automatically generate a new rss entry in your feed for the specified page. Consider moving this script to a directory outside of your webserver's installation.

# Command usage: rsshelper.sh https://example.com/posts/template-post/index.html
rss='/var/www/html/rss.xml' # Location of your site's RSS file goes here
rssitemstart='<ttl>' #Specifies a whatever tag is the very last tag in your RSS file before the <item> section begins. This will vary from feed to feed because the RSS standard does not have any sane delineation between its header and contents. If you are using the default RSS feed provided by wmcms, <ttl> should be the last line before new entries begin.

# Begin script function below.
#############################



# Creates a temporary file location and downloads the webpage we want to add to RSS
webpage=`mktemp /tmp/XXXXXXXXX.html`
curl $1 -o $webpage

# Extracts metadata from html head
title=$(grep "og:title" $webpage | sed -n -e 's/^.*content=\"\(.*\)\".*$/\1/p')
description=$(grep "og:description" $webpage | sed -n -e 's/^.*content=\"\(.*\)\".*$/\1/p')
url=$(grep "og:url" $webpage | sed -n -e 's/^.*content=\"\(.*\)\".*$/\1/p')
author=$(grep 'meta name="author"' $webpage | sed -n -e 's/^.*content=\"\(.*\)\".*$/\1/p')
pubdate=$(grep 'meta property="article:published_time"' $webpage | sed -n -e 's/^.*content=\"\(.*\)\".*$/\1/p')

# Convert html's ISO8601 date to RSS's RFC-822.
pubdate=$(date -d"$pubdate" --rfc-822)

# Updates the last build date of the RSS feed to now, then creates a new item entry in our existing feed. What kind of webmasters would we be if we didn't find a way to use ed for our site?
ed $rss << EOF
/<lastBuildDate>
d
a
<lastBuildDate>$(date --rfc-822)</lastBuildDate>
.
/$rssitemstart
.t.
s/.*/<item>
a
<title>$title</title>
<dc:creator>$author</dc:creator>
<description>$description</description>
<link>$url</link>
<pubDate>$pubdate</pubDate>
</item>
.
w
q
EOF

# Deletes our temporary file that we scraped to pull data from
rm $webpage
