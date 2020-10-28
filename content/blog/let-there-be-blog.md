+++
title = "Let There Be Blog"
date = 2014-01-16
+++
Following my recent discovery of the [Ghost](https://ghost.org/) blogging platform, I began to ponder the idea of setting up a blog on my website.

My initial concern was: 'What shall I put on it?'

This was a valid concern as my previous blogging endeavours were cesspools of teenage drama and emotion.
So instead of returning to my humble beginnings, I decided to dedicate my would-be blog to my new hobbies and interests, particularly development.
I also wanted to try my hand at both technical writing and ensure my twelve years of English courses weren't going to waste.

Now that I had an idea and purpose I began to think of an implementation.

As much as I liked Ghost I wanted to try my hand at a slightly more home-baked solution, one which wouldn't require quite as much of a makeover for my site as a Ghost implementation seemed to entail.
I remembered my initial foray into web development - static [Jekyll](http://jekyllrb.com/) sites for my [FRC Robotics Team](http://4343.ca/).
After researching those for a bit I realized [Markdown](http://daringfireball.net/projects/markdown/) would be a perfect way for me to write blog posts without having to put much effort into markup and boilerplate.
It was also the perfect combination of light-weight and flexible; I knew this from my experience with [Github Flavored Markdown](https://github.github.com/gfm/), with which I write short introductions and explanations for all of my Github-based [creations](https://github.com/indiv0/).
I also made a mental note to convert all of my [BukkitDev](https://dev.bukkit.org/members/_ForgeUser7047089/projects) projects to Markdown from Wikicreole.

I began searching for ways to implement this idea in the context of a [Flask](http://flask.pocoo.org/) app, and lo-and-behold it had already been done (nothing new under the sun, eh?).

The resource I had stumbled upon was James Harding's [write-up](http://www.jamesharding.ca/posts/simple-static-markdown-blog-in-flask/) of his implementation of said project.
Equipped with this walkthrough, I implemented into my site, customizing it for my existing site structure, only really modifying the organization - adding a year-based hierarchy for the posts.

Now that my implementation was done, I decided to write up this write-up as the first post.

It seemed rather fitting that the first post on my blog should be an explanation of the setup of my blog.
However, at this point in time, I have not yet merged the `feat/blog` branch into my `master` branch as I have not customized the actual rendering of the posts on my website, and I highly wish that at least the way the content is displayed be of my creation, and that it match the formatting of the website itself.

When this modification is complete, I imagine I will have another blog post at the ready.

I feel like [Cory Doctorow](http://xkcd.com/345/) already.

**Update (2020-10-27):** Fixed broken link to GFM page; fixed typo; fixed broken link to BukkitDev.
