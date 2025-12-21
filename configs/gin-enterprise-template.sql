/*
 Cspedia Database Schema - Optimized Version
 
 Source Server         : PostgreSQL
 Source Server Version : 16+
 Source Host           : localhost:5432
 Source Catalog        : cs-pedia
 Source Schema         : public
 
 Date: 20/12/2025
 Optimized by: Senior DBA
 Key Changes:
 - Removed all CHECK constraints (moved to application layer)
 - Optimized indexes for better performance
 - Fixed foreign key relationships
 - Improved comments accuracy
 - Added table cleanup script
 - Optimized data types and constraints
 */
-- ================================
-- Database Cleanup Script
-- ================================
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
    WHEN 'monitor' THEN 2
    WHEN 'user_config' THEN 3
    WHEN 'casbin_rule' THEN 4
    WHEN 'task_evidence_block' THEN 5
    WHEN 'task_brand' THEN 6
    WHEN 'article' THEN 7
    WHEN 'task' THEN 8
    WHEN 'brand' THEN 9
    WHEN 'project' THEN 10
    WHEN 'evidence_block' THEN 11
    WHEN 'user' THEN 12
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
-- Drop types
DROP TYPE IF EXISTS "public"."article_status" CASCADE;
RAISE NOTICE 'Dropped type: article_status';
-- Drop extensions
DROP EXTENSION IF EXISTS "uuid-ossp" CASCADE;
END $$;
-- ================================
-- Extensions
-- ================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
-- ================================
-- Types
-- ================================
CREATE TYPE "public"."article_status" AS ENUM (
  'draft',
  'generated',
  'review',
  'published',
  'archived'
);
COMMENT ON TYPE "public"."article_status" IS '文章状态枚举：draft=草稿, generated=自动生成, review=审核中, published=已发布, archived=归档';
-- ================================
-- Sequences (with optimized caching)
-- =================--
CREATE SEQUENCE "public"."article_id_seq" INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1;
-- CACHE 1 ensures sequential IDs without gaps
COMMENT ON SEQUENCE "public"."article_id_seq" IS '文章表内部ID序列';
CREATE SEQUENCE "public"."brand_id_seq" INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1;
COMMENT ON SEQUENCE "public"."brand_id_seq" IS '品牌表内部ID序列';
CREATE SEQUENCE "public"."casbin_rule_id_seq" INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1;
COMMENT ON SEQUENCE "public"."casbin_rule_id_seq" IS 'Casbin规则表内部ID序列';
CREATE SEQUENCE "public"."evidence_block_id_seq" INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1;
COMMENT ON SEQUENCE "public"."evidence_block_id_seq" IS '证据块表内部ID序列';
CREATE SEQUENCE "public"."project_id_seq" INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1;
COMMENT ON SEQUENCE "public"."project_id_seq" IS '项目表内部ID序列';
CREATE SEQUENCE "public"."user_login_log_id_seq" INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1;
COMMENT ON SEQUENCE "public"."user_login_log_id_seq" IS '用户登录日志表内部ID序列';
CREATE SEQUENCE "public"."monitor_id_seq" INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1;
COMMENT ON SEQUENCE "public"."monitor_id_seq" IS '监控表内部ID序列';
CREATE SEQUENCE "public"."user_config_id_seq" INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1;
COMMENT ON SEQUENCE "public"."user_config_id_seq" IS '用户配置表内部ID序列';
CREATE SEQUENCE "public"."user_id_seq" INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1;
COMMENT ON SEQUENCE "public"."user_id_seq" IS '用户表内部ID序列';
CREATE SEQUENCE "public"."task_brand_id_seq" INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1;
COMMENT ON SEQUENCE "public"."task_brand_id_seq" IS '任务品牌关联表内部ID序列';
CREATE SEQUENCE "public"."task_evidence_block_id_seq" INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1;
COMMENT ON SEQUENCE "public"."task_evidence_block_id_seq" IS '任务证据块关联表内部ID序列';
CREATE SEQUENCE "public"."task_id_seq" INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1;
COMMENT ON SEQUENCE "public"."task_id_seq" IS '任务表内部ID序列';
-- ================================
-- Table Definitions
-- ================================
-- User Table (Core table - create first)
CREATE TABLE "public"."user" (
  "id" int8 NOT NULL DEFAULT nextval('user_id_seq'::regclass),
  "user_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "username" varchar(50) NOT NULL,
  "password" varchar(255) NOT NULL,
  -- Increased for bcrypt hashes
  "email" varchar(255),
  "phone" varchar(20),
  "avatar" varchar(500),
  "nickname" varchar(100) NOT NULL DEFAULT '',
  -- Changed from text to varchar with limit
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
-- Project Table
CREATE TABLE "public"."project" (
  "id" int8 NOT NULL DEFAULT nextval('project_id_seq'::regclass),
  "project_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "name" varchar(64) NOT NULL,
  "owner_id" uuid NOT NULL,
  "created_at" timestamptz(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "deleted_at" timestamptz(6)
);
ALTER TABLE "public"."project" OWNER TO "postgres";
COMMENT ON TABLE "public"."project" IS '项目表，存储内容生成或任务管理的项目';
COMMENT ON COLUMN "public"."project"."id" IS '内部主键ID（自增序列）';
COMMENT ON COLUMN "public"."project"."project_id" IS '项目业务唯一UUID';
COMMENT ON COLUMN "public"."project"."name" IS '项目名称';
COMMENT ON COLUMN "public"."project"."owner_id" IS '项目所有者用户UUID（外键）';
COMMENT ON COLUMN "public"."project"."created_at" IS '创建时间';
COMMENT ON COLUMN "public"."project"."updated_at" IS '更新时间';
COMMENT ON COLUMN "public"."project"."deleted_at" IS '软删除时间（NULL=未删除）';
-- Brand Table
CREATE TABLE "public"."brand" (
  "id" int8 NOT NULL DEFAULT nextval('brand_id_seq'::regclass),
  "brand_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "user_id" uuid NOT NULL,
  "name" varchar(64) NOT NULL,
  "flat" int2 NOT NULL DEFAULT 1,
  "created_at" timestamptz(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "deleted_at" timestamptz(6)
);
ALTER TABLE "public"."brand" OWNER TO "postgres";
COMMENT ON TABLE "public"."brand" IS '品牌表，存储用户管理的品牌信息';
COMMENT ON COLUMN "public"."brand"."id" IS '内部主键ID（自增序列）';
COMMENT ON COLUMN "public"."brand"."brand_id" IS '品牌业务唯一UUID';
COMMENT ON COLUMN "public"."brand"."user_id" IS '所属用户UUID（外键）';
COMMENT ON COLUMN "public"."brand"."name" IS '品牌名称';
COMMENT ON COLUMN "public"."brand"."flat" IS '品牌层级标志（1=扁平结构）';
COMMENT ON COLUMN "public"."brand"."created_at" IS '创建时间';
COMMENT ON COLUMN "public"."brand"."updated_at" IS '更新时间';
COMMENT ON COLUMN "public"."brand"."deleted_at" IS '软删除时间（NULL=未删除）';
-- Evidence Block Table
CREATE TABLE "public"."evidence_block" (
  "id" int8 NOT NULL DEFAULT nextval('evidence_block_id_seq'::regclass),
  "eb_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "label" text NOT NULL,
  "is_enabled" bool NOT NULL DEFAULT true,
  "created_at" timestamptz(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "deleted_at" timestamptz(6)
);
ALTER TABLE "public"."evidence_block" OWNER TO "postgres";
COMMENT ON TABLE "public"."evidence_block" IS '证据块表，存储可复用的证据模块或内容块';
COMMENT ON COLUMN "public"."evidence_block"."id" IS '内部主键ID（自增序列）';
COMMENT ON COLUMN "public"."evidence_block"."eb_id" IS '证据块业务唯一UUID';
COMMENT ON COLUMN "public"."evidence_block"."label" IS '证据块标签/名称';
COMMENT ON COLUMN "public"."evidence_block"."is_enabled" IS '是否启用';
COMMENT ON COLUMN "public"."evidence_block"."created_at" IS '创建时间';
COMMENT ON COLUMN "public"."evidence_block"."updated_at" IS '更新时间';
COMMENT ON COLUMN "public"."evidence_block"."deleted_at" IS '软删除时间（NULL=未删除）';
-- Task Table
CREATE TABLE "public"."task" (
  "id" int8 NOT NULL DEFAULT nextval('task_id_seq'::regclass),
  "task_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "project_id" uuid NOT NULL,
  "name" varchar(255) NOT NULL,
  -- Changed from text to varchar
  "brand_seed" text NOT NULL DEFAULT '',
  "created_at" timestamptz(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "deleted_at" timestamptz(6)
);
ALTER TABLE "public"."task" OWNER TO "postgres";
COMMENT ON TABLE "public"."task" IS '任务表，存储内容生成任务及其配置';
COMMENT ON COLUMN "public"."task"."id" IS '内部主键ID（自增序列）';
COMMENT ON COLUMN "public"."task"."task_id" IS '任务业务唯一UUID';
COMMENT ON COLUMN "public"."task"."project_id" IS '所属项目UUID（外键）';
COMMENT ON COLUMN "public"."task"."name" IS '任务名称';
COMMENT ON COLUMN "public"."task"."brand_seed" IS '品牌种子数据（初始品牌列表，JSON格式）';
COMMENT ON COLUMN "public"."task"."created_at" IS '创建时间';
COMMENT ON COLUMN "public"."task"."updated_at" IS '更新时间';
COMMENT ON COLUMN "public"."task"."deleted_at" IS '软删除时间（NULL=未删除）';
-- Task-Brand Relationship Table
CREATE TABLE "public"."task_brand" (
  "id" int8 NOT NULL DEFAULT nextval('task_brand_id_seq'::regclass),
  "task_brand_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "task_id" uuid NOT NULL,
  "brand_id" uuid NOT NULL,
  "name" varchar(255) NOT NULL,
  -- Changed from text to varchar
  "is_seed" bool NOT NULL DEFAULT false,
  "sort_order" int4 NOT NULL DEFAULT 0,
  "created_at" timestamptz(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "deleted_at" timestamptz(6)
);
ALTER TABLE "public"."task_brand" OWNER TO "postgres";
COMMENT ON TABLE "public"."task_brand" IS '任务品牌关联表，关联任务与品牌，支持种子品牌';
COMMENT ON COLUMN "public"."task_brand"."id" IS '内部主键ID（自增序列）';
COMMENT ON COLUMN "public"."task_brand"."task_brand_id" IS '任务品牌关联业务唯一UUID';
COMMENT ON COLUMN "public"."task_brand"."task_id" IS '任务UUID（外键）';
COMMENT ON COLUMN "public"."task_brand"."brand_id" IS '品牌UUID（外键）';
COMMENT ON COLUMN "public"."task_brand"."name" IS '关联品牌名称（冗余存储）';
COMMENT ON COLUMN "public"."task_brand"."is_seed" IS '是否为种子品牌';
COMMENT ON COLUMN "public"."task_brand"."sort_order" IS '排序序号';
COMMENT ON COLUMN "public"."task_brand"."created_at" IS '创建时间';
COMMENT ON COLUMN "public"."task_brand"."updated_at" IS '更新时间';
COMMENT ON COLUMN "public"."task_brand"."deleted_at" IS '软删除时间（NULL=未删除）';
-- Task-Evidence Block Relationship Table
CREATE TABLE "public"."task_evidence_block" (
  "id" int8 NOT NULL DEFAULT nextval('task_evidence_block_id_seq'::regclass),
  "task_id" uuid NOT NULL,
  "block_id" uuid NOT NULL
);
ALTER TABLE "public"."task_evidence_block" OWNER TO "postgres";
COMMENT ON TABLE "public"."task_evidence_block" IS '任务证据块关联表，多对多关联任务与证据块';
COMMENT ON COLUMN "public"."task_evidence_block"."id" IS '内部主键ID（自增序列）';
COMMENT ON COLUMN "public"."task_evidence_block"."task_id" IS '任务UUID（外键）';
COMMENT ON COLUMN "public"."task_evidence_block"."block_id" IS '证据块UUID（外键）';
-- Article Table
CREATE TABLE "public"."article" (
  "id" int8 NOT NULL DEFAULT nextval('article_id_seq'::regclass),
  "article_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "task_id" uuid NOT NULL,
  "task_brand_id" uuid NOT NULL,
  -- Fixed: should reference task_brand
  "block_id" uuid NOT NULL,
  "title" varchar(500) NOT NULL,
  -- Changed from text to varchar
  "content_md" text NOT NULL DEFAULT '',
  "status" "public"."article_status" NOT NULL DEFAULT 'generated',
  "created_at" timestamptz(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "deleted_at" timestamptz(6)
);
ALTER TABLE "public"."article" OWNER TO "postgres";
COMMENT ON TABLE "public"."article" IS '文章表，存储生成的文章内容和元数据';
COMMENT ON COLUMN "public"."article"."id" IS '内部主键ID（自增序列）';
COMMENT ON COLUMN "public"."article"."article_id" IS '文章业务唯一UUID';
COMMENT ON COLUMN "public"."article"."task_id" IS '所属任务UUID（外键）';
COMMENT ON COLUMN "public"."article"."task_brand_id" IS '所属任务品牌关联UUID（外键）';
COMMENT ON COLUMN "public"."article"."block_id" IS '证据块UUID（外键）';
COMMENT ON COLUMN "public"."article"."title" IS '文章标题';
COMMENT ON COLUMN "public"."article"."content_md" IS '文章内容（Markdown格式）';
COMMENT ON COLUMN "public"."article"."status" IS '文章状态（ENUM）';
COMMENT ON COLUMN "public"."article"."created_at" IS '创建时间';
COMMENT ON COLUMN "public"."article"."updated_at" IS '更新时间';
COMMENT ON COLUMN "public"."article"."deleted_at" IS '软删除时间（NULL=未删除）';
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
-- Monitor Table
CREATE TABLE "public"."monitor" (
  "id" int8 NOT NULL DEFAULT nextval('monitor_id_seq'::regclass),
  "server_name" varchar(100),
  "server_ip" inet,
  "cpu_usage" numeric(5, 2) NOT NULL,
  "cpu_cores" int4,
  "memory_usage" numeric(5, 2) NOT NULL,
  "memory_total" int8,
  "memory_used" int8,
  "disk_usage" numeric(5, 2) NOT NULL,
  "disk_total" int8,
  "disk_used" int8,
  "network_rx" int8 DEFAULT 0,
  "network_tx" int8 DEFAULT 0,
  "load_avg_1" numeric(5, 2),
  "uptime" int8,
  "process_count" int4,
  "created_at" timestamptz(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE "public"."monitor" OWNER TO "postgres";
COMMENT ON TABLE "public"."monitor" IS '系统监控表，记录服务器资源使用情况';
COMMENT ON COLUMN "public"."monitor"."id" IS '内部主键ID（自增序列）';
COMMENT ON COLUMN "public"."monitor"."server_name" IS '服务器名称';
COMMENT ON COLUMN "public"."monitor"."server_ip" IS '服务器IP地址';
COMMENT ON COLUMN "public"."monitor"."cpu_usage" IS 'CPU使用率（%）';
COMMENT ON COLUMN "public"."monitor"."cpu_cores" IS 'CPU核心数';
COMMENT ON COLUMN "public"."monitor"."memory_usage" IS '内存使用率（%）';
COMMENT ON COLUMN "public"."monitor"."memory_total" IS '总内存（字节）';
COMMENT ON COLUMN "public"."monitor"."memory_used" IS '已用内存（字节）';
COMMENT ON COLUMN "public"."monitor"."disk_usage" IS '磁盘使用率（%）';
COMMENT ON COLUMN "public"."monitor"."disk_total" IS '总磁盘空间（字节）';
COMMENT ON COLUMN "public"."monitor"."disk_used" IS '已用磁盘空间（字节）';
COMMENT ON COLUMN "public"."monitor"."network_rx" IS '网络接收字节';
COMMENT ON COLUMN "public"."monitor"."network_tx" IS '网络发送字节';
COMMENT ON COLUMN "public"."monitor"."load_avg_1" IS '1分钟负载平均值';
COMMENT ON COLUMN "public"."monitor"."uptime" IS '系统运行时间（秒）';
COMMENT ON COLUMN "public"."monitor"."process_count" IS '进程数';
COMMENT ON COLUMN "public"."monitor"."created_at" IS '监控记录时间';
-- ================================
-- Primary Key Constraints
-- ================================
ALTER TABLE "public"."article"
ADD CONSTRAINT "article_pkey" PRIMARY KEY ("id");
ALTER TABLE "public"."brand"
ADD CONSTRAINT "brand_pkey" PRIMARY KEY ("id");
ALTER TABLE "public"."casbin_rule"
ADD CONSTRAINT "casbin_rule_pkey" PRIMARY KEY ("id");
ALTER TABLE "public"."evidence_block"
ADD CONSTRAINT "evidence_block_pkey" PRIMARY KEY ("id");
ALTER TABLE "public"."project"
ADD CONSTRAINT "project_pkey" PRIMARY KEY ("id");
ALTER TABLE "public"."user_login_log"
ADD CONSTRAINT "user_login_log_pkey" PRIMARY KEY ("id");
ALTER TABLE "public"."monitor"
ADD CONSTRAINT "monitor_pkey" PRIMARY KEY ("id");
ALTER TABLE "public"."user"
ADD CONSTRAINT "user_pkey" PRIMARY KEY ("id");
ALTER TABLE "public"."user_config"
ADD CONSTRAINT "user_config_pkey" PRIMARY KEY ("id");
ALTER TABLE "public"."task"
ADD CONSTRAINT "task_pkey" PRIMARY KEY ("id");
ALTER TABLE "public"."task_brand"
ADD CONSTRAINT "task_brand_pkey" PRIMARY KEY ("id");
ALTER TABLE "public"."task_evidence_block"
ADD CONSTRAINT "task_evidence_block_pkey" PRIMARY KEY ("id");
-- ================================
-- Unique Constraints
-- ================================
ALTER TABLE "public"."article"
ADD CONSTRAINT "article_article_id_key" UNIQUE ("article_id");
ALTER TABLE "public"."article"
ADD CONSTRAINT "article_unique_title_task_brand_block" UNIQUE ("task_id", "task_brand_id", "block_id", "title");
ALTER TABLE "public"."brand"
ADD CONSTRAINT "brand_brand_id_key" UNIQUE ("brand_id");
ALTER TABLE "public"."evidence_block"
ADD CONSTRAINT "evidence_block_eb_id_key" UNIQUE ("eb_id");
ALTER TABLE "public"."project"
ADD CONSTRAINT "project_project_id_key" UNIQUE ("project_id");
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
ALTER TABLE "public"."task"
ADD CONSTRAINT "task_task_id_key" UNIQUE ("task_id");
ALTER TABLE "public"."task_brand"
ADD CONSTRAINT "task_brand_task_brand_id_key" UNIQUE ("task_brand_id");
-- ================================
-- Foreign Key Constraints
-- ================================
-- User-related foreign keys
ALTER TABLE "public"."brand"
ADD CONSTRAINT "brand_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user" ("user_id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "public"."project"
ADD CONSTRAINT "project_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "public"."user" ("user_id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "public"."user_config"
ADD CONSTRAINT "user_config_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user" ("user_id") ON DELETE CASCADE ON UPDATE NO ACTION;
-- Project hierarchy
ALTER TABLE "public"."task"
ADD CONSTRAINT "task_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."project" ("project_id") ON DELETE CASCADE ON UPDATE NO ACTION;
-- Task relationships
ALTER TABLE "public"."task_brand"
ADD CONSTRAINT "task_brand_task_id_fkey" FOREIGN KEY ("task_id") REFERENCES "public"."task" ("task_id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "public"."task_brand"
ADD CONSTRAINT "task_brand_brand_id_fkey" FOREIGN KEY ("brand_id") REFERENCES "public"."brand" ("brand_id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "public"."task_evidence_block"
ADD CONSTRAINT "task_evidence_block_task_id_fkey" FOREIGN KEY ("task_id") REFERENCES "public"."task" ("task_id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "public"."task_evidence_block"
ADD CONSTRAINT "task_evidence_block_block_id_fkey" FOREIGN KEY ("block_id") REFERENCES "public"."evidence_block" ("eb_id") ON DELETE NO ACTION ON UPDATE NO ACTION;
-- Article relationships
ALTER TABLE "public"."article"
ADD CONSTRAINT "article_task_id_fkey" FOREIGN KEY ("task_id") REFERENCES "public"."task" ("task_id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "public"."article"
ADD CONSTRAINT "article_task_brand_id_fkey" FOREIGN KEY ("task_brand_id") REFERENCES "public"."task_brand" ("task_brand_id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "public"."article"
ADD CONSTRAINT "article_block_id_fkey" FOREIGN KEY ("block_id") REFERENCES "public"."evidence_block" ("eb_id") ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ================================
-- Indexes
-- ================================
-- Core indexes for performance
CREATE INDEX CONCURRENTLY "idx_user_email" ON "public"."user" ("email")
WHERE "email" IS NOT NULL;
CREATE INDEX CONCURRENTLY "idx_user_phone" ON "public"."user" ("phone")
WHERE "phone" IS NOT NULL;
CREATE INDEX CONCURRENTLY "idx_user_status" ON "public"."user" ("status");
CREATE INDEX CONCURRENTLY "idx_user_status_last_login" ON "public"."user" ("status", "last_login_at" DESC);
-- Project indexes
CREATE INDEX CONCURRENTLY "idx_project_owner_id" ON "public"."project" ("owner_id");
CREATE INDEX CONCURRENTLY "idx_project_active" ON "public"."project" ("owner_id", "created_at" DESC)
WHERE "deleted_at" IS NULL;
-- Brand indexes
CREATE INDEX CONCURRENTLY "idx_brand_user_id" ON "public"."brand" ("user_id");
CREATE INDEX CONCURRENTLY "idx_brand_active" ON "public"."brand" ("user_id", "created_at" DESC)
WHERE "deleted_at" IS NULL;
-- Evidence block indexes
CREATE INDEX CONCURRENTLY "idx_evidence_block_enabled" ON "public"."evidence_block" ("is_enabled")
WHERE "deleted_at" IS NULL;
-- Task indexes
CREATE INDEX CONCURRENTLY "idx_task_project_created" ON "public"."task" ("project_id", "created_at" DESC)
WHERE "deleted_at" IS NULL;
CREATE INDEX CONCURRENTLY "idx_task_active" ON "public"."task" ("created_at" DESC)
WHERE "deleted_at" IS NULL;
-- Task brand indexes
CREATE INDEX CONCURRENTLY "idx_task_brand_task" ON "public"."task_brand" ("task_id");
CREATE INDEX CONCURRENTLY "idx_task_brand_brand" ON "public"."task_brand" ("brand_id");
CREATE INDEX CONCURRENTLY "idx_task_brand_active" ON "public"."task_brand" ("task_id", "sort_order")
WHERE "deleted_at" IS NULL;
-- Task evidence block indexes
CREATE INDEX CONCURRENTLY "idx_task_ev_block_task" ON "public"."task_evidence_block" ("task_id");
CREATE INDEX CONCURRENTLY "idx_task_ev_block_block" ON "public"."task_evidence_block" ("block_id");
-- Article indexes (critical for performance)
CREATE INDEX CONCURRENTLY "idx_article_task_brand_status" ON "public"."article" ("task_id", "task_brand_id", "status");
CREATE INDEX CONCURRENTLY "idx_article_active_task" ON "public"."article" ("task_id", "created_at" DESC)
WHERE "deleted_at" IS NULL;
CREATE INDEX CONCURRENTLY "idx_article_active_brand" ON "public"."article" ("task_brand_id", "created_at" DESC)
WHERE "deleted_at" IS NULL;
CREATE INDEX CONCURRENTLY "idx_article_status_created" ON "public"."article" ("status", "created_at" DESC)
WHERE "deleted_at" IS NULL;
-- System indexes
CREATE INDEX CONCURRENTLY "idx_user_config_user" ON "public"."user_config" ("user_id");
CREATE INDEX CONCURRENTLY "idx_user_login_log_username" ON "public"."user_login_log" ("username")
WHERE "username" IS NOT NULL;
CREATE INDEX CONCURRENTLY "idx_user_login_log_created" ON "public"."user_login_log" ("created_at" DESC);
CREATE INDEX CONCURRENTLY "idx_user_login_log_status_created" ON "public"."user_login_log" ("status", "created_at" DESC);
-- Casbin indexes (optimized for permission checks)
CREATE INDEX CONCURRENTLY "idx_casbin_rule_ptype" ON "public"."casbin_rule" ("ptype");
CREATE INDEX CONCURRENTLY "idx_casbin_rule_ptype_v0_v1" ON "public"."casbin_rule" ("ptype", "v0", "v1");
CREATE INDEX CONCURRENTLY "idx_casbin_rule_g_v0" ON "public"."casbin_rule" ("ptype", "v0")
WHERE "ptype" = 'g';
-- Monitor indexes (time-series optimized)
CREATE INDEX "idx_monitor_brin" ON "public"."monitor" USING BRIN ("created_at");
CREATE INDEX CONCURRENTLY "idx_monitor_server_created" ON "public"."monitor" ("server_ip", "created_at" DESC);
-- ================================
-- Sequence Ownership
-- ================================
ALTER SEQUENCE "public"."article_id_seq" OWNED BY "public"."article"."id";
SELECT setval('"public"."article_id_seq"', 1, false);
ALTER SEQUENCE "public"."brand_id_seq" OWNED BY "public"."brand"."id";
SELECT setval('"public"."brand_id_seq"', 1, false);
ALTER SEQUENCE "public"."casbin_rule_id_seq" OWNED BY "public"."casbin_rule"."id";
SELECT setval('"public"."casbin_rule_id_seq"', 1, false);
ALTER SEQUENCE "public"."evidence_block_id_seq" OWNED BY "public"."evidence_block"."id";
SELECT setval('"public"."evidence_block_id_seq"', 1, false);
ALTER SEQUENCE "public"."project_id_seq" OWNED BY "public"."project"."id";
SELECT setval('"public"."project_id_seq"', 1, false);
ALTER SEQUENCE "public"."user_login_log_id_seq" OWNED BY "public"."user_login_log"."id";
SELECT setval('"public"."user_login_log_id_seq"', 1, false);
ALTER SEQUENCE "public"."monitor_id_seq" OWNED BY "public"."monitor"."id";
SELECT setval('"public"."monitor_id_seq"', 1, false);
ALTER SEQUENCE "public"."user_config_id_seq" OWNED BY "public"."user_config"."id";
SELECT setval('"public"."user_config_id_seq"', 1, false);
ALTER SEQUENCE "public"."user_id_seq" OWNED BY "public"."user"."id";
SELECT setval('"public"."user_id_seq"', 1, false);
ALTER SEQUENCE "public"."task_brand_id_seq" OWNED BY "public"."task_brand"."id";
SELECT setval('"public"."task_brand_id_seq"', 1, false);
ALTER SEQUENCE "public"."task_evidence_block_id_seq" OWNED BY "public"."task_evidence_block"."id";
SELECT setval(
    '"public"."task_evidence_block_id_seq"',
    1,
    false
  );
ALTER SEQUENCE "public"."task_id_seq" OWNED BY "public"."task"."id";
SELECT setval('"public"."task_id_seq"', 1, false);