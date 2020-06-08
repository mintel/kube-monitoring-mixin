local layout = import 'components/layout.libsonnet';
local commonPanels = import 'components/panels/common.libsonnet';
local workloadPanels = import 'components/panels/workloads.libsonnet';
{

  overview(serviceSelectorKey='service', serviceSelectorValue='$service', startRow=1000)::
    local config = {
      serviceSelectorKey: serviceSelectorKey,
      serviceSelectorValue: serviceSelectorValue,
    };
    layout.grid([

      workloadPanels.workloadStatus(),
      commonPanels.singlestat(
        title='Incoming Request Volume',
        description='Requests per second (all http-status)',
        colorBackground=true,
        format='rps',
        sparklineShow=true,
        span=4,
        query=|||
          sum(
            rate(
              http_request_duration_seconds_count{namespace="$namespace", %(serviceSelectorKey)s="%(serviceSelectorValue)s"}[$__interval]))
        ||| % config,
      ),
      commonPanels.singlestat(
        title='Incoming Success Rate',
        description='Percentage of successful (non http-5xx) requests',
        colorBackground=true,
        format='percent',
        sparklineShow=true,
        thresholds="99,95",
        colors=[
          '#d44a3a',
          'rgba(237, 129, 40, 0.89)',
          '#299c46',
        ],
        span=4,
        query=|||
          100 - (
            sum by (service, app_mintel_com_owner)
              (
                rate(http_request_duration_seconds_count{namespace="$namespace", %(serviceSelectorKey)s="%(serviceSelectorValue)s", status_code=~"5.."}[$__interval])
                    or 0 * up{namespace="$namespace", %(serviceSelectorKey)s="%(serviceSelectorValue)s"}
              )

            /
            sum by (service, app_mintel_com_owner)
              (
                rate(http_request_duration_seconds_count{namespace="$namespace", %(serviceSelectorKey)s="%(serviceSelectorValue)s"}[$__interval])
                  or 0 * up{namespace="$namespace", %(serviceSelectorKey)s="%(serviceSelectorValue)s"}
              )
          ) * 100
        ||| % config,
      ),

    ], cols=12, rowHeight=10, startRow=startRow),
}
