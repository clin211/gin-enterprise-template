// Healthz API 定义，包括健康检查响应消息和状态。

// 由 protoc-gen-defaults 代码生成。请勿编辑。

package v1

import (
	"google.golang.org/protobuf/types/known/durationpb"
	"google.golang.org/protobuf/types/known/timestamppb"
	"google.golang.org/protobuf/types/known/wrapperspb"
)

var (
	_ *timestamppb.Timestamp
	_ *durationpb.Duration
	_ *wrapperspb.BoolValue
)

func (x *HealthzResponse) Default() {
}
