{% if theme.swiftype_key %}
  {% include 'search/google.swig' %}
{% elseif theme.tinysou_Key %}
  {% include 'search/tinysou.swig' %}
{% elseif config.search.path %}
	{% include 'search/localsearch.swig' %}
{% endif %}
