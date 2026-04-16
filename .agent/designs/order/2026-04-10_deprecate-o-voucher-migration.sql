-- o_voucher deprecation migration
-- Purpose:
-- 1. Add channel snapshot columns to o_order_item.
-- 2. Create o_fulfillment_item and o_fulfillment_voucher.
-- 3. Migrate existing o_voucher data into the new fulfillment tables.
-- 4. Drop deprecated o_voucher.
--
-- Run on MySQL 8.x. For MySQL versions without ALTER TABLE ADD COLUMN IF NOT EXISTS,
-- execute the ALTER statements manually after checking information_schema.

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- 1. o_order_item compatibility columns
-- ----------------------------
ALTER TABLE `o_order_item`
  ADD COLUMN IF NOT EXISTS `channel_order_no` varchar(128) DEFAULT NULL COMMENT '渠道订单号' AFTER `channel_sku_id`,
  ADD COLUMN IF NOT EXISTS `channel_item_id` varchar(128) DEFAULT NULL COMMENT '渠道订单项/子单ID' AFTER `channel_order_no`,
  ADD COLUMN IF NOT EXISTS `channel_sub_sku_list` json DEFAULT NULL COMMENT '渠道组合商品子SKU集合JSON' AFTER `channel_item_id`,
  ADD COLUMN IF NOT EXISTS `sku_type` varchar(32) NOT NULL DEFAULT 'NORMAL' COMMENT 'SKU类型(NORMAL普通商品/COMBO组合商品)' AFTER `channel_sub_sku_list`;

-- ----------------------------
-- 2. New fulfillment item table
-- ----------------------------
CREATE TABLE IF NOT EXISTS `o_fulfillment_item` (
  `fulfillment_item_id` bigint(20) NOT NULL COMMENT '主键(雪花算法)',
  `fulfillment_type` varchar(32) NOT NULL DEFAULT 'VOUCHER' COMMENT '履约类型(VOUCHER/NONE)',
  `expected_quantity` int(11) NOT NULL DEFAULT '1' COMMENT '应履约数量',
  `fulfillment_status` varchar(32) NOT NULL DEFAULT 'PENDING' COMMENT '履约状态(PENDING/PARTIAL_ISSUED/ISSUED/PARTIAL_VERIFIED/VERIFIED/PARTIAL_REFUNDED/REFUNDED/CLOSED)',
  `extend_attr` json DEFAULT NULL COMMENT '履约扩展信息JSON',
  `order_id` bigint(20) NOT NULL COMMENT '归属主订单ID',
  `order_no` varchar(64) NOT NULL COMMENT '冗余：主订单号',
  `order_item_id` bigint(20) NOT NULL COMMENT '归属订单项ID',
  `spu_id` varchar(128) NOT NULL DEFAULT '0' COMMENT '商品SPU ID',
  `sku_id` varchar(128) NOT NULL DEFAULT '0' COMMENT '商品SKU ID',
  `sub_sku_id` varchar(128) NOT NULL DEFAULT '0' COMMENT '组合商品子SKU ID',
  `channel_code` varchar(32) DEFAULT 'SELF' COMMENT '订单来源渠道',
  `channel_order_no` varchar(128) DEFAULT '0' COMMENT '渠道订单号',
  `channel_item_id` varchar(128) DEFAULT '0' COMMENT '渠道子单/渠道订单项ID',
  `channel_sku_id` varchar(128) DEFAULT '0' COMMENT '渠道SKU快照',
  `channel_sub_sku_id` varchar(128) DEFAULT '0' COMMENT '渠道组合商品子SKU ID',
  `tenant_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '租户ID',
  `create_user` bigint(20) NOT NULL DEFAULT '0' COMMENT '创建人',
  `modify_user` bigint(20) NOT NULL DEFAULT '0' COMMENT '修改人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `modify_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '逻辑删除',
  PRIMARY KEY (`fulfillment_item_id`),
  UNIQUE KEY `uk_order_item_subsku` (`order_item_id`, `sub_sku_id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_order_item_id` (`order_item_id`),
  KEY `idx_order_no` (`order_no`),
  KEY `idx_spu_sku_subsku` (`spu_id`, `sku_id`, `sub_sku_id`),
  KEY `idx_channel_item` (`channel_code`, `channel_order_no`, `channel_item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单履约项表';

-- ----------------------------
-- 3. New fulfillment voucher table
-- ----------------------------
CREATE TABLE IF NOT EXISTS `o_fulfillment_voucher` (
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
-- 4. Migrate old o_voucher data when the table still exists
-- ----------------------------
DROP PROCEDURE IF EXISTS `migrate_o_voucher_to_fulfillment`;
DELIMITER $$
CREATE PROCEDURE `migrate_o_voucher_to_fulfillment`()
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.tables
    WHERE table_schema = DATABASE()
      AND table_name = 'o_voucher'
  ) THEN
    INSERT IGNORE INTO `o_fulfillment_item` (
      `fulfillment_item_id`, `fulfillment_type`, `expected_quantity`, `fulfillment_status`, `extend_attr`,
      `order_id`, `order_no`, `order_item_id`, `spu_id`, `sku_id`, `sub_sku_id`,
      `channel_code`, `channel_order_no`, `channel_item_id`, `channel_sku_id`, `channel_sub_sku_id`,
      `tenant_id`, `create_user`, `modify_user`, `create_time`, `modify_time`, `deleted`
    )
    SELECT
      MIN(v.`voucher_id`) AS `fulfillment_item_id`,
      'VOUCHER' AS `fulfillment_type`,
      COUNT(1) AS `expected_quantity`,
      CASE
        WHEN SUM(CASE WHEN v.`status` = 'VERIFIED' THEN 1 ELSE 0 END) = COUNT(1) THEN 'VERIFIED'
        ELSE 'ISSUED'
      END AS `fulfillment_status`,
      NULL AS `extend_attr`,
      COALESCE(oi.`order_id`, 0) AS `order_id`,
      v.`order_no`,
      v.`order_item_id`,
      COALESCE(v.`spu_id`, '0') AS `spu_id`,
      COALESCE(v.`sku_id`, '0') AS `sku_id`,
      COALESCE(v.`sub_sku_id`, '0') AS `sub_sku_id`,
      COALESCE(o.`channel_code`, 'SELF') AS `channel_code`,
      COALESCE(o.`channel_order_no`, '0') AS `channel_order_no`,
      COALESCE(oi.`channel_item_id`, '0') AS `channel_item_id`,
      COALESCE(oi.`channel_sku_id`, '0') AS `channel_sku_id`,
      COALESCE(v.`sub_sku_id`, '0') AS `channel_sub_sku_id`,
      COALESCE(v.`tenant_id`, 0) AS `tenant_id`,
      COALESCE(MIN(v.`create_user`), 0) AS `create_user`,
      COALESCE(MAX(v.`modify_user`), 0) AS `modify_user`,
      MIN(v.`create_time`) AS `create_time`,
      MAX(v.`modify_time`) AS `modify_time`,
      0 AS `deleted`
    FROM `o_voucher` v
    LEFT JOIN `o_order_item` oi ON oi.`order_item_id` = v.`order_item_id`
    LEFT JOIN `o_order` o ON o.`order_no` = v.`order_no`
    WHERE v.`deleted` = 0
    GROUP BY
      COALESCE(oi.`order_id`, 0), v.`order_no`, v.`order_item_id`,
      COALESCE(v.`spu_id`, '0'), COALESCE(v.`sku_id`, '0'), COALESCE(v.`sub_sku_id`, '0'),
      COALESCE(o.`channel_code`, 'SELF'), COALESCE(o.`channel_order_no`, '0'),
      COALESCE(oi.`channel_item_id`, '0'), COALESCE(oi.`channel_sku_id`, '0'), COALESCE(v.`tenant_id`, 0);

    INSERT IGNORE INTO `o_fulfillment_voucher` (
      `voucher_id`, `fulfillment_item_id`, `ticket_type`, `voucher_code`, `project_id`, `status`,
      `valid_start_time`, `valid_end_time`, `user_id`, `order_id`, `order_no`, `order_item_id`,
      `spu_id`, `sku_id`, `sub_sku_id`, `channel_code`, `channel_voucher_id`, `channel_order_no`,
      `tenant_id`, `create_user`, `modify_user`, `create_time`, `modify_time`, `deleted`
    )
    SELECT
      v.`voucher_id`,
      fi.`fulfillment_item_id`,
      COALESCE(v.`ticket_type`, 'NORMAL') AS `ticket_type`,
      v.`voucher_code`,
      COALESCE(v.`project_id`, CAST(v.`voucher_id` AS CHAR)) AS `project_id`,
      v.`status`,
      v.`valid_start_time`,
      v.`valid_end_time`,
      COALESCE(v.`user_id`, '0') AS `user_id`,
      COALESCE(oi.`order_id`, 0) AS `order_id`,
      v.`order_no`,
      v.`order_item_id`,
      COALESCE(v.`spu_id`, '0') AS `spu_id`,
      COALESCE(v.`sku_id`, '0') AS `sku_id`,
      COALESCE(v.`sub_sku_id`, '0') AS `sub_sku_id`,
      COALESCE(o.`channel_code`, 'SELF') AS `channel_code`,
      NULL AS `channel_voucher_id`,
      COALESCE(o.`channel_order_no`, '0') AS `channel_order_no`,
      COALESCE(v.`tenant_id`, 0) AS `tenant_id`,
      COALESCE(v.`create_user`, 0) AS `create_user`,
      COALESCE(v.`modify_user`, 0) AS `modify_user`,
      v.`create_time`,
      v.`modify_time`,
      v.`deleted`
    FROM `o_voucher` v
    LEFT JOIN `o_order_item` oi ON oi.`order_item_id` = v.`order_item_id`
    LEFT JOIN `o_order` o ON o.`order_no` = v.`order_no`
    INNER JOIN `o_fulfillment_item` fi
      ON fi.`order_item_id` = v.`order_item_id`
     AND fi.`sub_sku_id` = COALESCE(v.`sub_sku_id`, '0')
    WHERE v.`deleted` = 0;

    DROP TABLE `o_voucher`;
  END IF;
END$$
DELIMITER ;

CALL `migrate_o_voucher_to_fulfillment`();
DROP PROCEDURE IF EXISTS `migrate_o_voucher_to_fulfillment`;

SET FOREIGN_KEY_CHECKS = 1;
