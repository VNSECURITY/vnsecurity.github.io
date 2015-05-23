---
layout: default_sidebar
paginate: false
---

<ul class="post-list">
    <div class="widget kopa-entry-list-widget clearfix">
        <h4 class="widget-title clearfix">
            <span class="title-text">Headlines</span>
        </h4>
        {% for post in site.posts limit:5 %}
            {% include post_row.html %}
        {% endfor %}        
    </div>    
    {% for category in site.portal_categories %}
        <div class="widget kopa-entry-list-widget clearfix">
            <h4 class="widget-title clearfix">
                <span class="title-text">{{ category}}</span>
            </h4>
            {% for post in site.categories[category] limit:3 %} 
                {% include post_row.html %}
            {% endfor %}
        </div>
    {% endfor %}
</ul>
