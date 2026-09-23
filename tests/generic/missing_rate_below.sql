{#
  Passes when the share of null values in a column is at or below max_pct percent.
  Use for fields the business has agreed can occasionally be missing, where every
  row is kept and flagged downstream instead of being dropped.
  Returns one row (the failure) if the missing rate exceeds the tolerance.
#}
{% test missing_rate_below(model, column_name, max_pct) %}

select
    count(*)                                                   as total_rows,
    count(*) - count({{ column_name }})                        as missing_rows,
    round(100.0 * (count(*) - count({{ column_name }})) / count(*), 2) as missing_pct,
    {{ max_pct }}                                              as max_pct
from {{ model }}
having 100.0 * (count(*) - count({{ column_name }})) / count(*) > {{ max_pct }}

{% endtest %}
