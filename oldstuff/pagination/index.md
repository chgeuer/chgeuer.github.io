---
layout: default
title: "pagination bits"
---

<div>
	<ul class="pagination">
	  {% if paginator.previous_page_path %}
	    <li><a href="{{ paginator.previous_page_path }}"><i class="fa fa-backward"></i> {{ paginator.previous_page }}</a></li>
	  {% else %}
	    <li class="disabled"><a href="#"><i class="fa fa-backward"></i></a></li>
	  {% endif %}

	  <li><a href="#"><span class=""><i class="fa fa-stop"></i></span></a></li>

	  {% if paginator.next_page_path %}
	    <li><a href="{{ paginator.next_page_path }}"><i class="fa fa-forward"></i>   {{ paginator.next_page }}</a></li>
	  {% else %}
	    <li class="disabled"><a href="#"><i class="fa fa-forward"></i>  </a></li>
	  {% endif %}
	</ul>
</div>

