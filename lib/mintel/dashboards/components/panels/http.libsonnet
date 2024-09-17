local commonPanels = import 'components/panels/common.libsonnet';
{
  httpBackendRequestsPerSecond(serviceSelectorKey='service', serviceSelectorValue='$service', span=4)::
    local config = {
      serviceSelectorKey: serviceSelectorKey,
      serviceSelectorValue: serviceSelectorValue,
    };
    commonPanels.singlestat(
      title='Incoming Request Volume',
      description='Requests per second (all http-status)',
      colorBackground=true,
      format='rps',
      sparklineShow=false,
      span=4,
      query=|||
        sum(
          rate(
            http_requests_total{namespace="$namespace", %(serviceSelectorKey)s="%(serviceSelectorValue)s"}[$__interval]))
      ||| % config,
    ),

  httpBackendSuccessRatioPercentage(serviceSelectorKey='service', serviceSelectorValue='$service', span=4)::
    local config = {
      serviceSelectorKey: serviceSelectorKey,
      serviceSelectorValue: serviceSelectorValue,
    };

    commonPanels.singlestat(
      title='Incoming Success Rate',
      description='Percentage of successful (non http-5xx) requests',
      colorBackground=true,
      format='percent',
      sparklineShow=false,
      thresholds="99,95",
      colors=[
        '#d44a3a',
        'rgba(237, 129, 40, 0.89)',
        '#299c46',
      ],
      span=4,
      query=|||
        100 - mintel:http_error_rate:percentage:1m{%(serviceSelectorKey)s="%(serviceSelectorValue)s"}
      ||| % config,
    ),
}
