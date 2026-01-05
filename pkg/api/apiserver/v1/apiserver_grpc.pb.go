// 由 protoc-gen-go-grpc 代码生成。请勿编辑。
// 版本:
// - protoc-gen-go-grpc v1.6.0
// - protoc             v6.30.0
// 源文件: apiserver/v1/apiserver.proto

package v1

import (
	context "context"
	grpc "google.golang.org/grpc"
	codes "google.golang.org/grpc/codes"
	status "google.golang.org/grpc/status"
	emptypb "google.golang.org/protobuf/types/known/emptypb"
)

// 这是一个编译时断言，用于确保此生成的文件
// 与其编译的 grpc 包兼容。
// 需要 gRPC-Go v1.64.0 或更高版本。
const _ = grpc.SupportPackageIsVersion9

const (
	BlogService_Healthz_FullMethodName      = "/apiserver.v1.BlogService/Healthz"
	BlogService_Login_FullMethodName        = "/apiserver.v1.BlogService/Login"
	BlogService_RefreshToken_FullMethodName = "/apiserver.v1.BlogService/RefreshToken"
	BlogService_CreateUser_FullMethodName   = "/apiserver.v1.BlogService/CreateUser"
	BlogService_GetUser_FullMethodName      = "/apiserver.v1.BlogService/GetUser"
	BlogService_UpdateUser_FullMethodName   = "/apiserver.v1.BlogService/UpdateUser"
	BlogService_DeleteUser_FullMethodName   = "/apiserver.v1.BlogService/DeleteUser"
	BlogService_ListUsers_FullMethodName    = "/apiserver.v1.BlogService/ListUsers"
)

// BlogServiceClient 是 BlogService 服务的客户端 API。
//
// 有关 ctx 使用以及关闭/结束流式 RPC 的语义，请参考 https://pkg.go.dev/google.golang.org/grpc/?tab=doc#ClientConn.NewStream。
type BlogServiceClient interface {
	// 健康检查
	Healthz(ctx context.Context, in *emptypb.Empty, opts ...grpc.CallOption) (*HealthzResponse, error)
	// 用户登录
	Login(ctx context.Context, in *LoginRequest, opts ...grpc.CallOption) (*LoginResponse, error)
	// 刷新令牌
	RefreshToken(ctx context.Context, in *RefreshTokenRequest, opts ...grpc.CallOption) (*RefreshTokenResponse, error)
	// 创建用户
	CreateUser(ctx context.Context, in *CreateUserRequest, opts ...grpc.CallOption) (*CreateUserResponse, error)
	// 获取用户
	GetUser(ctx context.Context, in *GetUserRequest, opts ...grpc.CallOption) (*GetUserResponse, error)
	// 更新用户
	UpdateUser(ctx context.Context, in *UpdateUserRequest, opts ...grpc.CallOption) (*UpdateUserResponse, error)
	// 删除用户
	DeleteUser(ctx context.Context, in *DeleteUserRequest, opts ...grpc.CallOption) (*DeleteUserResponse, error)
	// 列表用户
	ListUsers(ctx context.Context, in *ListUserRequest, opts ...grpc.CallOption) (*ListUserResponse, error)
}

type blogServiceClient struct {
	cc grpc.ClientConnInterface
}

func NewBlogServiceClient(cc grpc.ClientConnInterface) BlogServiceClient {
	return &blogServiceClient{cc}
}

func (c *blogServiceClient) Healthz(ctx context.Context, in *emptypb.Empty, opts ...grpc.CallOption) (*HealthzResponse, error) {
	cOpts := append([]grpc.CallOption{grpc.StaticMethod()}, opts...)
	out := new(HealthzResponse)
	err := c.cc.Invoke(ctx, BlogService_Healthz_FullMethodName, in, out, cOpts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *blogServiceClient) Login(ctx context.Context, in *LoginRequest, opts ...grpc.CallOption) (*LoginResponse, error) {
	cOpts := append([]grpc.CallOption{grpc.StaticMethod()}, opts...)
	out := new(LoginResponse)
	err := c.cc.Invoke(ctx, BlogService_Login_FullMethodName, in, out, cOpts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *blogServiceClient) RefreshToken(ctx context.Context, in *RefreshTokenRequest, opts ...grpc.CallOption) (*RefreshTokenResponse, error) {
	cOpts := append([]grpc.CallOption{grpc.StaticMethod()}, opts...)
	out := new(RefreshTokenResponse)
	err := c.cc.Invoke(ctx, BlogService_RefreshToken_FullMethodName, in, out, cOpts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *blogServiceClient) CreateUser(ctx context.Context, in *CreateUserRequest, opts ...grpc.CallOption) (*CreateUserResponse, error) {
	cOpts := append([]grpc.CallOption{grpc.StaticMethod()}, opts...)
	out := new(CreateUserResponse)
	err := c.cc.Invoke(ctx, BlogService_CreateUser_FullMethodName, in, out, cOpts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *blogServiceClient) GetUser(ctx context.Context, in *GetUserRequest, opts ...grpc.CallOption) (*GetUserResponse, error) {
	cOpts := append([]grpc.CallOption{grpc.StaticMethod()}, opts...)
	out := new(GetUserResponse)
	err := c.cc.Invoke(ctx, BlogService_GetUser_FullMethodName, in, out, cOpts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *blogServiceClient) UpdateUser(ctx context.Context, in *UpdateUserRequest, opts ...grpc.CallOption) (*UpdateUserResponse, error) {
	cOpts := append([]grpc.CallOption{grpc.StaticMethod()}, opts...)
	out := new(UpdateUserResponse)
	err := c.cc.Invoke(ctx, BlogService_UpdateUser_FullMethodName, in, out, cOpts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *blogServiceClient) DeleteUser(ctx context.Context, in *DeleteUserRequest, opts ...grpc.CallOption) (*DeleteUserResponse, error) {
	cOpts := append([]grpc.CallOption{grpc.StaticMethod()}, opts...)
	out := new(DeleteUserResponse)
	err := c.cc.Invoke(ctx, BlogService_DeleteUser_FullMethodName, in, out, cOpts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *blogServiceClient) ListUsers(ctx context.Context, in *ListUserRequest, opts ...grpc.CallOption) (*ListUserResponse, error) {
	cOpts := append([]grpc.CallOption{grpc.StaticMethod()}, opts...)
	out := new(ListUserResponse)
	err := c.cc.Invoke(ctx, BlogService_ListUsers_FullMethodName, in, out, cOpts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

// BlogServiceServer 是 BlogService 服务的服务器 API。
// 所有实现必须嵌入 UnimplementedBlogServiceServer
// 以实现前向兼容。
type BlogServiceServer interface {
	// 健康检查
	Healthz(context.Context, *emptypb.Empty) (*HealthzResponse, error)
	// 用户登录
	Login(context.Context, *LoginRequest) (*LoginResponse, error)
	// 刷新令牌
	RefreshToken(context.Context, *RefreshTokenRequest) (*RefreshTokenResponse, error)
	// 创建用户
	CreateUser(context.Context, *CreateUserRequest) (*CreateUserResponse, error)
	// 获取用户
	GetUser(context.Context, *GetUserRequest) (*GetUserResponse, error)
	// 更新用户
	UpdateUser(context.Context, *UpdateUserRequest) (*UpdateUserResponse, error)
	// 删除用户
	DeleteUser(context.Context, *DeleteUserRequest) (*DeleteUserResponse, error)
	// 列表用户
	ListUsers(context.Context, *ListUserRequest) (*ListUserResponse, error)
	mustEmbedUnimplementedBlogServiceServer()
}

// UnimplementedBlogServiceServer 必须被嵌入以具有
// 前向兼容的实现。
//
// 注意：这应该按值嵌入，而不是按指针嵌入，以避免在调用方法时出现
// 空指针解引用。
type UnimplementedBlogServiceServer struct{}

func (UnimplementedBlogServiceServer) Healthz(context.Context, *emptypb.Empty) (*HealthzResponse, error) {
	return nil, status.Error(codes.Unimplemented, "method Healthz not implemented")
}
func (UnimplementedBlogServiceServer) Login(context.Context, *LoginRequest) (*LoginResponse, error) {
	return nil, status.Error(codes.Unimplemented, "method Login not implemented")
}
func (UnimplementedBlogServiceServer) RefreshToken(context.Context, *RefreshTokenRequest) (*RefreshTokenResponse, error) {
	return nil, status.Error(codes.Unimplemented, "method RefreshToken not implemented")
}
func (UnimplementedBlogServiceServer) CreateUser(context.Context, *CreateUserRequest) (*CreateUserResponse, error) {
	return nil, status.Error(codes.Unimplemented, "method CreateUser not implemented")
}
func (UnimplementedBlogServiceServer) GetUser(context.Context, *GetUserRequest) (*GetUserResponse, error) {
	return nil, status.Error(codes.Unimplemented, "method GetUser not implemented")
}
func (UnimplementedBlogServiceServer) UpdateUser(context.Context, *UpdateUserRequest) (*UpdateUserResponse, error) {
	return nil, status.Error(codes.Unimplemented, "method UpdateUser not implemented")
}
func (UnimplementedBlogServiceServer) DeleteUser(context.Context, *DeleteUserRequest) (*DeleteUserResponse, error) {
	return nil, status.Error(codes.Unimplemented, "method DeleteUser not implemented")
}
func (UnimplementedBlogServiceServer) ListUsers(context.Context, *ListUserRequest) (*ListUserResponse, error) {
	return nil, status.Error(codes.Unimplemented, "method ListUsers not implemented")
}
func (UnimplementedBlogServiceServer) mustEmbedUnimplementedBlogServiceServer() {}
func (UnimplementedBlogServiceServer) testEmbeddedByValue()                     {}

// UnsafeBlogServiceServer 可以被嵌入以选择退出此服务的前向兼容性。
// 不建议使用此接口，因为向 BlogServiceServer 添加方法将
// 导致编译错误。
type UnsafeBlogServiceServer interface {
	mustEmbedUnimplementedBlogServiceServer()
}

func RegisterBlogServiceServer(s grpc.ServiceRegistrar, srv BlogServiceServer) {
	// 如果以下调用发生 panic，表示 UnimplementedBlogServiceServer
	// 是通过指针嵌入的并且为 nil。如果调用了
	// 未实现的方法，这将导致 panic，因此我们在初始化时
	// 测试以防止稍后在运行时由于 I/O 原因而发生。
	if t, ok := srv.(interface{ testEmbeddedByValue() }); ok {
		t.testEmbeddedByValue()
	}
	s.RegisterService(&BlogService_ServiceDesc, srv)
}

func _BlogService_Healthz_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(emptypb.Empty)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(BlogServiceServer).Healthz(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: BlogService_Healthz_FullMethodName,
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(BlogServiceServer).Healthz(ctx, req.(*emptypb.Empty))
	}
	return interceptor(ctx, in, info, handler)
}

func _BlogService_Login_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(LoginRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(BlogServiceServer).Login(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: BlogService_Login_FullMethodName,
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(BlogServiceServer).Login(ctx, req.(*LoginRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _BlogService_RefreshToken_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(RefreshTokenRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(BlogServiceServer).RefreshToken(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: BlogService_RefreshToken_FullMethodName,
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(BlogServiceServer).RefreshToken(ctx, req.(*RefreshTokenRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _BlogService_CreateUser_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(CreateUserRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(BlogServiceServer).CreateUser(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: BlogService_CreateUser_FullMethodName,
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(BlogServiceServer).CreateUser(ctx, req.(*CreateUserRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _BlogService_GetUser_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(GetUserRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(BlogServiceServer).GetUser(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: BlogService_GetUser_FullMethodName,
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(BlogServiceServer).GetUser(ctx, req.(*GetUserRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _BlogService_UpdateUser_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(UpdateUserRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(BlogServiceServer).UpdateUser(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: BlogService_UpdateUser_FullMethodName,
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(BlogServiceServer).UpdateUser(ctx, req.(*UpdateUserRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _BlogService_DeleteUser_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(DeleteUserRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(BlogServiceServer).DeleteUser(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: BlogService_DeleteUser_FullMethodName,
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(BlogServiceServer).DeleteUser(ctx, req.(*DeleteUserRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _BlogService_ListUsers_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(ListUserRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(BlogServiceServer).ListUsers(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: BlogService_ListUsers_FullMethodName,
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(BlogServiceServer).ListUsers(ctx, req.(*ListUserRequest))
	}
	return interceptor(ctx, in, info, handler)
}

// BlogService_ServiceDesc 是 BlogService 服务的 grpc.ServiceDesc。
// 它仅用于直接与 grpc.RegisterService 一起使用，
// 不应被内省或修改（即使作为副本）
var BlogService_ServiceDesc = grpc.ServiceDesc{
	ServiceName: "apiserver.v1.BlogService",
	HandlerType: (*BlogServiceServer)(nil),
	Methods: []grpc.MethodDesc{
		{
			MethodName: "Healthz",
			Handler:    _BlogService_Healthz_Handler,
		},
		{
			MethodName: "Login",
			Handler:    _BlogService_Login_Handler,
		},
		{
			MethodName: "RefreshToken",
			Handler:    _BlogService_RefreshToken_Handler,
		},
		{
			MethodName: "CreateUser",
			Handler:    _BlogService_CreateUser_Handler,
		},
		{
			MethodName: "GetUser",
			Handler:    _BlogService_GetUser_Handler,
		},
		{
			MethodName: "UpdateUser",
			Handler:    _BlogService_UpdateUser_Handler,
		},
		{
			MethodName: "DeleteUser",
			Handler:    _BlogService_DeleteUser_Handler,
		},
		{
			MethodName: "ListUsers",
			Handler:    _BlogService_ListUsers_Handler,
		},
	},
	Streams:  []grpc.StreamDesc{},
	Metadata: "apiserver/v1/apiserver.proto",
}
