---
layout: default	
Resume: passive
Projects: active
blog: passive
moocs: passive
contact: passive
description: "Portfolio of machine learning and data analytics projects"
---

<h3 style="text-align: center;">Portfolio of Projects and Competitions</h3>
These projects are a mix of my work in machine learning competitions or course projects in the Data Science Specialization. The projects cover a range of technical capabilities from simple regression to stacking multiple algorithms to make a single prediction.  Go ahead and browse through them- I'd love to get your feedback!

<style>
.major-proj-card {
	position: relative;
	min-height: 325px;
	}
.minor-proj-card {
	position: relative;
	min-height: 175px;
	}
.proj-btn {
	position: absolute;
	bottom: 10px;
	}
.proj-type{
	position: absolute;
	bottom: 35px;
	}
.row {
	display: -webkit-box;
	display: -webkit-flex;
	display: -ms-flexbox;
	display: flex;
	flex-wrap: wrap;
	}
.row > [class*='col-'] {
	display: flex;
	flex-direction: column;
	}
</style>

<div class="row">
    {% for proj in site.data.majorprojects %}
        <article  data-url="{{ proj.url }}" class="col-lg-6 col-md-6 col-sm-12 panel panel-default major-proj-card" itemscope="itemscope" itemtype="http://schema.org/Article" >
			<h4 itemprop="name"><a href="{{ proj.link }}">{{ proj.name }}</a></h4>
			<p class="description">{{ proj.objective }}</p>
			<a href="{{ proj.link }}" class="btn btn-default btn-xs col-sm-6 col-lg-6 proj-btn">Project Page</a>
        </article>
    {% endfor %}
	</div>
	

<div class="row">
{% for proj in site.data.minorprojects %}
	<div class="col-lg-4 col-md-4 col-sm-6 minor-proj-card panel panel-default">
		<h4>{{ proj.name }}</h4>
		<p class="description">{{ proj.intro }}</p>
		{% if proj.link %}
			<a href="(( proj.link ))" class="btn btn-default btn-xs col-sm-6 proj-btn">Project Page</a>
		{% else %}
			<a href="(( proj.url ))" class="btn btn-default btn-xs col-sm-6 proj-btn">Github</a>
		{% endif %}
		<p><small class="text-muted proj-type">{{ proj.type }}</small></p>
	</div>
{% endfor %}
</div>
