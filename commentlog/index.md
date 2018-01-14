---
title: "Summary of Comments"
output: html_document
layout: default
---


# Google Comments by Blog Post


<script type='text/javascript' src='https://apis.google.com/js/plusone.js'></script>


{% for post in site.categories.blog %}

<h4>{{ post.title }}</h4>
<div id='comments{{ forloop.index }}'>
{{ post.title }}
</div>
<hr>

<script type='text/javascript'>

  gapi.comments.render('comments{{ forloop.index }}', {
    href: 'http://ryankuhn.net{{ post.url }}',
    width: '624',
    first_party_property: 'BLOGGER',
    view_type: 'FILTERED_POSTMOD'
    });

</script>  
{% endfor %}





<script type= "text/javascript">
  
  $('iframe').css({
    'position': 'static',
    'width': '642px',
    'height': '600px'
    });
    
  $('iframe').css( 'top', '' );
  $('iframe').scrolling = 'yes';

</script>