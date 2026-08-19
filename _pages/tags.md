---
layout: page
permalink: /tags/
title: Tags
nav: true
nav_order: 3
description: All tags used on this blog.
---

{% assign tags = site.tags | sort %}

{% if tags.size == 0 %}
<p>No tags yet.</p>
{% else %}
<ul class="post-list">
  {% for tag in tags %}
  <li>
    <h3>
      <a class="post-title" href="{{ tag[0] | slugify | prepend: '/blog/tag/' | relative_url }}">{{ tag[0] }}</a>
    </h3>
    <p class="post-meta">{{ tag[1].size }} {% if tag[1].size == 1 %}post{% else %}posts{% endif %}</p>
    <p>
      {% for post in tag[1] %}
      <a href="{{ post.url | relative_url }}">{{ post.title }}</a>{% unless forloop.last %} · {% endunless %}
      {% endfor %}
    </p>
  </li>
  {% endfor %}
</ul>
{% endif %}
