local layout = import 'components/layout.libsonnet';
local commonPanels = import 'components/panels/common.libsonnet';
local haproxyPanels = import 'components/panels/haproxy.libsonnet';
local promQuery = import 'components/prom_query.libsonnet';
{
  requestResponsePanels(serviceSelectorKey='job', serviceSelectorValue='$deployment', startRow=1000)::
    local config = {
      serviceSelectorKey: serviceSelectorKey,
      serviceSelectorValue: serviceSelectorValue,
    };
    layout.grid([

      haproxyPanels.latencyTimeseries(config.serviceSelectorKey, config.serviceSelectorValue, span=6),
      haproxyPanels.httpResponseStatusTimeseries(config.serviceSelectorKey, config.serviceSelectorValue, span=6),
  
    ], cols=12, rowHeight=10, startRow=startRow),

  resourcePanels(serviceSelectorKey='job', serviceSelectorValue='$deployment', startRow=1000)::
    local config = {
      serviceSelectorKey: serviceSelectorKey,
      serviceSelectorValue: serviceSelectorValue,
    };
    layout.grid([

      commonPanels.timeseries(
        title='Per Instance CPU',
        yAxisLabel='CPU Usage',
        span=6,
        legend_show=false,
        query=|||
          sum(
            rate(
              container_cpu_usage_seconds_total{namespace="$namespace", pod=~"$deployment.*", container="main"}[5m])) by (pod)
        ||| % config,
        legendFormat='{{ pod }}',
        intervalFactor=2,
      ),

      commonPanels.timeseries(
        title='Per Instance Memory',
        yAxisLabel='Memory Usage',
        span=6,
        legend_show=false,
        query=|||
          sum(container_memory_usage_bytes{namespace="$namespace", pod=~"$deployment-.*", container="main"}) by (pod)
        ||| % config,
        legendFormat='{{ pod }}',
        intervalFactor=2,
      ),
    ], cols=2, rowHeight=200, startRow=startRow),

  storagePanels(serviceSelectorKey='job', serviceSelectorValue='$deployment', startRow=1000)::
    local config = {
      serviceSelectorKey: serviceSelectorKey,
      serviceSelectorValue: serviceSelectorValue,
    };
    layout.grid([
      commonPanels.latencyTimeseries(
        title='Storage R/W Latency',
        yAxisLabel='',
        span=12,
        query=|||
          rate(thumbor_gcs_fetch_sum{%(serviceSelectorKey)s="%(serviceSelectorValue)s"}[$__interval])
           /
           rate(thumbor_gcs_fetch_count{%(serviceSelectorKey)s="%(serviceSelectorValue)s"}[$__interval])
        ||| % config,
        legendFormat='{{ pod }}',
        intervalFactor=2,
      ),
    ], cols=1, rowHeight=10, startRow=startRow),

}
