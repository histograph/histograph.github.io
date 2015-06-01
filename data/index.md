---
d3: true
---
<ul id="sources">
</ul>

<script>
d3.json('{{ site.data.api.endpoint}}sources', function(json) {
  var source = d3.select('#sources').selectAll('li').data(json)
      .enter().append('li');

  source.append('h5').html(function(d) {
    return d.title;
  });

  source.append('p').html(function(d) {
    return d.description;
  });

});
</script>