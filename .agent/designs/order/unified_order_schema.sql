-- 统一订单中心数据库结构定义 (V5.3)
-- 包含：核心主子订单、凭证履约、售后逆向单、通道基础配置表
-- 变更点 (V5.3)：ChannelConfig 增加 extra_config 扩展字段

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for o_order (主订单表)
-- ----------------------------
DROP TABLE IF EXISTS `o_order`;
CREATE TABLE `o_order` (
  `order_id` bigint(20) NOT NULL COMMENT '主键(雪花算法)',
  `order_no` varchar(64) NOT NULL COMMENT '平台统一订单流水号',
  `parent_order_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '父订单ID，0代表根主单',
  `prod_id` varchar(64) DEFAULT '0' COMMENT '产品线ID(API自调时赋值)',
  `app_id` varchar(64) DEFAULT '0' COMMENT '应用模块ID(API自调时赋值)',
  `channel_code` varchar(32) NOT NULL COMMENT '外部渠道标识 (如: DOUYIN, MEITUAN, MINIAPP)',
  `channel_app_id` varchar(128) DEFAULT NULL COMMENT '渠道开放平台应用ID(如抖音app_id)',
  `channel_order_no` varchar(128) DEFAULT NULL COMMENT '外部渠道方原生流水号',
  `channel_user_id` varchar(128) DEFAULT NULL COMMENT '外部渠道方的用户唯一标识(如OpenID)',
  `total_amount` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '订单商品总原价',
  `pay_amount` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '用户实际支付总金额',
  `discount_amount` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '整体通用立减折扣',
  `coupon_amount` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '各类优惠券总抵扣',
  `user_id` varchar(64) DEFAULT '0' COMMENT '内部核心用户ID (API自调时赋值)',
  `user_account` varchar(64) DEFAULT NULL COMMENT '用户外显账号/归属手机号',
  `order_status` varchar(32) NOT NULL COMMENT '主单状态(PENDING, PAID, DELIVERING, COMPLETED, CANCELED, REFUNDING, REFUNDED)',
  `pay_type` tinyint(2) DEFAULT NULL COMMENT '支付手段枚举 (1-微信, 2-支付宝, 3-抖音原生等)',
  `client_ip` varchar(64) DEFAULT NULL COMMENT '下单时的防刷客户端IP',
  `extend_attr` json DEFAULT NULL COMMENT '富文本扩展属性JSON',
  `industry_type` varchar(32) DEFAULT NULL COMMENT '行业类型(SCENIC_TICKET景区票/HOTEL酒店/RESTAURANT餐饮/ACTIVITY活动/COMBO套餐/OTHER)',
  `merchant_id` varchar(64) DEFAULT '0' COMMENT '平台内部商户ID',
  `merchant_name` varchar(128) DEFAULT NULL COMMENT '下单时平台商户名称快照',
  `channel_merchant_id` varchar(128) DEFAULT NULL COMMENT '渠道侧商家ID(如抖音商家ID)',
  `channel_merchant_name` varchar(128) DEFAULT NULL COMMENT '渠道侧商家名称快照',
  `shop_id` varchar(64) DEFAULT '0' COMMENT '平台内部店铺ID',
  `shop_name` varchar(128) DEFAULT NULL COMMENT '下单时平台店铺名称快照',
  `channel_shop_id` varchar(128) DEFAULT NULL COMMENT '渠道侧门店ID(如抖音poi_id)',
  `channel_shop_name` varchar(128) DEFAULT NULL COMMENT '渠道侧门店名称快照',
  `order_subject` varchar(256) DEFAULT NULL COMMENT '商品SPU信息说明，如"故宫一日游成人票 等3件"',
  `channel_biz_type` varchar(64) DEFAULT NULL COMMENT '渠道侧原始业务类型快照(如抖音GROUP_BUY/CALENDAR)',
  `tenant_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '租户ID',
  `create_user` bigint(20) DEFAULT '0' COMMENT '创建者',
  `modify_user` bigint(20) DEFAULT '0' COMMENT '修改者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `modify_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '逻辑删除标识 (0-正常 1-已删除)',
  PRIMARY KEY (`order_id`),
  UNIQUE KEY `uk_order_no` (`order_no`),
  KEY `idx_user_tenant` (`user_id`, `tenant_id`),
  KEY `idx_prod_app` (`prod_id`, `app_id`),
  KEY `idx_parent_order_id` (`parent_order_id`),
  KEY `idx_channel_code_order_no` (`channel_code`,`channel_order_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单主表';

-- ----------------------------
-- Table structure for o_order_item (子订单明细表)
-- ----------------------------
DROP TABLE IF EXISTS `o_order_item`;
CREATE TABLE `o_order_item` (
  `order_item_id` bigint(20) NOT NULL COMMENT '主键(雪花算法)',
  `order_id` bigint(20) NOT NULL COMMENT '归属的主订单ID',
  `order_no` varchar(64) NOT NULL COMMENT '冗余：平台统一订单流水号',
  `prod_id` varchar(64) DEFAULT '0' COMMENT '产品线环境隔离',
  `app_id` varchar(64) DEFAULT '0' COMMENT '应用模块隔离',
  `spu_id` varchar(128) NOT NULL COMMENT '商品SPU ID',
  `sku_id` varchar(128) NOT NULL DEFAULT '0' COMMENT '售卖规格SKU ID',
  `sub_sku_list` json DEFAULT NULL COMMENT '组合票子SKU集合，元素含subSkuId/subSpuId/quantity/subSkuName',
  `sku_name` varchar(128) DEFAULT '未知' COMMENT '购买时的商品/规格名称',
  `spu_pic` varchar(512) DEFAULT NULL COMMENT '商品主图快照URL',
  `price` decimal(12,2) NOT NULL DEFAULT '0.00' COMMENT '商品单价',
  `quantity` int(11) NOT NULL DEFAULT '1' COMMENT '购买数量',
  `coupon_amount` decimal(12,2) DEFAULT '0.00' COMMENT '优惠分摊金额',
  `user_id` varchar(64) DEFAULT '0' COMMENT '冗余：所属用户ID',
  `refund_status` varchar(32) DEFAULT NULL COMMENT '子项独立售后状态',
  `channel_spu_id` varchar(128) DEFAULT NULL COMMENT '下单时快照：外部渠道SPU ID',
  `channel_sku_id` varchar(128) DEFAULT NULL COMMENT '下单时快照：外部渠道SKU ID',
  `channel_order_no` varchar(128) DEFAULT NULL COMMENT '渠道订单号',
  `channel_item_id` varchar(128) DEFAULT NULL COMMENT '渠道订单项/子单ID',
  `channel_sub_sku_list` json DEFAULT NULL COMMENT '渠道组合商品子SKU集合JSON',
  `sku_type` varchar(32) NOT NULL DEFAULT 'NORMAL' COMMENT 'SKU类型(NORMAL普通商品/COMBO组合商品)',
  `sku_attr` json DEFAULT NULL COMMENT '销售属性KV',
  `spu_name` varchar(256) DEFAULT NULL COMMENT '商品SPU名称快照',
  `spu_snapshot` json DEFAULT NULL COMMENT '下单时商品完整快照JSON',
  `fulfillment_type` varchar(32) DEFAULT 'VOUCHER' COMMENT '履约方式(VOUCHER发码/NONE不立即履约)',
  `tenant_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '所属租户ID',
  `create_user` bigint(20) DEFAULT '0' COMMENT '创建记录的用户',
  `modify_user` bigint(20) DEFAULT '0' COMMENT '最后修改的用户',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `modify_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '删除标识',
  PRIMARY KEY (`order_item_id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_spu_sku` (`spu_id`, `sku_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='子订单明细表';

-- ----------------------------
-- Table structure for o_order_status_log (订单状态变更日志表)
-- ----------------------------
DROP TABLE IF EXISTS `o_order_status_log`;
CREATE TABLE `o_order_status_log` (
  `log_id` bigint(20) NOT NULL COMMENT '主键(雪花算法)',
  `order_id` bigint(20) NOT NULL COMMENT '订单ID',
  `order_no` varchar(64) NOT NULL COMMENT '订单号',
  `from_status` varchar(32) DEFAULT NULL COMMENT '变更前状态',
  `to_status` varchar(32) NOT NULL COMMENT '变更后状态',
  `operator` varchar(64) DEFAULT NULL COMMENT '操作人',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `tenant_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '租户ID',
  `create_user` bigint(20) DEFAULT '0' COMMENT '创建人',
  `modify_user` bigint(20) DEFAULT '0' COMMENT '修改人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `modify_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '逻辑删除',
  PRIMARY KEY (`log_id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_order_no` (`order_no`),
  KEY `idx_order_status_flow` (`order_id`, `from_status`, `to_status`),
  KEY `idx_tenant_create_time` (`tenant_id`, `create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单状态变更日志表';

-- ----------------------------
DROP TABLE IF EXISTS `o_fulfillment_item`;
CREATE TABLE `o_fulfillment_item` (
      `fulfillment_item_id` bigint(20) NOT NULL COMMENT '主键(雪花算法)',

      `fulfillment_type` varchar(32) NOT NULL DEFAULT 'VOUCHER' COMMENT '履约类型(VOUCHER/NONE)',
      `expected_quantity` int(11) NOT NULL DEFAULT '1' COMMENT '应履约数量',
      `fulfillment_status` varchar(32) NOT NULL DEFAULT 'PENDING' COMMENT '履约状态(PENDING/PARTIAL_ISSUED/ISSUED/PARTIAL_VERIFIED/VERIFIED/PARTIAL_REFUNDED/REFUNDED/CLOSED)',
      `extend_attr` json DEFAULT NULL COMMENT '履约扩展信息，不重要的sku属性等(JSON)',

      `order_id` bigint(20) NOT NULL COMMENT '归属主订单ID',
      `order_no` varchar(64) NOT NULL COMMENT '冗余：主订单号',
      `order_item_id` bigint(20) NOT NULL COMMENT '归属订单项ID',
      `spu_id` varchar(128) NOT NULL DEFAULT '0' COMMENT '商品SPU ID',
      `sku_id` varchar(128) NOT NULL DEFAULT '0' COMMENT '商品SKU ID',
      `sub_sku_id` varchar(128) NOT NULL DEFAULT '0' COMMENT '组合商品子SKU ID，普通票默认0',

      `channel_code` varchar(32) DEFAULT 'SELF' COMMENT '订单来源渠道',
      `channel_order_no` varchar(128) DEFAULT '0' COMMENT '渠道订单号',
      `channel_item_id` varchar(128) DEFAULT '0' COMMENT '渠道子单/渠道订单项ID',
      `channel_sku_id` varchar(128) DEFAULT '0' COMMENT '渠道SKU快照',
      `channel_sub_sku_id` varchar(128) DEFAULT '0' COMMENT '组合商品子SKU ID，普通票默认0',

      `tenant_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '租户ID',
      `create_user` bigint(20) NOT NULL DEFAULT '0' COMMENT '创建人',
      `modify_user` bigint(20) NOT NULL DEFAULT '0' COMMENT '修改人',
      `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
      `modify_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
      `deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '逻辑删除',

      PRIMARY KEY (`fulfillment_item_id`),
      KEY `idx_order_id` (`order_id`),
      KEY `idx_order_item_id` (`order_item_id`),
      KEY `idx_order_no` (`order_no`),
      KEY `idx_spu_sku_subsku` (`spu_id`, `sku_id`, `sub_sku_id`),
      KEY `idx_channel_item` (`channel_code`, `channel_order_no`, `channel_item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单履约项表';

DROP TABLE IF EXISTS `o_fulfillment_voucher`;
CREATE TABLE `o_fulfillment_voucher` (
     `voucher_id` bigint(20) NOT NULL COMMENT '主键(雪花算法)',
     `fulfillment_item_id` bigint(20) NOT NULL COMMENT '归属履约项ID',

     `ticket_type` varchar(32) NOT NULL DEFAULT 'NORMAL' COMMENT '票型(NORMAL/COMBO)',
     `voucher_code` varchar(128) NOT NULL COMMENT '内部统一券码/核销码',
     `project_id` varchar(128) DEFAULT NULL COMMENT '渠道项目标识，当前可约定为voucherId',
     `status` varchar(32) NOT NULL COMMENT '状态(USABLE/VERIFIED/EXPIRED/LOCKED/INVALID)',
     `valid_start_time` datetime DEFAULT NULL COMMENT '生效时间',
     `valid_end_time` datetime DEFAULT NULL COMMENT '失效时间',
     `user_id` varchar(64) NOT NULL DEFAULT '0' COMMENT '所属用户ID',

     `order_id` bigint(20) NOT NULL COMMENT '冗余：主订单ID',
     `order_no` varchar(64) NOT NULL COMMENT '冗余：主订单号',
     `order_item_id` bigint(20) NOT NULL COMMENT '冗余：归属订单项ID',
     `spu_id` varchar(128) NOT NULL DEFAULT '0' COMMENT '商品SPU ID',
     `sku_id` varchar(128) NOT NULL DEFAULT '0' COMMENT '商品SKU ID',
     `sub_sku_id` varchar(128) NOT NULL DEFAULT '0' COMMENT '组合票子SKU ID',

     `channel_code` varchar(32) DEFAULT 'SELF' COMMENT '订单来源渠道',
     `channel_voucher_id` varchar(128) DEFAULT NULL COMMENT '渠道侧码ID，如抖音 certificate_id',
     `channel_order_no` varchar(128) DEFAULT '0' COMMENT '渠道订单号',

     `tenant_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '租户ID',
     `create_user` bigint(20) NOT NULL DEFAULT '0' COMMENT '创建人',
     `modify_user` bigint(20) NOT NULL DEFAULT '0' COMMENT '修改人',
     `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
     `modify_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
     `deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '逻辑删除',

     PRIMARY KEY (`voucher_id`),
     UNIQUE KEY `uk_voucher_code` (`voucher_code`),
     UNIQUE KEY `uk_channel_voucher_id` (`channel_code`, `channel_voucher_id`),
     KEY `idx_fulfillment_item_id` (`fulfillment_item_id`),
     KEY `idx_order_item_id` (`order_item_id`),
     KEY `idx_order_no` (`order_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='实际码券表';

-- ----------------------------
-- Table structure for o_verify_log (核销记录流水表)
-- ----------------------------
DROP TABLE IF EXISTS `o_verify_log`;
CREATE TABLE `o_verify_log` (
  `log_id` bigint(20) NOT NULL COMMENT '主键(雪花算法)',
  `voucher_id` bigint(20) NOT NULL COMMENT '关联凭证',
  `prod_id` varchar(64) NOT NULL DEFAULT '0' COMMENT '产品线隔离',
  `app_id` varchar(64) NOT NULL DEFAULT '0' COMMENT '应用隔离',
  `verify_channel` varchar(32) NOT NULL COMMENT '来源(GATE, MINIAPP, ADMIN, API)',
  `verify_device_id` varchar(64) DEFAULT NULL COMMENT '设备号',
  `verify_result` tinyint(1) NOT NULL COMMENT '1-成功, 0-失败',
  `channel_notify_status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '异步回写: 0-不回写, 1-待, 2-成, 3-败',
  `tenant_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '所属租户ID',
  `create_user` bigint(20) NOT NULL DEFAULT '0' COMMENT '操作人ID',
  `modify_user` bigint(20) DEFAULT '0' COMMENT '最后修改人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '核销创建时间',
  `modify_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '逻辑删除',
  PRIMARY KEY (`log_id`),
  KEY `idx_voucher_id` (`voucher_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='凭证核销流水';

-- ----------------------------
-- Table structure for o_refund_apply (退款售后单表)
-- ----------------------------
DROP TABLE IF EXISTS `o_refund_apply`;
CREATE TABLE `o_refund_apply` (
  `refund_id` bigint(20) NOT NULL COMMENT '主键(雪花算法)',
  `refund_no` varchar(64) NOT NULL COMMENT '内部统一售后单号',
  `order_id` bigint(20) NOT NULL COMMENT '关联主单',
  `order_no` varchar(64) NOT NULL DEFAULT '0' COMMENT '冗余：主订单号',
  `original_order_status` varchar(32) NOT NULL DEFAULT 'PAID' COMMENT '申请退款前的订单状态',
  `order_item_id` bigint(20) DEFAULT NULL COMMENT '关联的具体子单(可选)',
  `prod_id` varchar(64) NOT NULL DEFAULT '0' COMMENT '产品线上下文',
  `app_id` varchar(64) NOT NULL DEFAULT '0' COMMENT '应用上下文',
  `user_id` varchar(64) NOT NULL COMMENT '冗余：所属用户ID',
  `refund_amount` decimal(12,2) NOT NULL COMMENT '本次申请退款金额',
  `refund_reason` varchar(255) DEFAULT NULL COMMENT '退款原因描述',
  `audit_remark` varchar(255) DEFAULT NULL COMMENT '审核备注/驳回原因',
  `channel_refund_no` varchar(64) DEFAULT NULL COMMENT '支付中心/渠道退款流水号',
  `refund_status` varchar(32) NOT NULL COMMENT 'APPLYING, APPROVED, SUCCESS, REJECTED',
  `tenant_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '租户隔离',
  `create_user` bigint(20) NOT NULL DEFAULT '0' COMMENT '申请人',
  `modify_user` bigint(20) DEFAULT '0' COMMENT '最后修改人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
  `modify_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '逻辑删除',
  PRIMARY KEY (`refund_id`),
  UNIQUE KEY `uk_refund_no` (`refund_no`),
  KEY `idx_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='逆向售后跟踪表';

-- ----------------------------
-- Table structure for o_voucher_rule (码券规则表)
-- ----------------------------
DROP TABLE IF EXISTS `o_voucher_rule`;
CREATE TABLE `o_voucher_rule` (
  `voucher_rule_id` bigint(20) NOT NULL COMMENT '主键(雪花算法)',
  `scope_type` varchar(32) NOT NULL COMMENT '作用域类型(PROD/APP/SPU/SKU)',
  `scope_id` varchar(128) NOT NULL COMMENT '作用域ID',
  `voucher_validity_type` tinyint(2) NOT NULL COMMENT '效期类型：1-当日有效 2-指定日期 3-N日内有效',
  `voucher_validity_days` int(11) NOT NULL DEFAULT '0' COMMENT '有效天数(效期类型=3时使用)',
  `tenant_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '租户隔离',
  `create_user` bigint(20) NOT NULL DEFAULT '0' COMMENT '配置人',
  `modify_user` bigint(20) NOT NULL DEFAULT '0' COMMENT '修改人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '规则创建时间',
  `modify_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '逻辑处理',
  PRIMARY KEY (`voucher_rule_id`),
  KEY `idx_voucher_rule_match` (`scope_type`, `scope_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='码券规则配置表';

-- ----------------------------
-- Table structure for o_refund_audit_rule (退款审核规则表)
-- ----------------------------
DROP TABLE IF EXISTS `o_refund_audit_rule`;
CREATE TABLE `o_refund_audit_rule` (
  `refund_audit_rule_id` bigint(20) NOT NULL COMMENT '主键(雪花算法)',
  `scope_type` varchar(32) NOT NULL COMMENT '作用域类型(PROD/APP/SPU/SKU)',
  `scope_id` varchar(128) NOT NULL COMMENT '作用域ID',
  `refund_policy` tinyint(2) NOT NULL COMMENT '退改政策',
  `need_refund_audit` tinyint(1) NOT NULL DEFAULT '0' COMMENT '1-需要人工审, 0-自动',
  `tenant_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '租户隔离',
  `create_user` bigint(20) NOT NULL DEFAULT '0' COMMENT '配置人',
  `modify_user` bigint(20) NOT NULL DEFAULT '0' COMMENT '修改人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '规则创建时间',
  `modify_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '逻辑处理',
  PRIMARY KEY (`refund_audit_rule_id`),
  KEY `idx_refund_audit_rule_match` (`scope_type`, `scope_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='退款审核规则配置表';

-- ----------------------------
-- Table structure for o_fulfillment_rule (履约规则表)
-- ----------------------------
DROP TABLE IF EXISTS `o_fulfillment_rule`;
CREATE TABLE `o_fulfillment_rule` (
  `fulfillment_rule_id` bigint(20) NOT NULL COMMENT '主键(雪花算法)',
  `scope_type` varchar(32) NOT NULL COMMENT '作用域类型(PROD/APP/SPU/SKU)',
  `scope_id` varchar(128) NOT NULL COMMENT '作用域ID',
  `fulfillment_type` varchar(32) NOT NULL DEFAULT 'VOUCHER' COMMENT '履约类型(VOUCHER发码,NONE不立即履约)',
  `tenant_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '租户隔离',
  `create_user` bigint(20) NOT NULL DEFAULT '0' COMMENT '配置人',
  `modify_user` bigint(20) NOT NULL DEFAULT '0' COMMENT '修改人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '规则创建时间',
  `modify_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '逻辑处理',
  PRIMARY KEY (`fulfillment_rule_id`),
  KEY `idx_fulfillment_rule_match` (`scope_type`, `scope_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='履约规则配置表';

-- ----------------------------
-- Table structure for o_channel_config (渠道连接配置表)
-- ----------------------------
DROP TABLE IF EXISTS `o_channel_config`;
CREATE TABLE `o_channel_config` (
  `config_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `channel_code` varchar(32) NOT NULL COMMENT '如: DOUYIN',
  `app_id` varchar(128) NOT NULL COMMENT '外部渠道方分发的身份标识AppID',
  `app_secret` varchar(255) DEFAULT NULL COMMENT '渠道密钥',
  `private_key` text COMMENT '由外部分配或内部自持的私钥',
  `public_key` text COMMENT '由外部分配或内部自持的公钥',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '状态1启用0禁用',
  `extra_config` json DEFAULT NULL COMMENT '扩展配置(JSON格式)',
  `tenant_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '租户隔离',
  `create_user` bigint(20) NOT NULL DEFAULT '0' COMMENT '创建人',
  `modify_user` bigint(20) NOT NULL DEFAULT '0' COMMENT '修改人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `modify_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
  `deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '逻辑删除',
  PRIMARY KEY (`config_id`),
  UNIQUE KEY `uk_channel_code` (`channel_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='各渠道通讯密钥配置';

-- ----------------------------
-- Table structure for o_channel_sku_mapping (外部渠道产品与大域SKU映射表)
-- ----------------------------
DROP TABLE IF EXISTS `o_channel_sku_mapping`;
CREATE TABLE `o_channel_sku_mapping` (
  `mapping_id` bigint(20) NOT NULL COMMENT '主键(雪花算法)',
  `channel_code` varchar(32) NOT NULL COMMENT '挂靠售卖的对外渠道',
  `prod_id` varchar(64) NOT NULL DEFAULT '0' COMMENT '内部产品线关联',
  `app_id` varchar(64) NOT NULL DEFAULT '0' COMMENT '内部应用模块关联',
  `channel_spu_id` varchar(128) NOT NULL COMMENT '外部渠道方(如抖音)商品SPU ID',
  `channel_sku_id` varchar(128) NOT NULL DEFAULT '0' COMMENT '外部渠道方规格SKU ID',
  `spu_id` varchar(128) NOT NULL COMMENT '强制锚定到系统内部的底层SPU',
  `sku_id` varchar(128) NOT NULL DEFAULT '0' COMMENT '精细描绘到内部具体SKU(无SKU则赋0)',
  `tenant_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '多租户ID',
  `create_user` bigint(20) NOT NULL DEFAULT '0' COMMENT '映射建立者',
  `modify_user` bigint(20) NOT NULL DEFAULT '0' COMMENT '映射维护者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `modify_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '删除标识',
  PRIMARY KEY (`mapping_id`),
  UNIQUE KEY `uk_chan_sku` (`channel_code`, `channel_spu_id`, `channel_sku_id`),
  KEY `idx_spu_sku` (`spu_id`, `sku_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='外部业务品种SKU映射库';

-- ----------------------------
-- Table structure for o_shopping_cart (购物车库)
-- ----------------------------
DROP TABLE IF EXISTS `o_shopping_cart`;
CREATE TABLE `o_shopping_cart` (
  `cart_id` bigint(20) NOT NULL COMMENT '雪花ID',
  `prod_id` varchar(64) NOT NULL DEFAULT '0' COMMENT '产品线上下文',
  `app_id` varchar(64) NOT NULL DEFAULT '0' COMMENT '应用上下文',
  `user_id` varchar(64) NOT NULL COMMENT '车主内部ID',
  `spu_id` varchar(128) NOT NULL COMMENT '内部SPU ID',
  `sku_id` varchar(128) NOT NULL DEFAULT '0' COMMENT '规格参数ID',
  `quantity` int(11) NOT NULL DEFAULT '1' COMMENT '加购数量',
  `tenant_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '多租户隔离',
  `create_user` bigint(20) NOT NULL DEFAULT '0' COMMENT '创建记录的用户',
  `modify_user` bigint(20) NOT NULL DEFAULT '0' COMMENT '最后修改的用户',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '加车时间',
  `modify_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '同步更新时间',
  `deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '移除标识',
  PRIMARY KEY (`cart_id`),
  KEY `idx_user_cart` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='购物车逻辑库';

SET FOREIGN_KEY_CHECKS = 1;
