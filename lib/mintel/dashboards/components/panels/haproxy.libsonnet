local layout = import 'components/layout.libsonnet';
local commonPanels = import 'components/panels/common.libsonnet';
local promQuery = import 'components/prom_query.libsonnet';
{
  latencyTimeseries(serviceSelectorKey='service', serviceSelectorValue='${service}', interval='5m', span=12)::
    local config = {
      serviceSelectorKey: serviceSelectorKey,
      serviceSelectorValue: serviceSelectorValue,
      mintelComSelector: std.format('mintel_com_service="%s_%s"', ['${namespace}', serviceSelectorValue]),
      backendSelector: std.format('backend=~"%s_%s_[0-9a-zA-Z]+"', ['${namespace}', serviceSelectorValue]),
      interval: interval,
    };

    commonPanels.latencyTimeseries(
      title='HAProxy Latency',
      description='Percentile Latency from HAProxy Ingress',
      yAxisLabel='Time',
      format='s',
      span=span,
      legend_show=true,
      height=300,
      query=|||
        histogram_quantile(0.95,
          sum(
            rate(
              http_backend_request_duration_seconds_bucket{%(backendSelector)s}[%(interval)s]))
        by (backend,job,le))
      ||| % config,
      legendFormat='p95 {{ backend }}',
      intervalFactor=2,
    )
    .addTarget(
      promQuery.target(
        |||
          histogram_quantile(0.75,
          sum(
            rate(
              http_backend_request_duration_seconds_bucket{%(backendSelector)s}-.*%(serviceSelectorValue)s-[0-9].*"}[%(interval)s]))
          by (backend,job,le))
        ||| % config,
        legendFormat='p75 {{ backend }}',
        intervalFactor=2,
      )
    )
    .addTarget(
      promQuery.target(
        |||
          histogram_quantile(0.50,
          sum(
            rate(
              http_backend_request_duration_seconds_bucket{%(backendSelector)s}-.*%(serviceSelectorValue)s-[0-9].*"}[%(interval)s]))
          by (backend,job,le))
        ||| % config,
        legendFormat='p50 {{ backend }}',
        intervalFactor=2,
      )
    ),

  latencyTimeseriesPreRecorded(serviceSelectorKey='service', serviceSelectorValue='${service}', span=12)::
    local config = {
      serviceSelectorKey: serviceSelectorKey,
      serviceSelectorValue: serviceSelectorValue,
      mintelComSelector: std.format('mintel_com_service="%s_%s"', ['${namespace}', serviceSelectorValue]),
      backendSelector: std.format('backend=~"%s_%s_[0-9a-zA-Z]+"', ['${namespace}', serviceSelectorValue]),
    };

    commonPanels.latencyTimeseries(
      title='HAProxy Latency',
      description='Percentile Latency from HAProxy Ingress',
      yAxisLabel='Time',
      format='s',
      span=span,
      legend_show=true,
      height=300,
      query=|||
        haproxy:http_backend_request_seconds_quantile:95{%(mintelComSelector)s}
      ||| % config,
      legendFormat='p95 {{ backend }}',
      intervalFactor=2,
    )
    .addTarget(
      promQuery.target(
        |||
          haproxy:http_backend_request_seconds_quantile:75{%(mintelComSelector)s}
        ||| % config,
        legendFormat='p75 {{ backend }}',
        intervalFactor=2,
      )
    )
    .addTarget(
      promQuery.target(
        |||
          haproxy:http_backend_request_seconds_quantile:50{%(mintelComSelector)s}
        ||| % config,
        legendFormat='p50 {{ backend }}',
        intervalFactor=2,
      )
    ),

  httpResponseStatusTimeseries(serviceSelectorKey='service', serviceSelectorValue='${service}', interval='5m', span=12)::
    local config = {
      serviceSelectorKey: serviceSelectorKey,
      serviceSelectorValue: serviceSelectorValue,
      mintelComSelector: std.format('mintel_com_service="%s_%s"', ['${namespace}', serviceSelectorValue]),
      backendSelector: std.format('backend=~"%s_%s_[0-9a-zA-Z]+"', ['${namespace}', serviceSelectorValue]),
      interval: interval,
    };

    commonPanels.timeseries(
      title='HAProxy Responses',
      description='HTTP Responses from HAProxy Ingress for backend %(serviceSelectorValue)s' % config,
      yAxisLabel='Num Responses',
      span=span,
      legend_show=true,
      height=300,
      query=|||
        sum(
          rate(
            haproxy:haproxy_backend_http_responses_total:counter{%(backendSelector)s}[%(interval)s]
          )
        ) by (code)
      ||| % config,
      legendFormat='{{ code }}',
      intervalFactor=2,
    ),


  httpBackendRequestsPerSecond(serviceSelectorKey='service', serviceSelectorValue='${service}', span=4)::
    local config = {
      serviceSelectorKey: serviceSelectorKey,
      serviceSelectorValue: serviceSelectorValue,
      mintelComSelector: std.format('mintel_com_service="%s_%s"', ['${namespace}', serviceSelectorValue]),
      backendSelector: std.format('backend=~"%s_%s_[0-9a-zA-Z]+"', ['${namespace}', serviceSelectorValue]),
    };
    commonPanels.singlestat(
      title='Incoming Request Volume',
      description='Requests per second (all http-status)',
      colorBackground=true,
      format='rps',
      sparklineShow=false,
      span=span,
      query=|||
        sum(
          rate(
            haproxy:haproxy_backend_http_responses_total:counter{%(backendSelector)s}[$__interval]))
      ||| % config,
    ),

  httpBackendSuccessRatioPercentage(serviceSelectorKey='service', serviceSelectorValue='${service}', span=4)::
    local config = {
      serviceSelectorKey: serviceSelectorKey,
      serviceSelectorValue: serviceSelectorValue,
      mintelComSelector: std.format('mintel_com_service="%s_%s"', ['${namespace}', serviceSelectorValue]),
      backendSelector: std.format('backend=~"%s_%s_[0-9a-zA-Z]+"', ['${namespace}', serviceSelectorValue]),
    };

    commonPanels.singlestat(
      title='Incoming Success Rate',
      description='Percentage of successful (non http-5xx) requests',
      colorBackground=true,
      format='percent',
      sparklineShow=false,
      thresholds='99,95',
      colors=[
        '#d44a3a',
        'rgba(237, 129, 40, 0.89)',
        '#299c46',
      ],
      span=span,
      query=|||
        100 - haproxy:haproxy_backend_http_error_rate:percentage:1m{%(mintelComSelector)s}
      ||| % config,
    ),
}
