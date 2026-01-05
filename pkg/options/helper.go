package options

import (
	"fmt"
	"net"
	"strings"

	netutils "k8s.io/utils/net"
)

// 定义单位常量。
const (
	_   = iota // 忽略 onex.iota
	KiB = 1 << (10 * iota)
	MiB
	GiB
	TiB
)

func Join(prefixes ...string) string {
	joined := strings.Join(prefixes, ".")
	if joined != "" {
		joined += "."
	}

	return joined
}

// ValidateAddress 接受字符串形式的地址并验证它。
// 如果输入地址不是有效的 :port 或 IP:port 格式，则返回错误。
// 它还检查地址的主机部分是否是有效的 IP 地址，以及端口号是否有效。
func ValidateAddress(addr string) error {
	host, port, err := net.SplitHostPort(addr)
	if err != nil {
		return fmt.Errorf("%q is not in a valid format (:port or ip:port): %w", addr, err)
	}
	if host != "" && netutils.ParseIPSloppy(host) == nil {
		return fmt.Errorf("%q is not a valid IP address", host)
	}
	if _, err := netutils.ParsePort(port, true); err != nil {
		return fmt.Errorf("%q is not a valid number", port)
	}

	return nil
}

// CreateListener 根据给定地址创建网络监听器并返回它和端口。
func CreateListener(addr string) (net.Listener, int, error) {
	network := "tcp"

	ln, err := net.Listen(network, addr)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to listen on %v: %w", addr, err)
	}

	// 获取端口
	tcpAddr, ok := ln.Addr().(*net.TCPAddr)
	if !ok {
		_ = ln.Close()

		return nil, 0, fmt.Errorf("invalid listen address: %q", ln.Addr().String())
	}

	return ln, tcpAddr.Port, nil
}
