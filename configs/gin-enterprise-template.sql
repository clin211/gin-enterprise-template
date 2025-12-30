DO $$
DECLARE r RECORD;
BEGIN -- Drop all tables in correct order to respect foreign key dependencies
FOR r IN
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY CASE
    table_name
    WHEN 'user_login_log' THEN 1
    WHEN 'user_config' THEN 2
    WHEN 'casbin_rule' THEN 3
    WHEN 'user' THEN 4
  END LOOP EXECUTE 'DROP TABLE IF EXISTS "' || r.table_name || '" CASCADE';
RAISE NOTICE 'Dropped table: %',
r.table_name;
END LOOP;
-- Drop all sequences
FOR r IN
SELECT sequence_name
FROM information_schema.sequences
WHERE sequence_schema = 'public' LOOP EXECUTE 'DROP SEQUENCE IF EXISTS "' || r.sequence_name || '" CASCADE';
RAISE NOTICE 'Dropped sequence: %',
r.sequence_name;
END LOOP;
-- Drop extensions
DROP EXTENSION IF EXISTS "uuid-ossp" CASCADE;
END $$;
-- ================================
-- Extensions
-- ================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
-- ================================
-- Sequences
-- ================================
CREATE SEQUENCE "public"."user_id_seq" INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1;
COMMENT ON SEQUENCE "public"."user_id_seq" IS '用户表内部ID序列';
CREATE SEQUENCE "public"."casbin_rule_id_seq" INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1;
COMMENT ON SEQUENCE "public"."casbin_rule_id_seq" IS 'Casbin规则表内部ID序列';
CREATE SEQUENCE "public"."user_login_log_id_seq" INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1;
COMMENT ON SEQUENCE "public"."user_login_log_id_seq" IS '用户登录日志表内部ID序列';
CREATE SEQUENCE "public"."user_config_id_seq" INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1;
COMMENT ON SEQUENCE "public"."user_config_id_seq" IS '用户配置表内部ID序列';
-- ================================
-- Table Definitions
-- ================================
-- User Table (Core table - create first)
CREATE TABLE "public"."user" (
  "id" int8 NOT NULL DEFAULT nextval('user_id_seq'::regclass),
  "user_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "username" varchar(50) NOT NULL,
  "password" varchar(255) NOT NULL,
  "email" varchar(255),
  "phone" varchar(20),
  "avatar" varchar(500),
  "nickname" varchar(100) NOT NULL DEFAULT '',
  "gender" int2 NOT NULL DEFAULT 0,
  "status" int2 NOT NULL DEFAULT 0,
  "last_login_at" timestamptz(6),
  "created_at" timestamptz(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "description" text
);
ALTER TABLE "public"."user" OWNER TO "postgres";
COMMENT ON TABLE "public"."user" IS '用户表，存储用户认证信息、基本资料和应用扩展';
COMMENT ON COLUMN "public"."user"."id" IS '内部主键ID（自增序列）';
COMMENT ON COLUMN "public"."user"."user_id" IS '用户业务唯一UUID';
COMMENT ON COLUMN "public"."user"."username" IS '用户名（唯一，登录用）';
COMMENT ON COLUMN "public"."user"."password" IS '密码哈希（bcrypt加密存储）';
COMMENT ON COLUMN "public"."user"."email" IS '电子邮箱（唯一）';
COMMENT ON COLUMN "public"."user"."phone" IS '手机号（唯一）';
COMMENT ON COLUMN "public"."user"."avatar" IS '头像URL';
COMMENT ON COLUMN "public"."user"."nickname" IS '用户昵称';
COMMENT ON COLUMN "public"."user"."gender" IS '性别（0=未知,1=男,2=女）';
COMMENT ON COLUMN "public"."user"."status" IS '用户状态（0=活跃,1=禁用）';
COMMENT ON COLUMN "public"."user"."last_login_at" IS '最后登录时间';
COMMENT ON COLUMN "public"."user"."created_at" IS '创建时间';
COMMENT ON COLUMN "public"."user"."updated_at" IS '更新时间';
COMMENT ON COLUMN "public"."user"."description" IS '用户描述/简介';
-- User Config Table
CREATE TABLE "public"."user_config" (
  "id" int8 NOT NULL DEFAULT nextval('user_config_id_seq'::regclass),
  "user_id" uuid NOT NULL,
  "config_key" varchar(100) NOT NULL,
  "config_value" jsonb NOT NULL,
  "created_at" timestamptz(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE "public"."user_config" OWNER TO "postgres";
COMMENT ON TABLE "public"."user_config" IS '用户个人配置表，存储用户偏好设置';
COMMENT ON COLUMN "public"."user_config"."id" IS '内部主键ID（自增序列）';
COMMENT ON COLUMN "public"."user_config"."user_id" IS '用户UUID（外键）';
COMMENT ON COLUMN "public"."user_config"."config_key" IS '配置键名（唯一组合）';
COMMENT ON COLUMN "public"."user_config"."config_value" IS '配置值（JSONB格式）';
COMMENT ON COLUMN "public"."user_config"."created_at" IS '创建时间';
COMMENT ON COLUMN "public"."user_config"."updated_at" IS '更新时间';
-- Casbin Rule Table
CREATE TABLE "public"."casbin_rule" (
  "id" int8 NOT NULL DEFAULT nextval('casbin_rule_id_seq'::regclass),
  "ptype" varchar(100) NOT NULL,
  "v0" varchar(100),
  "v1" varchar(100),
  "v2" varchar(100),
  "v3" varchar(100),
  "v4" varchar(100),
  "v5" varchar(100)
);
ALTER TABLE "public"."casbin_rule" OWNER TO "postgres";
COMMENT ON TABLE "public"."casbin_rule" IS 'Casbin权限规则表，作为系统中唯一的权限控制机制，支持RBAC和ABAC策略';
COMMENT ON COLUMN "public"."casbin_rule"."id" IS '内部主键ID（自增序列）';
COMMENT ON COLUMN "public"."casbin_rule"."ptype" IS '规则类型（p=权限, g=角色继承）';
COMMENT ON COLUMN "public"."casbin_rule"."v0" IS '主体（用户/角色）';
COMMENT ON COLUMN "public"."casbin_rule"."v1" IS '资源（对象）';
COMMENT ON COLUMN "public"."casbin_rule"."v2" IS '动作（读/写等）';
COMMENT ON COLUMN "public"."casbin_rule"."v3" IS '扩展字段1（条件等）';
COMMENT ON COLUMN "public"."casbin_rule"."v4" IS '扩展字段2';
COMMENT ON COLUMN "public"."casbin_rule"."v5" IS '扩展字段3';
-- User Login Log Table
CREATE TABLE "public"."user_login_log" (
  "id" int8 NOT NULL DEFAULT nextval('user_login_log_id_seq'::regclass),
  "username" varchar(50),
  "ip_address" inet,
  "user_agent" varchar(1000),
  "status" bool NOT NULL,
  "error_message" text,
  "created_at" timestamptz(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE "public"."user_login_log" OWNER TO "postgres";
COMMENT ON TABLE "public"."user_login_log" IS '用户登录日志表，记录登录尝试和安全信息';
COMMENT ON COLUMN "public"."user_login_log"."id" IS '内部主键ID（自增序列）';
COMMENT ON COLUMN "public"."user_login_log"."username" IS '登录用户名';
COMMENT ON COLUMN "public"."user_login_log"."ip_address" IS '登录IP地址';
COMMENT ON COLUMN "public"."user_login_log"."user_agent" IS '用户代理字符串';
COMMENT ON COLUMN "public"."user_login_log"."status" IS '登录状态（true=成功, false=失败）';
COMMENT ON COLUMN "public"."user_login_log"."error_message" IS '错误消息（失败时）';
COMMENT ON COLUMN "public"."user_login_log"."created_at" IS '登录尝试时间';
-- ================================
-- Primary Key Constraints
-- ================================
ALTER TABLE "public"."user"
ADD CONSTRAINT "user_pkey" PRIMARY KEY ("id");
ALTER TABLE "public"."user_config"
ADD CONSTRAINT "user_config_pkey" PRIMARY KEY ("id");
ALTER TABLE "public"."casbin_rule"
ADD CONSTRAINT "casbin_rule_pkey" PRIMARY KEY ("id");
ALTER TABLE "public"."user_login_log"
ADD CONSTRAINT "user_login_log_pkey" PRIMARY KEY ("id");
-- ================================
-- Unique Constraints
-- ================================
ALTER TABLE "public"."user"
ADD CONSTRAINT "uni_user_user_id" UNIQUE ("user_id");
ALTER TABLE "public"."user"
ADD CONSTRAINT "user_username_key" UNIQUE ("username");
ALTER TABLE "public"."user"
ADD CONSTRAINT "user_email_key" UNIQUE ("email");
ALTER TABLE "public"."user"
ADD CONSTRAINT "user_phone_key" UNIQUE ("phone");
ALTER TABLE "public"."user_config"
ADD CONSTRAINT "user_config_user_id_config_key_key" UNIQUE ("user_id", "config_key");
-- ================================
-- Foreign Key Constraints
-- ================================
ALTER TABLE "public"."user_config"
ADD CONSTRAINT "user_config_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user" ("user_id") ON DELETE CASCADE ON UPDATE NO ACTION;
-- ================================
-- Indexes
-- ================================
-- User indexes
CREATE INDEX CONCURRENTLY "idx_user_email" ON "public"."user" ("email")
WHERE "email" IS NOT NULL;
CREATE INDEX CONCURRENTLY "idx_user_phone" ON "public"."user" ("phone")
WHERE "phone" IS NOT NULL;
CREATE INDEX CONCURRENTLY "idx_user_status" ON "public"."user" ("status");
CREATE INDEX CONCURRENTLY "idx_user_status_last_login" ON "public"."user" ("status", "last_login_at" DESC);
-- User config indexes
CREATE INDEX CONCURRENTLY "idx_user_config_user" ON "public"."user_config" ("user_id");
-- User login log indexes
CREATE INDEX CONCURRENTLY "idx_user_login_log_username" ON "public"."user_login_log" ("username")
WHERE "username" IS NOT NULL;
CREATE INDEX CONCURRENTLY "idx_user_login_log_created" ON "public"."user_login_log" ("created_at" DESC);
CREATE INDEX CONCURRENTLY "idx_user_login_log_status_created" ON "public"."user_login_log" ("status", "created_at" DESC);
-- Casbin indexes (optimized for permission checks)
CREATE INDEX CONCURRENTLY "idx_casbin_rule_ptype" ON "public"."casbin_rule" ("ptype");
CREATE INDEX CONCURRENTLY "idx_casbin_rule_ptype_v0_v1" ON "public"."casbin_rule" ("ptype", "v0", "v1");
CREATE INDEX CONCURRENTLY "idx_casbin_rule_g_v0" ON "public"."casbin_rule" ("ptype", "v0")
WHERE "ptype" = 'g';
-- ================================
-- Sequence Ownership
-- ================================
ALTER SEQUENCE "public"."user_id_seq" OWNED BY "public"."user"."id";
SELECT setval('"public"."user_id_seq"', 1, false);
ALTER SEQUENCE "public"."casbin_rule_id_seq" OWNED BY "public"."casbin_rule"."id";
SELECT setval('"public"."casbin_rule_id_seq"', 1, false);
ALTER SEQUENCE "public"."user_login_log_id_seq" OWNED BY "public"."user_login_log"."id";
SELECT setval('"public"."user_login_log_id_seq"', 1, false);
ALTER SEQUENCE "public"."user_config_id_seq" OWNED BY "public"."user_config"."id";
SELECT setval('"public"."user_config_id_seq"', 1, false);