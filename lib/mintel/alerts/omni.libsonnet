{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'omni.alerts',
        rules: [
          {
            alert: 'OmniHAProxyBackendResponseTime',
            annotations: {
              runbook_url: '%(runBookBaseURL)s/core/HAProxy.md#haproxybackendresponsetime' % $._config,
              summary: 'HAProxy: 95th percentile of response times is more than 0.5s on {{ $labels.mintel_com_service }} backend.',
            },
            expr: 'haproxy:http_backend_request_seconds_quantile:95{mintel_com_service=~".*omni-web"} > 0.5',
            'for': '10m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'OmniHAProxyBackendResponseTime',
            annotations: {
              runbook_url: '%(runBookBaseURL)s/core/HAProxy.md#haproxybackendresponsetime' % $._config,
              summary: 'HAProxy: 95th percentile of response times is more than 1s on {{ $labels.mintel_com_service }} backend.',
            },
            expr: 'haproxy:http_backend_request_seconds_quantile:95{mintel_com_service=~".*omni-web"} > 1',
            'for': '5m',
            labels: {
              severity: 'critical',
            },
          },
        ],
      },
    ],
  },
}
