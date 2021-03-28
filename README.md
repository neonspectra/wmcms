# WebmasterCMS - The CMS for Webmasters

*You think you're so cool with your Wordpress site with more plug-ins than your phone charger is factory rated for? Your garbage blog that pumps out HTTP requests like it's calling up the whole phonebook any time you try to load a page?*

*Well, guess what. This is a real, organic, free-range web framework. You've never seen one before. It's easily traversable. It's responsive and modular. It's got all your metadata tags and serves up pages in style. What more could you ask for?*

### The Story

One day I woke up and thought to myself that keeping up on the maintenance of my personal [Ghost](https://ghost.org/) website is actually a massive pain. They're always changing how various methods in the themes work, how the site itself works, or some other crap. In some ways, my fear of updating Ghost or of updating the webserver it ran on was starting to rule my life. 

I told myself that there *has* to be a better way. I should be running my website; it shouldn't be running *me*. There are nineties websites [still running to this day](http://home.mcom.com/home/welcome.html) that haven't been modified for longer than I've been alive. Why is it that these pages can go literally decades without updates and still remain functional, while my Ghost site will throw a fit when I run a routine server update?

Well, I'll tell you why. It's because we as web developers have forgotten our roots as webmasters. We throw together all this unnecessary garbage fragile garbage rather than using the rock-solid web foundations that those frameworks are built on to their fullest potential.

WebmasterCMS is my attempt at solving that problem.

![wmcms preview](https://i.imgur.com/9P4HArk.png?1)

### Key Features/Notes:

wmcms is a static site template built for hosting article-based websites on an nginx webserver. Think of it as "Wordpress without the bullshit".

wmcms is a site template that is designed with webmasters in mind, not end users. It's designed to make it as easy and painless as possible to get down and dirty with maintaining your website, you fucking webmaster you. You should be familiar with configuring and maintaining basic web technologies to make the most out of wmcms. You should be prepared to open up and familiarise yourself with how to modify every single file in this entire repository by hand (there's really not that many and none of it is particularly complex-- and that's the whole point of this project!)

- Powered entirely via [ngx_http_ssi_module](https://nginx.org/en/docs/http/ngx_http_ssi_module.html) and [ngx_fancyindex](https://www.nginx.com/resources/wiki/modules/fancy_index/).
 - No javascript, php, databases, or really anything else
 - Modular design: core site components are centralised in one location, so you only need to modify one set of files to globally tweak your website.
 - Posts are written in raw html

### Design Philosophy

wmcms is designed with the following ideas in mind:
 - Websites should be simple to maintain
   - A site should have as few moving parts (application frameworks, web engines, etc) as absolutely necessary to enable its core functionality. The less your site is built on, the fewer points of failure it has when it comes time to update.
 - Websites should be lean
   - No one appreciates when you force them to download over a megabyte of scripts and styling just to read a recipe you posted on your food blog. The point of a website is to send information from my computer into your brain; it really shouldn't take a lot to do that effectively.
 - Modern developers have a lot to learn from the webmasters of old
   - There was a time before Wordpress, before javascript, before even php. And the webmasters who ran the 'net back then made do. They wrangled their webservers to the fullest and hacked together sites that could do anything their business required of them-- somehow. Most of those simple yet powerful and efficient tools those webmasters relied on still exist today and are baked in to our modern systems. We just have to be willing to learn how to use them.
 - Modern tools are ridiculously powerful
   - Nostalgia isn't everything. We *do* have more tools than those webmasters of old could ever dream of, and we shouldn't be ashamed of using those tools to their fullest where appropriate. Modern utilities such as OpenGraphs and tastefully responsive styling make the web more accessible, and ultimately lend a better user experience than ever. You'd be amazed just how much you can accomplish with just a CSS stylesheet these days.
 - **And most importantly:** Websites should be fun.
   - Before the giants took over, the web was envisioned fun place for all of us to let our imaginations run wild and lovingly craft our own digital spaces for our friends and neighbours to read and learn from. The internet is **our** community, and each of us has the power to make it a little more fun than when we found it.

### Dependencies

wmcms will require the following items to be installed and configured on your computer.

For the framwork itself:
- nginx with [ngx_http_ssi_module](https://nginx.org/en/docs/http/ngx_http_ssi_module.html) and [ngx_fancyindex](https://www.nginx.com/resources/wiki/modules/fancy_index/) (these two modules are built into nginx by default on most distributions)

For the RSS helper script:
- Bash
- mktemp
- curl
- grep
- sed
- ed

### Installation

#### Configure nginx

This guide assumes you have a basic nginx webserver installed and running. The basics of installing nginx are outside the scope of this document, but a decent guide on how to do so can be found [here](https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-18-04).

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
                fancyindex_time_format "%F"; # Sets the date format for index pages. Default: 2077-01-01
                fancyindex_show_path off;
        }

        location /config { # '/config' should have SSI on but not be explorable
        ssi on;
        fancyindex off;
        }

        location /posts { # '/posts' should be both explorable and use SSI
        ssi on;
        fancyindex off;
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

### Configure RSS

The first thing you will want to do is open up `/rss.xml` in your editor of choice and configure your site name, url, and all the other applicable metadata fields.

wmcms does not dynamically generate or update RSS items, but instead relies on you to do so by hand. Thankfully, I've included a script `rsshelper.sh` that will automatically generate new RSS items using a specified page URL as an argument.

To use it, simply edit the configuration items within the script to specify your rss file location and rss item delimiter, then just run the script by doing:

`bash rsshelper.sh https://example.com/posts/template-post/index.html`

The script will automatically pull down your page from your live website, parse the metadata, and create a new RSS item in your RSS feed automagically. Run this script any time you make a new post that you want to add to RSS.

I would recommend moving `rsshelper.sh` out of your webroot directory since there is no reason to keep it in an accessible portion of your website, since it is not part of the site itself.

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
