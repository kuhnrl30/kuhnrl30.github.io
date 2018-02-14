---
title: "Moderating Google Comments in a Jekyll Blog"
output: html_document
layout: post
date: '2018-01-15'
comments: TRUE
tags: []
htmlwidgets: false
description: "Moderating Google Comments in a Jekyll Blog"
---


## Motivation 

Comments are an important part of a blog because it allows you to interact with the audience.  It's quite easy to add comments to your Jekyll blog with only a few lines of html through Google Plus.  There's plenty of tutorials on how to do this (I used [this one](http://blog.nrowegt.com/how-to-setup-jekyll-with-google-plus-comments-and-other-customizations-on-github-pages/)) so I won't go into setup.  

The issue is that there hasn't been a mechanism to moderate the comments or event to see a condensed summary of messages left by the reader.  Personally I've missed opportunities to reply to my readers because I simply wasn't aware the comments existed.  This is my first pass attempt at a tool to moderate the comments, or at least see everything in one place.

### TL; DR
The G+ api will return comments for each post but only the last will be visible.  Use CSS to bring them back on the screen.

## How to do it

The Google API will add a &lt;code>div&lt;/code> with all of the comments left on Google Plus.  You'd use this on a single blog post but there are issues if you try to poll the API for multiple links on a single page.  Only the last link used will be visible on your page.  Every link you pass to the API will return the comments but only the last link will be on screen.  The other links before it will be shown off screen.  

My solution: bring the other divs back onscreen.  We can add a few lines of javascript to accomplish this.  

### 1. Add a page to aggreate the comments  
We'll get started by creating a page just to aggregate your comments.  Create a new folder and an index.md file with your usual YAML headers.  We won't link this page from anywhere else in the site so it will generally go unnoticed by the reader.  I am calling my page 'commentlog' so my project directory will look something like this:

<pre><code>blog   
contact  
css  
commentlog  
&#8627; index.md  
_data  
_layouts  
_includes  
_config.yml
index.html
</code></pre>

### 2. Poll Google for comments on each post

Next, we'll add a few lines to get the G+ comments for each of your blog posts.  This block of code will loop through all of your blog posts and get the comments from Google.  We'll display the post title to separate the comment blocks and make it easier to read.  I've arbitrarily set the comment block width at 624px so feel free to customize that size. 


<pre>{% raw %}<code class="html">&lt;script type='text/javascript' src='https://apis.google.com/js/plusone.js'>&lt;/script>

{% for post in site.categories.blog %}

&lt;h4>{{ post.title }}&lt;/h4>
&lt;div id='comments{{ forloop.index }}'>
{{ post.title }}
&lt;/div>
&lt;hr>

&lt;script type='text/javascript'>

  gapi.comments.render('comments{{ forloop.index }}', {
    href: 'http://ryankuhn.net{{ post.url }}',
    width: '624', 
    first_party_property: 'BLOGGER',
    view_type: 'FILTERED_POSTMOD'
    });

&lt;/script>  
{% endfor %}
</code>{% endraw %}</pre>


### 3. Add styling to bring everything back on the page  

At this stage we'll have several sections that look like they should have comments but there is nothing there.  The issue is that Google's javascript file changes the alignment so that all but the last comment block is on the page.  All others will but off screen up and to the left.  I wasn't able to decipher the minimized code file and adjust so the approach I'm taking is to add additional styling to bring them back on screen.  We're using jquery here but I'm already using boostrap so it isn't a new dependency for me.  Again, the height and width are arbitrarily set to 600px and 624px so you should customize to your tastes.

<pre>{% raw %}<code>&lt;script type= "text/javascript">
  
  $('iframe').css({
    'position': 'static',
    'width': '642px',
    'height': '600px'
    });
    
  $('iframe').css( 'top', '' );
  $('iframe').scrolling = 'yes';

&lt;/script>

</code>{% endraw %}</pre>


## [See it in action](http://ryankuhn.net/commentlog)  

## Conclusion  
Admittedly a first pass attempt at creating a tool to monitor the comments being left on my blog.  It's not pretty. but it works for now.  For future development I'd like to be able to make the height dynamic or hide the section for a post if there aren't any comments.  I'm hoping other readers can push this approach a little further down the road towards a complete solution. 

If you liked this post, leave a comment below or subscribe!



