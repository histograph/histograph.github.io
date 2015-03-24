---
---

__DRAFT!__

### Place-in-Time

<table class="u-full-width">
  <thead>
    <tr>
      <th>Property</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>HGID</td><td>Histograph identifier</td>
    </tr>
    <tr>
      <td>Source</td><td>Data source</td>
    </tr>
    <tr>
      <td>Name</td><td>String term from source</td>
    </tr>
    <tr>
      <td>Period</td><td>Start and end date - we'll use <code>xsd:date</code> for now, but we'll look into more <a href="http://dh.stanford.edu/topotime/docs/TemporalGeometry.pdf"><i>fuzzy</i></a> dates later</td>
    </tr>
    <tr>
      <td>Geometry</td><td>Point, line or polygon</td>
    </tr>
    <tr>
      <td>URI</td><td>URI of object in source</td>
    </tr>
  </tbody>
</table>

### Atomic relationships

<table class="u-full-width vertical-align-top no-borders">
  <tbody>
    {% for property in site.data.atomic %}
      {% for relation in property.relations %}
      {% if forloop.last %}
      <tr class="border-bottom">
      {% else %}
      <tr>
      {% endif %}
        {% if forloop.first %}
        <td rowspan="{{ forloop.length }}">
          <span class="first-pit">{{ property.name }}</span> - <span class="second-pit">{{ property.name }}</span>
        </td>
        {% endif %}
        <td class="no-left-margin"><code>{{ relation }}</code></td>
        <td><img src="{{ site.baseurl}}/images/properties_{{ property.name }}_{{ relation }}.svg" /></td>
      </tr>
      {% endfor %}
    {% endfor %}
  </tbody>
</table>

### Relationships

<table class="u-full-width vertical-align-top no-borders">
  <thead>
    <tr>
      <th>Relation</th>
      <th>Atomic relations</th>
    </tr>
  </thead>
  <tbody>
    {% for relation in site.data.relations %}
      {% for atomic in relation.atomic %}
      {% if forloop.last %}
      <tr class="border-bottom">
      {% else %}
      <tr>
      {% endif %}
        {% if forloop.first %}
        <td rowspan="{{ forloop.length }}">
          <code>{{ relation.uri }}</code>
        </td>
        {% endif %}
        <td class="no-left-margin"><code>{{ atomic }}</code></td>
      </tr>
      {% endfor %}
    {% endfor %}
  </tbody>
</table>