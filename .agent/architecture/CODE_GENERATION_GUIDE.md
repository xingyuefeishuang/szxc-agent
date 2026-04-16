# 通用代码生成规范文档

> 本文档为通用模板，适用于任何表结构的代码生成。根据具体表结构填充占位符即可生成完整代码。

---

## 1. 输入模板：表结构

请提供你的 CREATE TABLE 语句，格式如下：

```sql
CREATE TABLE `表名` (
  `id` bigint unsigned NOT NULL COMMENT '主键',
  `字段1` 类型 NOT NULL COMMENT '字段注释',
  `字段2` 类型 DEFAULT NULL COMMENT '字段注释',
  -- ... 其他字段
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `modify_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除 1表示是，0表示否',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='表注释';
```

### 1.1 变量占位符说明

| 占位符 | 说明 | 示例值 |
|--------|------|--------|
| `{TableName}` | 表名（蛇形，下划线分隔） | `c_article_template` |
| `{EntityName}` | 实体类名（大驼峰） | `ArticleTemplate` |
| `{moduleName}` | 模块名（小驼峰） | `articletemplate` |
| `{TableComment}` | 表注释 | `文章表单模板表` |
| `{Fields}` | 字段列表（根据表结构生成） | 见下方字段映射表 |

### 1.2 字段类型映射表

| MySQL 类型 | Java 类型 | 注解 |
|------------|-----------|------|
| `bigint unsigned` | `Long` | `@JsonSerialize(using = ToStringSerializer.class)` |
| `int` / `tinyint` | `Integer` | 无 |
| `varchar(n)` | `String` | 无 |
| `json` | `String` | 无 |
| `datetime` | `Date`（默认）/ `LocalDateTime`（模块已迁移时） | `@JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")` |
| `decimal(p,s)` | `BigDecimal` | 无 |

---

## 2. 配置参数

### 2.1 项目基础配置

| 参数 | 值 |
|------|-----|
| 根包 | `cn.com.bsszxc.plt` |
| 模块名 | `cms`（根据实际模块调整） |
| 逻辑删除字段 | `deleted` |
| 逻辑删除值 | `0` → `1` |
| 创建时间字段 | `create_time` |
| 更新时间字段 | `modify_time` |

### 2.2 各层包名

| 层级 | 包名 |
|------|------|
| Entity | `{rootPackage}.{moduleName}.db.model` |
| Mapper | `{rootPackage}.{moduleName}.db.mapper` |
| Service | `{rootPackage}.{moduleName}.service` |
| ServiceImpl | `{rootPackage}.{moduleName}.service.impl` |
| Controller | `{rootPackage}.{moduleName}.module.{moduleName}.controller` |
| Api/POJO | `{rootPackage}.{moduleName}.module.{moduleName}` |

### 2.3 生成前校验规则

在根据本模板生成代码前，必须先核对以下事实，避免模板与真实项目冲突：

1. 目标模块最近的真实代码风格；
2. `.agent/architecture/PROJECT_STRUCTURE.md` 中的对象模型、基础类和返回类型约束；
3. 基类是否已提供 `createTime`、`modifyTime`、`tenantId` 等通用字段；
4. 当前模块实际使用的是 `Date` 还是 `LocalDateTime`。

如模板与现有模块事实冲突，以**现有模块事实**为准；如无现成实现，再以 `PROJECT_STRUCTURE.md` 为准。

---

## 3. 文件清单

| 序号 | 文件 | 路径 | 说明 |
|------|------|------|------|
| 1 | Entity | `{rootPackage}/{moduleName}/db/model/{EntityName}.java` | 实体类 |
| 2 | BO | `{rootPackage}/{moduleName}/module/{moduleName}/pojo/{EntityName}BO.java` | 展示对象 |
| 3 | AddDO | `{rootPackage}/{moduleName}/module/{moduleName}/pojo/{EntityName}AddDO.java` | 添加请求 |
| 4 | UpdateDO | `{rootPackage}/{moduleName}/module/{moduleName}/pojo/{EntityName}UpdateDO.java` | 更新请求 |
| 5 | QueryDO | `{rootPackage}/{moduleName}/module/{moduleName}/pojo/{EntityName}QueryDO.java` | 查询请求 |
| 6 | Api | `{rootPackage}/{moduleName}/module/{moduleName}/{EntityName}Api.java` | Feign接口 |
| 7 | Controller | `{rootPackage}/{moduleName}/module/{moduleName}/controller/{EntityName}Controller.java` | 控制器 |
| 8 | Service | `{rootPackage}/{moduleName}/service/{EntityName}Service.java` | 服务接口 |
| 9 | ServiceImpl | `{rootPackage}/{moduleName}/service/impl/{EntityName}ServiceImpl.java` | 服务实现 |
| 10 | Mapper | `{rootPackage}/{moduleName}/db/mapper/{EntityName}Mapper.java` | Mapper接口 |
| 11 | Mapper.xml | `src/main/resources/mapper/{EntityName}Mapper.xml` | XML映射 |

---

## 4. 继承关系

```
Entity (extends TenantSuperModel)
    ↓
Mapper (extends SuperMapper<Entity>)
    ↓
Service (extends IBaseService<Entity>)
    ↓
ServiceImpl (extends BaseServiceImpl<Mapper, Entity> implements Service)
    ↓
Controller (implements Api)
```

---

## 5. 完整代码模板

### 5.1 Entity 模板

```java
package {rootPackage}.{moduleName}.db.model;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.annotation.TableLogic;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import {rootPackage}.mybatis.core.base.entity.TenantSuperModel;

@Data
@EqualsAndHashCode(callSuper = true)
@NoArgsConstructor
@TableName("{TableName}")
@Schema(description = "{TableComment}")
public class {EntityName} extends TenantSuperModel {

    private static final long serialVersionUID = 1L;

    // ========== 字段列表开始 ==========
    // 根据表结构生成以下字段
    @Schema(description = "主键")
    @TableId(value = "id", type = IdType.ASSIGN_ID)
    private Long id;

    // ... 其他字段（根据表结构生成）
    // ========== 字段列表结束 ==========

    @Schema(description = "是否删除")
    @TableLogic(value = "0", delval = "1")
    private Integer deleted;

    // 字段常量
    public static final String ID = "id";
    // ... 其他字段常量（根据表结构生成）
}
```

### 5.2 BO 模板

```java
package {rootPackage}.{moduleName}.module.{moduleName}.pojo;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.NoArgsConstructor;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;

import java.util.Date;

@Data
@NoArgsConstructor
@Schema(description = "{TableComment}展示对象")
public class {EntityName}BO {

    // ========== 字段列表开始 ==========
    @Schema(description = "主键")
    @JsonSerialize(using = ToStringSerializer.class)
    private Long id;

    // ... 其他字段（根据表结构生成，JSON字段用String，Long类型加序列化注解）
    // ========== 字段列表结束 ==========

    @Schema(description = "创建时间")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    public Date createTime;

    @Schema(description = "更新时间")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    public Date modifyTime;
}
```

### 5.3 AddDO 模板

```java
package {rootPackage}.{moduleName}.module.{moduleName}.pojo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.NoArgsConstructor;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;

@Data
@NoArgsConstructor
@Schema(description = "{TableComment}添加请求")
public class {EntityName}AddDO {

    // ========== 字段列表开始 ==========
    // ... 其他字段（根据表结构生成，不含时间字段和deleted字段）
    // ========== 字段列表结束 ==========
}
```

### 5.4 UpdateDO 模板

```java
package {rootPackage}.{moduleName}.module.{moduleName}.pojo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.NoArgsConstructor;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;
import javax.validation.constraints.NotNull;

@Data
@NoArgsConstructor
@Schema(description = "{TableComment}更新请求")
public class {EntityName}UpdateDO {

    // ========== 字段列表开始 ==========
    @Schema(description = "主键")
    @JsonSerialize(using = ToStringSerializer.class)
    @NotNull(message = "主键不能为空")
    private Long id;

    // ... 其他字段（根据表结构生成，不含时间字段和deleted字段）
    // ========== 字段列表结束 ==========
}
```

### 5.5 QueryDO 模板

```java
package {rootPackage}.{moduleName}.module.{moduleName}.pojo;

import {rootPackage}.common.model.PageReq;
import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.NoArgsConstructor;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;

import java.util.Date;
import java.util.List;

@Data
@NoArgsConstructor
@Schema(description = "{TableComment}查询请求")
public class {EntityName}QueryDO extends PageReq {

    // ========== 字段列表开始 ==========
    @Schema(description = "主键")
    @JsonSerialize(using = ToStringSerializer.class)
    private Long id;

    @Schema(description = "主键List")
    private List<Long> idList;

    // ... 其他字段（根据表结构生成）
    // ========== 字段列表结束 ==========

    @Schema(description = "创建时间")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    public Date createTime;

    @Schema(description = "更新时间")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    public Date modifyTime;
}
```

### 5.6 Api 模板

```java
package {rootPackage}.{moduleName}.module.{moduleName};

import {rootPackage}.{moduleName}.constant.{ModuleName}Constant;
import {rootPackage}.{moduleName}.module.{moduleName}.pojo.{EntityName}AddDO;
import {rootPackage}.{moduleName}.module.{moduleName}.pojo.{EntityName}BO;
import {rootPackage}.{moduleName}.module.{moduleName}.pojo.{EntityName}QueryDO;
import {rootPackage}.{moduleName}.module.{moduleName}.pojo.{EntityName}UpdateDO;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import javax.validation.Valid;
import java.util.List;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;

@Tag(name = "{TableComment}原子接口")
@FeignClient(contextId = "{EntityName}Api", name = {ModuleName}Constant.SERVICE_NAME)
public interface {EntityName}Api {

    @Operation(summary = "新增{TableComment}")
    @PostMapping("{moduleName}/add")
    String insert(@Valid @RequestBody {EntityName}AddDO dto);

    @Operation(summary = "修改{TableComment}")
    @PostMapping("{moduleName}/update")
    boolean update(@Valid @RequestBody {EntityName}UpdateDO dto);

    @Operation(summary = "条件查询{TableComment}详情")
    @PostMapping("{moduleName}/detailByCondition")
    {EntityName}BO detailByCondition(@Valid @RequestBody {EntityName}QueryDO dto);

    @Operation(summary = "删除{TableComment}")
    @GetMapping("{moduleName}/remove")
    boolean delete(@RequestParam("id") String id);

    @Operation(summary = "{TableComment}详情")
    @GetMapping("{moduleName}/detail")
    {EntityName}BO detail(@RequestParam("id") String id);

    @Operation(summary = "{TableComment}分页查询")
    @PostMapping("{moduleName}/page")
    Page<{EntityName}BO> page(@Valid @RequestBody {EntityName}QueryDO dto);

    @Operation(summary = "{TableComment}列表")
    @PostMapping("{moduleName}/list")
    List<{EntityName}BO> list(@Valid @RequestBody {EntityName}QueryDO dto);

    @Operation(summary = "{TableComment}总量计算")
    @PostMapping("{moduleName}/count")
    Long count(@Valid @RequestBody {EntityName}QueryDO dto);
}
```

### 5.7 Controller 模板

```java
package {rootPackage}.{moduleName}.module.{moduleName}.controller;

import {rootPackage}.{moduleName}.module.{moduleName}.{EntityName}Api;
import {rootPackage}.{moduleName}.module.{moduleName}.pojo.{EntityName}AddDO;
import {rootPackage}.{moduleName}.module.{moduleName}.pojo.{EntityName}BO;
import {rootPackage}.{moduleName}.module.{moduleName}.pojo.{EntityName}QueryDO;
import {rootPackage}.{moduleName}.module.{moduleName}.pojo.{EntityName}UpdateDO;
import {rootPackage}.{moduleName}.service.{EntityName}Service;
import {rootPackage}.common.annotation.EmptyParamFilling;
import {rootPackage}.common.annotation.EmptyParamFillings;
import {rootPackage}.common.constant.FillingBeanProvider;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.Valid;
import java.util.List;

@Tag(name = "{TableComment}服务接口")
@RestController
public class {EntityName}Controller implements {EntityName}Api {

    @Autowired
    private {EntityName}Service service;

    @Operation(summary = "新增{TableComment}")
    @Override
    @EmptyParamFillings({
        @EmptyParamFilling(parameter = "#dto.createUser", beanProvider = FillingBeanProvider.LOGIN_USER_ID_PROVIDER)
    })
    public String insert(@Valid @RequestBody {EntityName}AddDO dto) {
        return service.insert(dto);
    }

    @Operation(summary = "修改{TableComment}")
    @Override
    @EmptyParamFillings({
        @EmptyParamFilling(parameter = "#dto.modifyUser", beanProvider = FillingBeanProvider.LOGIN_USER_ID_PROVIDER)
    })
    public boolean update(@Valid @RequestBody {EntityName}UpdateDO dto) {
        return service.update(dto);
    }

    @Operation(summary = "条件查询{TableComment}详情")
    @Override
    public {EntityName}BO detailByCondition(@Valid @RequestBody {EntityName}QueryDO dto) {
        return service.detail(dto);
    }

    @Operation(summary = "删除{TableComment}")
    @Override
    public boolean delete(@RequestParam("id") String id) {
        return service.delete(id);
    }

    @Operation(summary = "{TableComment}详情")
    @Override
    public {EntityName}BO detail(@RequestParam("id") String id) {
        return service.detail(id);
    }

    @Operation(summary = "{TableComment}分页查询")
    @Override
    public Page<{EntityName}BO> page(@Valid @RequestBody {EntityName}QueryDO dto) {
        return service.page(dto);
    }

    @Operation(summary = "{TableComment}列表")
    @Override
    public List<{EntityName}BO> list(@Valid @RequestBody {EntityName}QueryDO dto) {
        return service.list(dto);
    }

    @Operation(summary = "{TableComment}总量计算")
    @Override
    public Long count(@Valid @RequestBody {EntityName}QueryDO dto) {
        return service.count(dto);
    }
}
```

### 5.8 Service 模板

```java
package {rootPackage}.{moduleName}.service;

import {rootPackage}.{moduleName}.db.model.{EntityName};
import {rootPackage}.{moduleName}.module.{moduleName}.pojo.{EntityName}AddDO;
import {rootPackage}.{moduleName}.module.{moduleName}.pojo.{EntityName}BO;
import {rootPackage}.{moduleName}.module.{moduleName}.pojo.{EntityName}QueryDO;
import {rootPackage}.{moduleName}.module.{moduleName}.pojo.{EntityName}UpdateDO;
import {rootPackage}.mybatis.core.base.service.IBaseService;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;

import java.util.List;

public interface {EntityName}Service extends IBaseService<{EntityName}> {
    String insert({EntityName}AddDO dto);
    boolean update({EntityName}UpdateDO dto);
    Long count({EntityName}QueryDO dto);
    Page<{EntityName}BO> page({EntityName}QueryDO dto);
    List<{EntityName}BO> list({EntityName}QueryDO dto);
    {EntityName}BO detail({EntityName}QueryDO dto);
    boolean delete(String id);
    {EntityName}BO detail(String id);
}
```

### 5.9 ServiceImpl 模板

```java
package {rootPackage}.{moduleName}.service.impl;

import {rootPackage}.{moduleName}.db.mapper.{EntityName}Mapper;
import {rootPackage}.{moduleName}.db.model.{EntityName};
import {rootPackage}.{moduleName}.module.{moduleName}.pojo.{EntityName}AddDO;
import {rootPackage}.{moduleName}.module.{moduleName}.pojo.{EntityName}BO;
import {rootPackage}.{moduleName}.module.{moduleName}.pojo.{EntityName}QueryDO;
import {rootPackage}.{moduleName}.module.{moduleName}.pojo.{EntityName}UpdateDO;
import {rootPackage}.{moduleName}.service.{EntityName}Service;
import {rootPackage}.mybatis.core.base.service.impl.BaseServiceImpl;
import com.baomidou.mybatisplus.extension.conditions.query.LambdaQueryChainWrapper;
import {rootPackage}.mybatis.core.base.entity.SuperModel;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Primary;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.util.ObjectUtil;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;

import java.util.ArrayList;
import java.util.List;

@Service
@Primary
@Slf4j
@Transactional(rollbackFor = Exception.class)
public class {EntityName}ServiceImpl extends BaseServiceImpl<{EntityName}Mapper, {EntityName}> 
        implements {EntityName}Service {

    @Override
    public String insert({EntityName}AddDO dto) {
        {EntityName} entity = BeanUtil.copyProperties(dto, {EntityName}.class);
        int count = this.getBaseMapper().insert(entity);
        return count <= 0 ? null : entity.getId().toString();
    }

    @Override
    public boolean update({EntityName}UpdateDO dto) {
        {EntityName} entity = BeanUtil.copyProperties(dto, {EntityName}.class);
        return this.updateById(entity);
    }

    @Override
    public Page<{EntityName}BO> page({EntityName}QueryDO dto) {
        Page<{EntityName}> page = getLambdaQueryChainWrapper(dto).page(new Page<>(dto.getCurrent(), dto.getSize()));
        if (ObjectUtil.isEmpty(page.getRecords())) {
            return new Page<>(page.getCurrent(), page.getSize(), 0);
        }
        Page<{EntityName}BO> boPage = new Page<>(page.getCurrent(), page.getSize(), page.getTotal());
        boPage.setRecords(BeanUtil.copyToList(page.getRecords(), {EntityName}BO.class));
        return boPage;
    }

    @Override
    public List<{EntityName}BO> list({EntityName}QueryDO dto) {
        List<{EntityName}> list = getLambdaQueryChainWrapper(dto).list();
        if (ObjectUtil.isEmpty(list)) {
            return new ArrayList<>();
        }
        return BeanUtil.copyToList(list, {EntityName}BO.class);
    }

    @Override
    public Long count({EntityName}QueryDO dto) {
        return getLambdaQueryChainWrapper(dto).count();
    }

    @Override
    public {EntityName}BO detail({EntityName}QueryDO dto) {
        {EntityName} entity = getLambdaQueryChainWrapper(dto).one();
        if (null == entity) {
            return null;
        }
        return BeanUtil.copyProperties(entity, {EntityName}BO.class);
    }

    @Override
    public boolean delete(String id) {
        return this.removeById(id);
    }

    @Override
    public {EntityName}BO detail(String id) {
        {EntityName} entity = this.getById(id);
        if (null == entity) {
            return null;
        }
        return BeanUtil.copyProperties(entity, {EntityName}BO.class);
    }

    public LambdaQueryChainWrapper<{EntityName}> getLambdaQueryChainWrapper({EntityName}QueryDO dto) {
        return this.lambdaQuery()
            .eq(ObjectUtil.isNotEmpty(dto.getId()), {EntityName}::getId, dto.getId())
            .in(ObjectUtil.isNotEmpty(dto.getIdList()), {EntityName}::getId, dto.getIdList())
            // 根据字段名动态生成查询条件
            // .eq(ObjectUtil.isNotEmpty(dto.getFieldName()), {EntityName}::getFieldName, dto.getFieldName())
            // .like(ObjectUtil.isNotEmpty(dto.getName()), {EntityName}::getName, dto.getName())
            .orderByDesc(SuperModel::getCreateTime);
    }
}
```

### 5.10 Mapper 模板

```java
package {rootPackage}.{moduleName}.db.mapper;

import {rootPackage}.{moduleName}.db.model.{EntityName};
import {rootPackage}.mybatis.core.base.mapper.SuperMapper;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface {EntityName}Mapper extends SuperMapper<{EntityName}> {
}
```

### 5.11 Mapper.xml 模板

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="{rootPackage}.{moduleName}.db.mapper.{EntityName}Mapper">

    <!-- 通用查询结果列 -->
    <sql id="Base_Column_List">
        id, 字段1, 字段2, 字段3, create_time, modify_time, deleted
    </sql>

</mapper>
```

---

## 6. 常用注解速查

### 6.1 MyBatis-Plus 注解

| 注解 | 用法 |
|------|------|
| `@TableName("表名")` | 指定表名 |
| `@TableId(value = "字段名", type = IdType.ASSIGN_ID)` | 指定主键字段和类型 |
| `@TableLogic` | 逻辑删除注解 |
| `@TableField` | 字段映射注解 |

### 6.2 Swagger 注解

| 注解 | 用法 |
|------|------|
| `@Tag(name = "描述")` | 类级别 |
| `@Schema(description = "描述")` | 字段级别 |

### 6.3 JSON 注解

| 注解 | 用法 |
|------|------|
| `@JsonSerialize(using = ToStringSerializer.class)` | Long 类型序列化 |
| `@JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")` | 时间格式化 |

### 6.4 校验注解

| 注解 | 用法 |
|------|------|
| `@NotNull(message = "不能为空")` | 必填校验 |
| `@Valid` | 开启校验 |

### 6.5 参数填充注解

```java
@EmptyParamFillings({
    @EmptyParamFilling(parameter = "#dto.createUser", beanProvider = FillingBeanProvider.LOGIN_USER_ID_PROVIDER)
})
```

---

## 7. 使用方法

### 7.1 准备输入

提供以下信息：
1. **CREATE TABLE** 语句
2. **模块名**（小驼峰，如 `articletemplate`）
3. **类名**（大驼峰，如 `ArticleTemplate`）

### 7.2 生成流程

1. 解析表结构，提取字段信息
2. 根据模板生成所有代码文件
3. 将 `{EntityName}`、`{TableName}`、`{moduleName}` 等占位符替换为实际值
4. 将字段列表替换为实际的字段定义

### 7.3 注意事项

- 确保继承关系正确
- 逻辑删除字段添加 `@TableLogic` 注解
- Long 类型字段添加 `@JsonSerialize` 注解
- 时间字段添加 `@JsonFormat` 注解
- QueryDO 必须继承 `PageReq`
- 如果基类已提供通用字段，不要在 Entity 中重复声明
- `count` 方法默认使用 `Long`
- 新生成代码必须先对照同模块最近实现，不能只照抄模板

---

## 8. 完整项目结构参考

```
项目根目录/
├── plt-cms-service/
│   ├── plt-cms-api/
│   │   └── src/main/java/{rootPackage}/{moduleName}/module/{moduleName}/
│   │       ├── {EntityName}Api.java
│   │       └── pojo/
│   │           ├── {EntityName}BO.java
│   │           ├── {EntityName}AddDO.java
│   │           ├── {EntityName}UpdateDO.java
│   │           └── {EntityName}QueryDO.java
│   └── plt-cms-core/
│       └── src/main/java/{rootPackage}/{moduleName}/
│           ├── db/
│           │   ├── model/{EntityName}.java
│           │   └── mapper/{EntityName}Mapper.java
│           ├── module/{moduleName}/
│           │   └── controller/{EntityName}Controller.java
│           └── service/
│               ├── {EntityName}Service.java
│               └── impl/{EntityName}ServiceImpl.java
└── src/main/resources/
    └── mapper/{EntityName}Mapper.xml
```

---

**文档版本**: 2.0
**最后更新**: 2026-01-20
