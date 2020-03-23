local commonPanels = import 'components/panels/common.libsonnet';
local promQuery = import 'components/prom_query.libsonnet';

{
  cpuUtilisation(span=2)::

    commonPanels.gauge(
      title='CPU Utilisation',
      gaugeMinValue=0,
      gaugeMaxValue=100,
      span=span,
      query=|||
        sum (rate (container_cpu_usage_seconds_total{id!="/",service="kubelet"}[1m]))
          /
        sum (machine_cpu_cores{service="kubelet"}) * 100
      |||,
    ),
}