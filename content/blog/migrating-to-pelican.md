+++
title = "Migrating to Pelican"
date = 2014-03-08
+++
<p>Initially this was going to be a post about deploying my newly created website to Dokku.</p>

<p>However, while I was contemplating the ins and outs of the migration, I decided that because my site relied so little on the dynamic features that the <a href="http://flask.pocoo.org/">Flask</a> framework provided, I decided to instead meet the following goals:</p>

<ul>
    <li>Migrate my site to a static platform</li>
    <li>Simplify the uploading process</li>
    <li>Host the site somewhere cheap and reliable</li>
</ul>

<p>Criterion two is really just an extension of three, so we'll consider those to be merged, giving us two real problems:</p>

<ul>
    <li>Platform</li>
    <li>Host</li>
</ul>

<h2>Platform</h2>

<p>The first goal was solved by researching various blogs and simply searching for static python blogging platforms.
I quickly found Alex Raichev's <a href="http://raichev.net/">website</a>, and I liked it quite a bit.
As it was stated - quite obviously - at the bottom of the page, the site ran on <a href="http://docs.getpelican.com">pelican</a>, a blogging platform that was already the frontrunner of my search.</p>

<p>I took a look at the source of his site, but unfortunately there didn't seem to be any references to the source templates or content, only the compiled files.
I did decide to settle with pelican though (or at least give it a shot), and give it a shot I did.</p>

<p>I created a basic website with pelican's website generator, as per their <a href="http://docs.getpelican.com/en/3.3.0/getting_started.html#installing-pelican">docs</a>:</p>

<pre><code>    virtualenv venv --python=python2.7
    source venv/bin/activate
    pip install pelican Markdown
    pelican-quickstart
</code></pre>

<p>After digging around in the documentation some more, I decided to just start modifying config files and tweaking things until I achieved a workable result.
It took me a while to realize that the theme of the website is structured separately from the content, so I copied the pelican <a href="https://github.com/getpelican/pelican/tree/master/pelican/themes/simple">simple</a> theme into my project directory and began modifying those templates.</p>

<p>So I tweaked and tweaked, until I finally managed a semi-decent replica of my Flask-based homepage.
When I reached that point, I began to migrate all of my pre-existing Markdown pages to the slightly different pelican format - all in all a painless process.</p>

<h2>Host</h2>

<p>I'd previously hosted websites using <a href="http://pages.github.com/">GitHub Pages</a>, specifically for my high school's FIRST Robotics team - <a href="http://4343.ca/">MaxTech 4343</a>.
After some deliberation, I decided that hosting on GitHub would fit all of my requirements - cheap (GitHub Pages is free), reliable (99.9919% uptime over the past month), and simple to upload to (done with a <code>git commit && git push</code>).</p>

<p>However, the deployment process wasn't quite as easy as it appeared at first glance as the <code>master</code> branch would display the website, but I also wanted to store the source in the same repository.</p>

<p>After a quick round of googling, I came upon a magical tool - <a href="https://github.com/davisp/ghp-import">ghp-import</a>, aka GitHub Pages Import.
It's essentially a python module, which, when installed in conjunction with pelican, allows the developer to simply run <code>make github</code> on a branch, and the website source would be compiled with pelican and put on the <code>gh-pages</code> branch.
It was exactly the tool I needed, but with some minor configuration necessary.</p>

<p>First I installed it:</p>

<pre><code>    pip install ghp-import</code></pre>

<p>I then had to move the source to another branch, as the compiled site should reside on <code>master</code>:</p>

<pre><code>    git checkout -b source</code></pre>

<p>I also had to update the <code>Makefile</code> to reflect these new
changes:</p>

<pre><code>    github: publish
        ghp-import -b master $(OUTPUTDIR)
        git push origin master
</code></pre>

<p>After all of these simple steps, I now had a functioning pelican site on GitHub Pages.</p>
