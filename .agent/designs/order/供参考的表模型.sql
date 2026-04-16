drop table if exists o_order_item;

/*==============================================================*/
/* Table: o_order_item                                          */
/*==============================================================*/
create table o_order_item
(
    order_item_id        char(10),
    order_id             char(10),
    order_sn             char(10),
    merchant_id          char(10),
    merchant_name        char(10),
    product_id           char(10),
    product_name         char(10),
    promotion_name       char(10) comment '打折优惠：满3件，打7.50折',
    product_sn           char(10),
    product_brand        char(10),
    product_attr         char(10),
    product_sku_id       char(10),
    product_sku_name     char(10),
    product_sku_title    char(10),
    product_sku_code     char(10),
    productor_attr       char(10) comment '商品销售属性:[{\"key\":\"颜色\",\"value\":\"颜色\"},{\"key\":\"容量\",\"value\":\"4G\"}]',
    product_quantity     char(10),
    product_price        char(10),
    product_category_id  char(10),
    product_category_name char(10),
    product_brand_id     char(10),
    product_brand_name   char(10),
    promotion_amount     char(10),
    coupon_amount        char(10),
    coupon_list          char(10) comment '针对该商品的优惠券信息（JSON集合）',
    integration_amount   char(10),
    gift_card_amount     char(10),
    discount_amount      char(10),
    real_amount          char(10),
    integration          char(10),
    growth               char(10),
    extend_attr          char(10)
);

alter table o_order_item comment '订单按商品拆分的订单项';

alter table o_order_item add constraint FK_Reference_19 foreign key ()
    references o_order on delete restrict on update restrict;


drop table if exists o_order;

/*==============================================================*/
/* Table: o_order                                               */
/*==============================================================*/
create table o_order
(
    order_id             char(10),
    order_sn             char(10),
    order_source         char(10),
    order_type           char(10),
    order_desc           char(10),
    user_id              char(10),
    user_account         char(10) comment '昵称（天猫、京东）、手机号（朴朴）',
    user_anony           char(10) comment '昵称或手机号匿名显示',
    receiver_name        char(10),
    receiver_phone       char(10),
    receiver_detail_address char(10) comment '值对象{省、市、区、邮编、详细地址}',
    total_amount         char(10),
    freight_amount       char(10),
    promotion_amount     char(10),
    coupon_amount        char(10),
    coupon_list          char(10) comment '优惠券信息（JSON集合）',
    integration_amount   char(10),
    gift_card_amount     char(10),
    gift_card_list       char(10),
    discount_amount      char(10),
    pay_amount           char(10),
    pay_type             char(10),
    delivery_type        char(10),
    bill_type            char(10),
    bill_header_type     char(10),
    bill_tax_code        char(10) comment '发票抬头、税号、电子邮箱、电话、注册地址、开户银行',
    order_status         char(10),
    user_confirm_status  char(10) comment '自动确认收货时，改值为空',
    auto_confirm_day     char(10),
    order_eta            char(10),
    delivery_eta         char(10),
    create_time          char(10),
    payment_time         char(10),
    delivery_time        char(10),
    receive_time         char(10),
    end_time             char(10) comment '订单完成、取消、关闭时间',
    modify_time          char(10),
    use_integration      char(10),
    integration          char(10),
    growth               char(10),
    pay_qrcode_url       char(10),
    deleted              char(10),
    extend_attr          char(10)
);

alter table o_order comment '订单主表（常用字段）';


drop table if exists o_order_return_apply;

/*==============================================================*/
/* Table: o_order_return_apply                                  */
/*==============================================================*/
create table o_order_return_apply
(
    return_apply_id      char(10),
    return_apply_code    char(10),
    return_type          char(10),
    order_item_id        char(10),
    order_id             char(10),
    order_sm             char(10),
    product_id           char(10),
    product_sn           char(10),
    product_pic          char(10),
    product_name         char(10),
    product_brand        char(10),
    product_sku_id       char(10),
    product_sku_code     char(10),
    product_category_id  char(10),
    productor_attr       char(10) comment '商品销售属性:[{\"key\":\"颜色\",\"value\":\"颜色\"},{\"key\":\"容量\",\"value\":\"4G\"}]',
    product_price        char(10),
    real_amount          char(10),
    apply_user_id        char(10),
    apply_user_name      char(10),
    申请人姓名                char(10),
    申请人手机号               char(10),
    退款方式                 char(10),
    退款金额                 char(10),
    退款退货原因               char(10),
    补充描述                 char(10),
    退货数量                 char(10),
    返回方式                 char(10),
    取件地址JSON             char(10) comment '用户地址/商家指定地址',
    申请状态                 char(10),
    创建时间                 char(10),
    修改时间                 char(10),
    删除状态                 char(10)
);

alter table o_order_return_apply comment '退款退货申请';

alter table o_order_return_apply add constraint FK_Reference_21 foreign key ()
    references o_order_item on delete restrict on update restrict;

alter table o_order_return_apply add constraint FK_Reference_29 foreign key ()
    references 退货媒体信息 on delete restrict on update restrict;

alter table o_order_return_apply add constraint FK_Reference_30 foreign key ()
    references 退款退货原因 on delete restrict on update restrict;


drop table if exists 退款退货原因;

/*==============================================================*/
/* Table: 退款退货原因                                                */
/*==============================================================*/
create table 退款退货原因
(
    原因ID                 char(10),
    原因描述                 char(10)
);


drop table if exists 退货媒体信息;

/*==============================================================*/
/* Table: 退货媒体信息                                                */
/*==============================================================*/
create table 退货媒体信息
(
    ra_media_id          bigint(20) not null,
    ra_id                bigint(20) not null,
    media_url            varchar(100),
    media_type           tinyint comment '字典：1. 图片 2. 视频 3 附件',
    create_time          datetime not null default CURRENT_TIMESTAMP,
    modify_time          datetime not null default CURRENT_TIMESTAMP,
    deleted              tinyint not null default 0
);


drop table if exists o_shopping_cart;

/*==============================================================*/
/* Table: o_shopping_cart                                       */
/*==============================================================*/
create table o_shopping_cart
(
    shopping_card_id     char(10),
    user_id              char(10),
    user_nickname        char(10),
    product_id           char(10),
    product_pic          char(10),
    product_name         char(10),
    product_sub_title    char(10),
    product_sku_id       char(10),
    product_sn           char(10),
    product_sku_code     char(10),
    product_attr         char(10),
    product_category_id  char(10),
    product_category_name char(10),
    product_brand_id     char(10),
    product_brand_name   char(10),
    quantity             char(10),
    create_time          char(10),
    modify_time          char(10),
    deleted              char(10)
);

alter table o_shopping_cart comment '购物车';
