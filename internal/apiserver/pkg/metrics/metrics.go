package metrics

import (
	"context"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/metric"
)

type Metrics struct {
	Meter                     metric.Meter
	RESTResourceCreateCounter metric.Int64Counter
	RESTResourceGetCounter    metric.Int64Counter
}

var M *Metrics

// Initialize 初始化 Prometheus 导出器和自定义业务指标。
func Initialize(ctx context.Context, scope string) error {
	meter := otel.Meter(scope + ".metrics")

	// 定义自定义指标
	// Prometheus 指标名称通常遵循以下模式：{subsystem}_{object}_{action}_{unit}
	createCounter, _ := meter.Int64Counter("miniblog_v4_apiserver_resource_create_total", metric.WithDescription("Total number of REST resource create requests"))
	getCount, _ := meter.Int64Counter("miniblog_v4_apiserver_resource_get_total", metric.WithDescription("Total number of REST resource get requests"))

	// 赋值给全局实例
	M = &Metrics{
		Meter:                     meter,
		RESTResourceCreateCounter: createCounter,
		RESTResourceGetCounter:    getCount,
	}

	return nil
}
