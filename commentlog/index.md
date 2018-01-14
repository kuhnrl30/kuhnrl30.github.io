---
title: "Test upload automation"
output: html_document
layout: default
---


# Testing 1, 2 3 ...


<script type='text/javascript' src='https://apis.google.com/js/plusone.js'></script>


<div id="comments1"></div>
<hr>
<div id="comments2"></div>
<hr>
<div id="comments3"></div>




<script type='text/javascript'>
gapi.comments.render('comments1', {
  href: 'http://ryankuhn.net/blog/Fantasy-Football-in-R-Part-I',
  width: '624',
  first_party_property: 'BLOGGER',
  view_type: 'FILTERED_POSTMOD'
  });

gapi.comments.render('comments2', {
  href: 'http://ryankuhn.net/blog/How-To-Use-Plotly-With-Jekyll',
  width: '624',
  first_party_property: 'BLOGGER',
  view_type: 'FILTERED_POSTMOD'
  });

gapi.comments.render('comments3', {
  href: 'http://ryankuhn.net/blog/How-To-Use-Plotly-With-Jekyll',
  width: '624',
  first_party_property: 'BLOGGER',
  view_type: 'FILTERED_POSTMOD'
  });


</script>


<hr>

  
  
  
<script type= "text/javascript">
  
  $('iframe').css({
    'position': 'static',
    'width': '642px' 
    });
    
  $('iframe').css( 'top', '' );
  $('iframe').scrolling = 'yes';
    
  $('iframe').load(function() {
    var hgt2 = $(this).contents().find('div.yJa').outerHeight();
    var hgt = $(this).find('div.yJa').outerHeight();
    console.log(  hgt2 );
    $(this).style.height = $(this).find('.yJa').outerHeight() + 'px';
  });

</script>