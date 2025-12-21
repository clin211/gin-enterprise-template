package user

import (
	"context"

	"github.com/clin211/gin-enterprise-template/pkg/store/where"

	v1 "github.com/clin211/gin-enterprise-template/pkg/api/apiserver/v1"
)

// Update 实现 UserBiz 接口中的 Update 方法.
func (b *userBiz) Update(ctx context.Context, rq *v1.UpdateUserRequest) (*v1.UpdateUserResponse, error) {
	userM, err := b.store.User().Get(ctx, where.T(ctx))
	if err != nil {
		return nil, err
	}

	if rq.Username != nil {
		userM.Username = rq.GetUsername()
	}
	if rq.Email != nil {
		email := rq.GetEmail()
		userM.Email = &email
	}
	if rq.Nickname != nil {
		userM.Nickname = rq.GetNickname()
	}
	if rq.Phone != nil {
		phone := rq.GetPhone()
		userM.Phone = &phone
	}

	if err := b.store.User().Update(ctx, userM); err != nil {
		return nil, err
	}

	return &v1.UpdateUserResponse{}, nil
}
