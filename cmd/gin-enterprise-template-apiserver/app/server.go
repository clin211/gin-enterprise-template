package app

import (
	"context"
	"fmt"
	"os"
	"path/filepath"

	"github.com/clin211/gin-enterprise-template/pkg/core"
	"github.com/clin211/gin-enterprise-template/pkg/version"
	"github.com/spf13/cobra"
	"github.com/spf13/viper"
	genericapiserver "k8s.io/apiserver/pkg/server"

	"github.com/clin211/gin-enterprise-template/cmd/gin-enterprise-template-apiserver/app/options"
)

const (
	// defaultHomeDir 定义存储 gin-enterprise-template-apiserver 服务配置的默认目录。
	defaultHomeDir = ".gin-enterprise-template"

	// defaultConfigName 指定 gin-enterprise-template-apiserver 服务的默认配置文件名。
	defaultConfigName = "gin-enterprise-template-apiserver.yaml"
)

// 配置文件的路径
var configFile string

// NewWebServerCommand 创建用于启动应用程序的 *cobra.Command 对象。
func NewWebServerCommand() *cobra.Command {
	// 创建默认的应用程序命令行选项
	opts := options.NewServerOptions()

	cmd := &cobra.Command{
		// 指定命令名称，将出现在帮助信息中
		Use: "gin-enterprise-template-apiserver",
		// 命令的简短描述
		Short: "Please update the short description of the binary file.",
		// 命令的详细描述
		Long: `Please update the detailed description of the binary file.`,
		// 当命令遇到错误时不打印帮助信息。
		// 将此设置为 true 可确保错误立即可见。
		SilenceUsage: true,
		// 指定调用 cmd.Execute() 时要执行的 Run 函数
		RunE: func(cmd *cobra.Command, args []string) error {
			ctx := genericapiserver.SetupSignalContext()

			// 如果传递了 --version 标志，则打印版本信息并退出
			version.PrintAndExitIfRequested()

			// 将 viper 的配置反序列化到 opts
			if err := viper.Unmarshal(opts); err != nil {
				return fmt.Errorf("failed to unmarshal configuration: %w", err)
			}

			// 验证命令行选项
			if err := opts.Validate(); err != nil {
				return fmt.Errorf("invalid options: %w", err)
			}
			if err := opts.OTelOptions.Apply(); err != nil {
				return err
			}
			defer func() {
				_ = opts.OTelOptions.Shutdown(ctx)
			}()

			return run(ctx, opts)
		},
		// 为命令设置参数验证。不需要命令行参数。
		// 例如：./gin-enterprise-template-apiserver param1 param2
		Args: cobra.NoArgs,
	}

	// 初始化配置函数，在每个命令运行时调用
	cobra.OnInitialize(core.OnInitialize(&configFile, "MINIBLOG-V4_APISERVER", searchDirs(), defaultConfigName))

	// cobra 支持持久标志，适用于指定命令及其所有子命令。
	// 建议使用配置文件进行应用程序配置，以便更轻松地管理配置项。
	cmd.PersistentFlags().StringVarP(&configFile, "config", "c", filePath(), "Path to the gin-enterprise-template-apiserver configuration file.")

	// 将服务器选项添加为标志
	opts.AddFlags(cmd.PersistentFlags())

	// 添加 --version 标志
	version.AddFlags(cmd.PersistentFlags())

	return cmd
}

// run 包含初始化和运行服务器的主要逻辑。
func run(ctx context.Context, opts *options.ServerOptions) error {
	// 获取应用程序配置
	// 分离命令行选项和应用程序配置可以更灵活地处理这两种类型的配置。
	cfg, err := opts.Config()
	if err != nil {
		return fmt.Errorf("failed to load configuration: %w", err)
	}

	// 创建并启动服务器
	server, err := cfg.NewServer(ctx)
	if err != nil {
		return fmt.Errorf("failed to create server: %w", err)
	}

	// 运行服务器
	return server.Run(ctx)
}

// searchDirs 返回搜索配置文件的默认目录。
func searchDirs() []string {
	// 获取用户的主目录。
	homeDir, err := os.UserHomeDir()
	// 如果无法获取用户的主目录，打印错误消息并退出程序。
	cobra.CheckErr(err)
	return []string{filepath.Join(homeDir, defaultHomeDir), "."}
}

// filePath 检索默认配置文件的完整路径。
func filePath() string {
	home, err := os.UserHomeDir()
	// 如果无法检索用户的主目录，记录错误并返回空路径。
	cobra.CheckErr(err)
	return filepath.Join(home, defaultHomeDir, defaultConfigName)
}
