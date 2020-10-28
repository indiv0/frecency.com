+++
title = "Changing My Website Domain"
date = 2020-10-27
+++

I want to change my primary domain from frecency.dev to frecency.com. I'm
keeping both, but I'd like to use frecency.com for my email address. Just to
keep it simple. I'm also going to move my blog from a subdomain to the root
domain, also for simplicity.

To do so, I need to move my old blog to the new domain. I'm not going to
bother setting up redirects from the old pages since no one really reads this
blog  and they've only been up for a few months.

I will however move content from my [_old old_ blog](https://nikitapek.in) to
the new one and setup redirects for its pages since that one has been up for
~6 years and does receive a modest amount of traffic.

First, per [my article](https://frecency.com/blog/new-website/) on how I
initially setup this website, I need to first create a new S3 bucket for the
site. I'll use the same settings for bucket policy, DNS, and Cloudflare workers
as before, just for the new domain. Note that I need to modify the existing
worker CSP policy for the new domain.

Next, I follow [this article](https://community.cloudflare.com/t/redirecting-one-domain-to-another/81960)
to redirect my old domain to my new domain using Cloudflare's page rules. I
also disable my Cloudflare workers on the old domain.

I then setup similar redirects for all my other frecency.\* domains.

Then, I delete my old S3 bucket.

Now that the old blog is migrated to the new domain, I need to migrate my old
old blog. Since that blog is also hosted on S3, I first need to convert its
source to [Zola](https://www.getzola.org/) pages.

After converting the pages to Zola, I chose to develop my own theme for Zola,
inspired by a few minimalist web pages I've seen before.
