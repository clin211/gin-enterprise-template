package main

import (
	"os"

	"github.com/clin211/gin-enterprise-template/cmd/gin-enterprise-template-apiserver/app"
)

// Go 程序的默认入口点。作为阅读项目代码的起点。
func main() {
	command := app.NewWebServerCommand()

	// 执行命令并处理错误。
	if err := command.Execute(); err != nil {
		// 如果发生错误则退出程序。
		// 返回退出代码，以便其他程序（例如 bash 脚本）
		// 可以根据退出代码确定服务状态。
		os.Exit(1)
	}
}
