{
  sli_slo: {
    sli_ingress_responses_total_rate_metric_name: 'ingress:backend_responses_total_by_code:rate',
    sli_ingress_responses_total_ratio_rate_metric_name: 'ingress:backend_responses_ratio_by_code:rate',
    sli_ingress_responses_errors_ratio_rate_metric_name: 'sli:ingress:backend_responses_errors_percentage:rate',
    sli_ingress_responses_latency_rate_metric_name: 'ingress:backend_responses_duration_milliseconds:rate',
    sli_ingress_responses_latency_percentile_metric_name: 'sli:ingress:backend_responses_duration_milliseconds:pctl',
    sli_quantiles: ['0.50', '0.75', '0.90', '0.95', '0.99'],
    slo_ingress_responses_errors_threshold_metric_name: 'slo:ingress:backend_responses_errors:threshold',
    slo_ingress_responses_latency_threshold_metric_name: 'slo:ingress:backend_responses_latency:threshold',
    slo_ingress_responses_errors_ok_metric_name: 'slo:ingress:backend_responses_errors:ok',
    slo_ingress_responses_latency_ok_metric_name: 'slo:ingress:backend_responses_latency:ok',
    slo_ingress_responses_combined_metric_name: 'slo:ingress:backend_responses_combined:ok',
    common_service_label: 'backend_service',
    haproxy: {
      job_selector: 'job=~"haproxy-(exporter|fluentd)"',
      service_name_format: '%s-%s-%s',
      service_label: 'backend',
      responses_total_metric_name: 'haproxy_backend_http_responses_total',
      responses_exclude_selector: 'backend!~"(error|stats|.*default-backend)"',
      responses_total_error_label: 'code',
      responses_total_error_value: '5xx',
      responses_total_rate_sum_by_labels: 'job, code, backend',
      responses_total_ratio_rate_sum_by_labels: 'job, ingress_type, backend',
      responses_errors_ratio_rate_sum_by_labels: 'job, ingress_type, backend',
      responses_latency_duration_metric_name: 'http_backend_request_duration_seconds_bucket',
      responses_latency_multiplier: 1000,  // Haproxy represent this field in seconds
      interval: '2m',
    },
    contour: {
      job_selector: 'job="contour-ingress"',
      service_name_format: '%s_%s_%s',
      service_label: 'envoy_cluster_name',
      responses_total_metric_name: 'envoy_cluster_upstream_rq_xx',
      responses_exclude_selector: 'envoy_cluster_name!~"(ingress-controller_contour_8001)"',
      responses_total_error_label: 'envoy_response_code_class',
      responses_total_error_value: '5',
      responses_total_rate_sum_by_labels: 'job, envoy_response_code_class, envoy_cluster_name',
      responses_total_ratio_rate_sum_by_labels: 'job, ingress_type, envoy_cluster_name',
      responses_errors_ratio_rate_sum_by_labels: 'job, ingress_type, envoy_cluster_name',
      responses_latency_duration_metric_name: 'envoy_cluster_upstream_rq_time_bucket',
      responses_latency_multiplier: 1,  // Contour already represent this field in milliseconds
      interval: '1m',
    },
  },
}
