---
layout: page
permalink: /categories/
title: Categories
nav: true
nav_order: 2
description: Browse posts by category.
---

{% assign known_categories = "LLM,Mathematics,Full Stack,Humanities,Essays" | split: "," %}

<ul class="post-list">
  {% for category in known_categories %}
    {% assign posts = site.categories[category] %}
    {% assign count = posts.size %}
    <li>
      <h3>
        {% if count > 0 %}
          <a class="post-title" href="{{ category | slugify | prepend: '/blog/category/' | relative_url }}">{{ category }}</a>
        {% else %}
          <span class="post-title">{{ category }}</span>
        {% endif %}
      </h3>
      <p class="post-meta">{{ count }} {% if count == 1 %}post{% else %}posts{% endif %}</p>
    </li>
  {% endfor %}
</ul>
