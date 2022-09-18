# NOTE: This tool has been deprecated in favour of [Arise](https://github.com/spectrasecure/arise). No further updates will be pushed to this repo.

---
---

# WebmasterCMS - The CMS for Webmasters

*You think you're so cool with your Wordpress site that has more plug-ins than your phone charger is factory rated for? You think it's neat to build a blog that pumps out HTTP requests like it's calling up the whole phonebook any time you try to load a single page?*

*Well, guess what. This is a real, organic, free-range web framework. You've never seen one before. It's easily traversable. It's responsive and modular. It's got all your metadata tags and serves up pages in style. What more could you ask for?*

### The Story

One day I woke up and thought to myself that keeping up on the maintenance of my personal [Ghost](https://ghost.org/) website is actually a massive pain. They're always changing how various methods in the themes work, how the site itself works, or some other crap. 

Like some kind of fucked up Pavlovian experiment, I realised that my website was slowly conditioning me to be terrified of updating since I knew I'd be the one to have to take the time and fix it every time it broke. Most modern site engines take for granted that you have an entire corporate dev team with practically unlimited man hours constantly troubleshoot whatever conflicts will inevitably crop up as updates are applied. But I'm just one woman. I don't have time for that shit. 

I told myself that there *has* to be a better way. I should be running my website; it shouldn't be running *me*. There are nineties websites [still running to this day](http://home.mcom.com/home/welcome.html) that haven't been modified for longer than I've been alive. Why is it that these pages can go literally decades without updates and still remain functional, while my Ghost site will throw a fit when I run a routine server update?

Well, I'll tell you why. It's because we as web developers have forgotten our roots as webmasters. We throw together all this unnecessary fragile garbage rather than using the full potential of the rock-solid web foundations that modern frameworks are built to extend.

WebmasterCMS is my attempt at solving that problem.

![wmcms preview](https://i.imgur.com/A1MPbIJ.png?1)

### Key Features/Notes:

wmcms is a static site template built for hosting article-based websites on an nginx webserver. Think of it as "Ghost without the bullshit".

wmcms is written by a webmaster, for the ease of use of other webmasters. It's designed to make it as easy and painless as possible to get down and dirty with maintaining your website, you fucking webmaster you. Unfortunately, that means wmcms isn't particularly great for tech-illiterate people who expect a WYSIWYG monstrosity to enable them to manage and write posts on their website. To get the most out of this platform, you should be familiar with how to configure and maintain an nginx webserver. 

Be prepared to open up and familiarise yourself with how to modify every single file in this entire repository by hand. They are all important and meaningful. Luckily, there's really not that many files and none of them are particularly complex-- and that's the whole point of this project!

Some quick bullet points about wmcms:
- Powered entirely via [ngx_http_ssi_module](https://nginx.org/en/docs/http/ngx_http_ssi_module.html) and [ngx_fancyindex](https://www.nginx.com/resources/wiki/modules/fancy_index/).
 - No javascript, php, databases, or really anything else
 - Modular design: core site components are centralised in one location, so you only need to modify one set of files to globally tweak your website.
 - Posts are written in raw html

For a live example of a website running wmcms, check out https://neosynth.net

### Design Philosophy

wmcms is designed with the following ideas in mind:
 - Websites should be simple to maintain
   - A site should have as few moving parts (application frameworks, web engines, etc) as absolutely necessary to enable its core functionality. The less your site is built on, the fewer points of failure it has when the comes time to update.
 - Websites should be lean
   - No one appreciates when you force them to download over a megabyte of scripts and styling just to read a recipe you posted on your food blog. The point of a website is to send information from my computer into your brain; it really shouldn't take a lot to do that effectively.
 - Modern developers have a lot to learn from the webmasters of old
   - There was a time before Wordpress, before javascript, before even php. And the webmasters who ran the 'net back then made do with what they had. They wrangled their webservers to the fullest and they hacked together sites that could do anything their business required of them-- somehow. The tools used by webmasters of the past may be antiquated, but they are powerful and efficient by design and should not be understimated. Most of these utilities still exist today and are often baked into the foundation of our modern systems. We just have to be willing to learn how to use them.
 - Modern tools are ridiculously powerful
   - Nostalgia isn't everything. We *do* have more tools than those webmasters of old could ever dream of, and we shouldn't be ashamed of using newer toys when appropriate. Modern protocols like OpenGraphs and accessibility tools like the tastefully responsive styling additions in CSS3 help us build better user experiences than ever. You'd be amazed how much interactivity you can accomplish with just a CSS stylesheet these days.
 - **And most importantly:** Websites should be fun.
   - Before the giants took over, the web was envisioned fun place for all of us to let our imaginations run wild and lovingly craft our own digital spaces for our friends and neighbours to read and learn from. The internet is **our** community, and each of us has the power to make it a little more fun than when we found it. Unfortunately, it's pretty hard to retake the internet as a place for individual self-expression without adequate tools to have a platform. wmcms is here to empower you to build a digital space that doesn't need a fully staffed corporate webdev team just to keep the place running day-to-day so that you can focus on what really matters: sharing your site's unique message with the world.

### Dependencies

wmcms will require the following items to be installed and configured on your computer.

For the framework itself:
- nginx with [ngx_http_ssi_module](https://nginx.org/en/docs/http/ngx_http_ssi_module.html) and [ngx_fancyindex](https://www.nginx.com/resources/wiki/modules/fancy_index/) (these two modules are built into nginx by default on most distributions)

For the RSS helper script:
- Bash
- mktemp
- curl
- grep
- sed
- ed

For the sitemaper script:
- Bash
- find
- sed
- grep

### Installation

#### Docker

Instructions on building wmcms as a Docker image can be found [here](https://github.com/neonspectra/wmcms-docker). If you follow these steps, you can skip down to [configuring wmcms](#configure-wmcms).

Using Docker is recommended because it's easier to set up, it gives you a cleaner base to version control new posts to your website more effectively, and it lets you easily test new content locally before you push it to your live environment.

Alternatively, if you prefer setting your webserver up like a traditional webmaster, continue below.

#### Configure nginx

If you are not using Docker, you will need to set up a webserver with nginx. This guide assumes you have a basic nginx webserver installed and running. The basics of installing nginx are outside the scope of this document, but a decent guide on how to do so can be found [here](https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-18-04).

After you have nginx installed, you will want to add some items to your nginx configuration to configure the features used by wmcms. You may want to tweak accordingly depending on your particular site, but a good set of defaults to include in your server block are:

```
        location / {
                ssi on; # Since wmcms uses SSI for most things, we generally want it enabled
                # WARNING: BE EXTRA CAREFUL IF YOU BUILD PAGES THAT ACCEPT USER-SUBMITTED CONTENT.
                # SSI INJECTION VULNERABILITIES ARE NO FUCKING JOKE.
                
                try_files $uri $uri/ =404;
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.

                fancyindex on;              # Enable fancy indexes.
                fancyindex_exact_size off;  # Output human-readable file sizes.
                fancyindex_footer /config/footer.html; # Sets the footer for your index pages
                fancyindex_header /config/header.html; # Sets the header for your index pages
                fancyindex_default_sort date_desc; # Sorts indices by date, with newest posts at the top
                fancyindex_time_format "%F"; # Sets the date format for index pages. Default: 2077-01-01
                fancyindex_show_path off;
        }

        location /config { # '/config' should have SSI on but not be explorable
        ssi on;
        fancyindex off;
        }

        location /posts { # '/posts' should be both explorable and use SSI
        ssi on;
        fancyindex on;
        }

        location /meta { # Metapages should have SSI, but you probably don't want these indexed
        ssi on;
        fancyindex off;
        }
        
        # Use our fancy error messages for common errors. You can make more if you want.
        error_page 403 /config/errors/403.html;
        error_page 404 /config/errors/404.html;

```

### Download wmcms

Clone the contents of this repo into your webserver's root directory. As long as you have nginx configured for SSI and fancyindex properly, everything should just work out of the box to give you the default wmcms website.

### Configure wmcms

As stated above, you will probably want to familiarise yourself with every single file in wmcms to use it effectively. That being said, there are some basics in terms of some pages you may want to immediately configure.

Almost all of the core components of wmcms are located in the `/config` directory.

- Open up `/config/siteconfig.html` in your editor of choice and set your site's name and domain. These variables are used to populate several metadata fields in the site headers.
- Configure your site's theme via the stylesheet in `/config/main.css`. wmcms includes a default set of styles for responsive design, as well as some custom classes to make formatting your posts easier. I'd recommend familiarising yourself with this css file to understand how it works, since it does the heavy lifting of making a wmcms site functional.
- Create a favicon. I'd recommend using [this](https://realfavicongenerator.net/) site to generate your favicon, since there's just way too many platforms to consider these days to do it by hand. Your favicon items will ultimately go in `/config/favicon/`

### Making posts

All posts (including the site homepage) are based off the same post template. An example post is included at `/posts/template-post/index.html`. 

To make a new post, simply create a new directory within `/posts/` and then copy the post template `index.html` to your new post directory and then edit the file to your liking. It's that easy! The nginx fancyindex module will automatically create an index for `/posts/` so that you can dyanamically browse through all the posts your have created so far.

When you open up the template `index.html`in your text editor of choice, you will see that it's highly modular, with a bunch of metadata tags at the top for things like the post title, author, etc. Those metadata items are used to populate the modular HTML header for your site, so don't forget to fill them out any time you make a new post!

### Search Engine Optimisation (SEO)

Modern websites have certain accessibility features that make it easier for crawlers to index your site so that it appears in search results on your favourite search engine. Some of these tasks are pretty annoying to do completely by hand, so let's talk about how wmcms can help you.

Feel free to use these options if you want. Or don't. You can delete all the SEO stuff if you want and your website will still work, but you probably won't get as many search hits.

#### robots.txt

This one is pretty self-explanatory because you can set it up once and then forget about it. Make sure to edit the bundled `robots.txt` so that it reflects your domain name.

The bundled configuration disallows crawlers from indexing the `/config` directory since that section is not designed to be user traversable.

#### RSS

The first thing you will want to do is open up `/rss.xml` in your editor of choice and configure your site name, url, and all the other applicable metadata fields.

wmcms does not dynamically generate or update RSS items, but instead relies on you to do so by hand. However, this repository includes a script `rsshelper.sh` that will automatically generate new RSS items using a specified page URL as an argument.

To use it, simply edit the configuration items within the script to specify your rss file location and rss item delimiter, then just run the script by doing:

`bash rsshelper.sh https://example.com/posts/template-post/index.html`

The script will automatically pull down your page from your live website, parse the metadata, and create a new RSS item in your RSS feed automagically. Run this script any time you make a new post that you want to add to RSS.

I would recommend moving `rsshelper.sh` outside of your webroot directory. There is no reason to keep it in an accessible portion of your website since it is not part of the site itself.

#### Sitemap

wmcms includes a script `sitemapper.sh` to automate building a sitemap.xml file. Make sure to edit the script options as described in the file comments. 

Paths within your site's `/config` directory are excluded from the sitemap since that path is not intended to be traversable on its own.

I would recommend moving `sitemapper.sh` outside of your webroot directory. There is no reason to keep it in an accessible portion of your website since it is not part of the site itself.

### Gotchas
- If you want to change the `background-color` css style, you will notice that it probably won't work if you set it just in `/config/main.css`. That's because it's also explicity set in `/config/header.html` and for all the files in `/config/errors`. Setting the background colour inline in the html body of these pages is important because it prevents users from getting a splash of white (if your site has a dark background) while the linked stylesheet is still loading in the user's browser.
- There is both a sidebar and a topbar version of the navigation bar in `/config/header.html`. These are responsive elements, so that mobile users and desktop users get a different experience. If you edit the links in your navbar, remember to update both the sidebar *and* the topbar if you want them to match.
- The nginx fancyindex module shows timestamps based on the filesystem modify date, NOT the SSI variable  metadata modify date stored within posts. Unfortunately, there is not really any easy way to fix this without patching and recompiling the nginx fancyindex module to edit its default functionality. A workaround for this is to use the unix `touch` command to change the modify date after editing a post if you want to keep your posts indexed by publish date.
- In your nginx config file, make sure that you have `ssi on;` in your location block for `/config`, even if you keep indexing off for the config directory to make it not explorable. SSI must be enabled there so that the modular core components of the framework themselves are able to perform SSI actions.

### FAQ

##### I don't like doing so much by hand. Can you automate [thing]?

The purpose of this framework is ultimately to make very "set-and-forget" websites that are easy to understand and maintain. Automations are an extra moving part prone to break down the line, depending on how they are implemented.

The modular design of this site should put the amount of busywork that needs to be done to tweak any one aspect of a wmcms site down to a minimum, but there's ultimately no getting around the fact that WebmasterCMS is a minimalist site template that is designed around the idea that you're gonna get down and dirty with writing your own HTML in order to proactively futureproof your website as best as possible.

If you would like to make an automation in your site for some function or feature to extend this site, you're welcome to make one.

##### Writing raw HTML is so 90s. Why not use Markdown?

Yes it is. But HTML is also the most futureproof responsive document format available to us, aside from plaintext. And there's several benefits to writing raw html over using some kind of formatting engine.

When you write raw HTML, you can use inline CSS styling and formatting tricks to make more unique and interesting pages with more power than Markdown. Additionally, you can more easily define custom classes for styling your text however you wish, since you can easily and directly work with your site's stylesheet in your HTML document.

And really, if you prefer to write in markdown, nothing is stopping you from plugging it into one of the million Markdown -> HTML converters out there, and then pop the result into a page template.

### Inspirations

wmcms was inspired by the following geniuses:

- [Motherfucking Website](https://motherfuckingwebsite.com/)
- [Better Motherfucking Website](http://bettermotherfuckingwebsite.com/)
- [Fucking Webmasters](https://justinjackson.ca/webmaster/)
- [Web Bloat Score](https://www.webbloatscore.com/)
