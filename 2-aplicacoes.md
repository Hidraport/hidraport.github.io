---
layout: page
title: Aplicações
menu-title: Aplicações
permalink: /aplicacoes/
excerpt: >
  Conheça a participação que os nossos produtos têm em todas as áreas. Atendemos os setores metalúrgico, químico, siderúrgico, de autopeças, plásticos, papeleiros, de navegação, e outros.
---

{% for app in site.aplicacoes %}

---

## {{ app.title }}

<div data-grid="center spacing" class="inner large">
    <div data-cell="1of2{% cycle '', ' order-1' %}">
        {% include img_from_url.html
            src = app.url
            alt = app.title
            format = 'jpg'
        %}
    </div>
    <div data-cell="1of2">
        <p>{{ app.content }}</p>
    </div>
</div>

{% endfor %}
