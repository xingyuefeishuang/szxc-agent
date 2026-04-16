# 博思平台2.0 项目结构文档

> **项目路径**: `D:\08-Work\01-博思\10-平台2.0`
> **文档更新时间**: 2026-01-21
> **阅读建议**: AI 首次进入仓库时，建议先阅读 `AI_QUICKSTART.md` 建立低 token 全局认知；仅在需要深入架构、对象模型、分层约束时再继续阅读本文全文。

---

## 1. 项目概览

这是一个基于 **Spring Cloud** 微服务架构的企业级平台项目，提供底座服务能力。

### 1.1 技术栈

| 技术 | 版本 |
|------|------|
| JDK | 17 |
| Spring Boot | 2.6.13 |
| Spring Cloud | 2021.0.5 |
| Spring Cloud Alibaba | 2021.0.6.2 |
| 注册/配置中心 | Nacos 2.2.6 |
| 网关 | Spring Cloud Gateway 3.1.4 |
| 数据库ORM | MyBatis Plus 3.4.0 |
| 缓存 | JetCache 2.6.0 + Redis |
| 连接池 | Druid 1.1.23 |
| 定时任务 | XXL-JOB 2.3.0 |
| 分布式锁 | Redisson 3.17.7 |
| Excel操作 | EasyExcel 3.2.1 |
| 工具类 | Hutool 5.7.21 |
| 接口文档 | Knife4j 4.5.0 |
| 分布式文件 | FastDFS 1.27.2 |
| 消息队列 | RabbitMQ / RocketMQ |
| 关系数据库 | MySQL 8.0.19 |
| 分布式事务 | Seata 1.4.2 |
| 区块链 | Hyperledger Fabric 1.4.6 |

### 1.2 Maven坐标

```xml
<groupId>cn.com.bsszxc</groupId>
<artifactId>plt-project</artifactId>
<version>2.0.0-SNAPSHOT</version>
```

---

## 1.3 编码规范说明
- 项目统一使用 `UTF-8` 编码。
- 请尽量避免使用带 BOM 的 UTF-8（除非有特殊历史原因，如需处理旧文件，Python 可使用 `utf-8-sig` 读取）。
- **AI 助理特别注意**：在 Windows 系统下写文件时，为了避免中文乱码，**必须**优先使用运行环境提供的结构化文件编辑工具，**严禁**使用 PowerShell 的重定向 `> ` 或 `echo` 来写入中文。如果必须使用 PowerShell 命令写文件，请务必指定 `-Encoding UTF8` 参数。

## 2. 项目模块结构

```
plt-project (根项目)
├── plt-commons          # 公共基础组件库（独立Git仓库）
├── plt-framework        # 框架层Starter组件（独立Git仓库）
├── plt-core-service     # 核心业务服务（独立Git仓库）
├── plt-gateway          # API网关服务（独立Git仓库）
├── plt-auth-service     # 认证授权服务（独立Git仓库）
├── plt-comm-service     # 通用服务（独立Git仓库）
├── plt-opr-service      # 运营管理服务
├── plt-mobile-service   # 移动端服务
├── plt-workflow-service # 工作流服务（独立Git仓库）
├── plt-open-service     # 开放接口服务
└── ind-opr-service      # 行业运营服务（独立Git仓库）
```

### 2.1 plt-core-service internal layout
`plt-core-service` is a single microservice that contains multiple business modules.
Each business module follows an `*-api` + `*-core` split, and all are wired by
`plt-core-startup`.

Examples (current on disk):
- `plt-core-service/plt-pay-service/plt-pay-api`
- `plt-core-service/plt-pay-service/plt-pay-core`
- `plt-core-service/plt-msg-service/plt-msg-api`
- `plt-core-service/plt-msg-service/plt-msg-core`

When adding a new domain module, follow the same pattern:
- `plt-core-service/plt-<domain>-service/plt-<domain>-api`
- `plt-core-service/plt-<domain>-service/plt-<domain>-core`
- add module wiring in `plt-core-service/pom.xml` and `plt-core-service/plt-core-startup`

### 2.2 文档约定补充
- `.agent/architecture/` 根目录下的文档用于描述**全局架构事实**与**跨模块通用规范**。
- `.agent/architecture/{业务域}/` 子目录下的文档用于描述**特定业务域**的架构约束、模块边界和补充说明。
- `requirements/`、`references/`、`designs/` 同样遵循“全局文档可在根部，业务文档新增时进入业务子目录”的双层结构。


---

## 3. 对象模型定义规范 (BO/DO/DTO/VO/Entity)

### 3.1 对象类型说明

项目中主要使用以下几种对象类型：

| 类型 | 命名规范 | 用途                                                | 所在位置 |
|------|---------|---------------------------------------------------|---------|
| **Entity** | `{EntityName}.java` | 数据库实体类，与表一一对应                                     | `{moduleName}-core/db/model/` |
| **BO** | `{EntityName}BO.java` | Business Object，业务展示对象，用于接口返回                     | `{moduleName}-api/module/{业务}/pojo/` |
| **AddDO** | `{EntityName}AddDO.java` | Data Object，新增请求对象                                | `{moduleName}-api/module/{业务}/pojo/` |
| **UpdateDO** | `{EntityName}UpdateDO.java` | Data Object，更新请求对象                                | `{moduleName}-api/module/{业务}/pojo/` |
| **QueryDO** | `{EntityName}QueryDO.java` | Data Object，查询请求对象，继承PageReq                      | `{moduleName}-api/module/{业务}/pojo/` |
| **DTO** | `*DTO.java` | Data Transfer Object，不直连数据库的BFF层特有对象，如plt-opr服务   | `{moduleName}-api/module/{业务}/pojo/` |
| **VO** | `*VO.java` | View Object，不直连数据库的BFF层特有对象，如plt-opr服务 | `{moduleName}-api/module/{业务}/pojo/` |

### 3.2 对象流转关系图

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              请求流程                                        │
└─────────────────────────────────────────────────────────────────────────────┘

  前端请求                                                           前端响应
     │                                                                  ▲
     ▼                                                                  │
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│  AddDO  │───▶│Controller│───▶│ Service │───▶│ Mapper  │───▶│ Entity  │
│UpdateDO │    │         │    │  Impl   │    │         │    │(数据库) │
│ QueryDO │    │         │    │         │    │         │    │         │
│  DO    │    │         │    │         │    │         │    │         │
└─────────┘    └─────────┘    └─────────┘    └─────────┘    └─────────┘
                    │              │              ▲              │
                    │              │              │              │
                    │              ▼              │              │
                    │         ┌─────────┐        │              │
                    │         │  Entity │────────┘              │
                    │         │  转换   │                       │
                    │         └────┬────┘                       │
                    │              │                            │
                    ▼              ▼                            │
               ┌─────────┐   ┌─────────┐                       │
               │   BO    │◀──│BeanUtil │◀──────────────────────┘
               │ (返回)  │   │.copy    │
               └─────────┘   └─────────┘
```

### 3.3 各对象详细说明

#### 3.3.1 Entity（实体类）

**位置**: `plt-{module}-service/plt-{module}-core/src/main/java/cn/com/bsszxc/plt/{module}/db/model/`

**继承关系**: 默认遵循 `Entity extends TenantSuperModel extends SuperModel extends Model`。  
如某模块存在明确例外，以该模块现有代码和对应设计文档为准。

**特点**:
- 与数据库表一一对应
- 使用 `@TableName` 注解指定表名
- 使用 `@TableId` 注解指定主键
- 使用 `@TableLogic` 注解实现逻辑删除
- **不要重复声明父类中已提供的通用字段**（如 `createTime`、`modifyTime`、`tenantId`），除非现有模块代码明确这么做
- 包含字段常量定义（如 `public static final String ID = "id";`）
- 主键注解不使用自增，使用雪花算法 type = IdType.ASSIGN_ID

**示例**:
```java
@Data
@EqualsAndHashCode(callSuper = true)
@NoArgsConstructor
@TableName("c_article_template")
@Schema(description = "文章表单模板表")
public class ArticleTemplate extends TenantSuperModel {
    
    @TableId(value = "id", type = IdType.ASSIGN_ID)
    private Long id;
    
    private String templateName;
    
    @TableLogic(value = "0", delval = "1")
    private Integer deleted;
    
    // 字段常量
    public static final String ID = "id";
    public static final String TEMPLATE_NAME = "template_name";
}
```

#### 3.3.2 BO（Business Object，业务对象）

**位置**: `plt-{module}-service/plt-{module}-api/src/main/java/cn/com/bsszxc/plt/{module}/module/{业务}/pojo/`

**用途**: 接口返回的展示对象，用于前端展示

**特点**:
- 不继承任何类
- Long类型字段使用 `@JsonSerialize(using = ToStringSerializer.class)` 注解，防止前端JS精度丢失
- 时间字段使用 `@JsonFormat` 注解格式化

**示例**:
```java
@Data
@NoArgsConstructor
@Schema(description = "文章表单模板表展示对象")
public class ArticleTemplateBO {
    
    @Schema(description = "主键")
    @JsonSerialize(using = ToStringSerializer.class)
    private Long id;
    
    @Schema(description = "模板名称")
    private String templateName;
    
    @Schema(description = "创建时间")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    public Date createTime;
}
```

#### 3.3.3 AddDO（新增请求对象）

**位置**: `plt-{module}-service/plt-{module}-api/src/main/java/cn/com/bsszxc/plt/{module}/module/{业务}/pojo/`

**用途**: 新增接口的请求参数

**特点**:
- 不包含时间字段（createTime/modifyTime）
- 不包含deleted字段（新增默认为0）
- Long类型字段使用 `@JsonSerialize` 注解

**示例**:
```java
@Data
@NoArgsConstructor
@Schema(description = "文章表单模板表添加请求")
public class ArticleTemplateAddDO {
    
    @Schema(description = "模板名称")
    private String templateName;
    
    @Schema(description = "创建者")
    @JsonSerialize(using = ToStringSerializer.class)
    private Long createUser;
}
```

#### 3.3.4 UpdateDO（更新请求对象）

**位置**: `plt-{module}-service/plt-{module}-api/src/main/java/cn/com/bsszxc/plt/{module}/module/{业务}/pojo/`

**用途**: 更新接口的请求参数

**特点**:
- id字段必填，使用 `@NotNull` 注解校验
- 不包含时间字段
- Long类型字段使用 `@JsonSerialize` 注解

**示例**:
```java
@Data
@NoArgsConstructor
@Schema(description = "文章表单模板表更新请求")
public class ArticleTemplateUpdateDO {
    
    @Schema(description = "主键")
    @JsonSerialize(using = ToStringSerializer.class)
    @NotNull(message = "主键不能为空")
    private Long id;
    
    @Schema(description = "模板名称")
    private String templateName;
}
```

#### 3.3.5 QueryDO（查询请求对象）

**位置**: `plt-{module}-service/plt-{module}-api/src/main/java/cn/com/bsszxc/plt/{module}/module/{业务}/pojo/`

**用途**: 查询接口的请求参数（支持分页）

**特点**:
- 标准分页查询对象**必须继承 `PageReq`** 以支持分页
- 包含 `idList` 字段支持批量查询
- 包含时间字段用于时间范围查询
- Long类型字段使用 `@JsonSerialize` 注解

**PageReq 继承属性**:
```java
public class PageReq {
    private Integer current = 1;    // 当前页码
    private Integer size = 10;      // 页面大小
    private String columnName;      // 排序字段
    private String sortType;        // 排序类型 (DESC/ASC)
}
```

**示例**:
```java
@Data
@NoArgsConstructor
@Schema(description = "文章表单模板表查询请求")
public class ArticleTemplateQueryDO extends PageReq {
    
    @Schema(description = "主键")
    @JsonSerialize(using = ToStringSerializer.class)
    private Long id;
    
    @Schema(description = "主键List")
    private List<Long> idList;
    
    @Schema(description = "模板名称")
    private String templateName;  // 一般用于模糊查询
    
    @Schema(description = "创建时间")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    public Date createTime;
}
```

#### 3.3.6 DTO（Data Transfer Object）

**用途**: 特殊业务场景的传输对象，不遵循标准CRUD命名

**示例**:
```java
@Data
@NoArgsConstructor
@Schema(title = "文章审核请求")
public class ArticleCheckDTO {
    
    @Schema(description = "文章ID")
    @JsonSerialize(using = ToStringSerializer.class)
    private Long articleId;
    
    @Schema(description = "文章ID列表")
    private List<Long> articleIdList;
    
    @Schema(description = "审核意见")
    private String auditOpinion;
}
```

#### 3.3.7 VO（View Object）

**用途**: 视图对象，特殊场景使用（较少见）

**示例**:
```java
@Data
public class LabelInfoSaveVO {
    
    @Schema(description = "标签表主键")
    private Long labelId;
    
    @Schema(description = "标签名称")
    private String labelName;
}
```

### 3.4 对象转换

使用 **Hutool** 的 `BeanUtil` 工具类进行对象转换（list copy除外，性能原因）：

```java
// 单个对象转换
ArticleTemplate entity = BeanUtil.copyProperties(dto, ArticleTemplate.class);
ArticleTemplateBO bo = BeanUtil.copyProperties(entity, ArticleTemplateBO.class);

// 列表转换(性能原因，不使用hutool工具类)
List<ArticleTemplateBO> boList = BeanUtils.copyArray(entityList, ArticleTemplateBO.class);
// List<ArticleTemplateBO> boList = BeanUtil.copyToList(entityList, ArticleTemplateBO.class);
```

---

## 4. 代码分层结构

### 4.1 层次结构

```
┌──────────────────────────────────────────────────────────────┐
│                     plt-{module}-api                         │
│  (API层 - Feign接口定义 + POJO对象)                          │
│  ┌─────────────┐  ┌─────────────────────────────────────┐   │
│  │  Api接口    │  │              pojo/                  │   │
│  │(FeignClient)│  │  BO / AddDO / UpdateDO / QueryDO    │   │
│  └─────────────┘  └─────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────┘
                              │
                              ▼ (实现)
┌──────────────────────────────────────────────────────────────┐
│                    plt-{module}-core                         │
│  (Core层 - 实现层)                                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │ Controller  │  │  Service    │  │        db/          │  │
│  │(implements  │  │    Impl     │  │  ┌───────┐ ┌─────┐  │  │
│  │    Api)     │  │             │  │  │mapper │ │model│  │  │
│  └─────────────┘  └─────────────┘  │  └───────┘ └─────┘  │  │
└──────────────────────────────────────────────────────────────┘
```

### 4.2 各层继承关系

```
Entity
    └── extends TenantSuperModel
            └── extends SuperModel (createTime, modifyTime)
                    └── extends Model (MyBatis-Plus ActiveRecord)

Mapper
    └── extends SuperMapper<Entity>
            └── extends BaseMapper<Entity> (MyBatis-Plus)

Service
    └── extends IBaseService<Entity>
            └── extends IService<Entity> (MyBatis-Plus)

ServiceImpl
    └── extends BaseServiceImpl<Mapper, Entity>
            └── extends ServiceImpl<Mapper, Entity> (MyBatis-Plus)
    └── implements Service

Controller
    └── implements Api
```

### 4.3 包名规范

| 层级 | 包名格式 |
|------|---------|
| Entity | `cn.com.bsszxc.plt.{moduleName}.db.model` |
| Mapper | `cn.com.bsszxc.plt.{moduleName}.db.mapper` |
| Service | `cn.com.bsszxc.plt.{moduleName}.service` |
| ServiceImpl | `cn.com.bsszxc.plt.{moduleName}.service.impl` |
| Controller | `cn.com.bsszxc.plt.{moduleName}.controller` |
| Api | `cn.com.bsszxc.plt.{moduleName}.module.{业务名}` |
| POJO (BO/DO...) | `cn.com.bsszxc.plt.{moduleName}.module.{业务名}.pojo` |

---

## 5. 标准CRUD接口模式

### 5.1 Api接口定义

```java
@Tag(name = "文章表单模板表原子接口")
@FeignClient(contextId = "ArticleTemplateApi", name = CmsConstant.SERVICE_NAME)
public interface ArticleTemplateApi {

    @Operation(summary = "新增")
    @PostMapping("api/articleTemplate/add")
    String insert(@Valid @RequestBody ArticleTemplateAddDO dto);

    @Operation(summary = "修改")
    @PostMapping("api/articleTemplate/update")
    boolean update(@Valid @RequestBody ArticleTemplateUpdateDO dto);

    @Operation(summary = "删除")
    @GetMapping("api/articleTemplate/remove")
    boolean delete(@RequestParam("id") String id);

    @Operation(summary = "详情")
    @GetMapping("api/articleTemplate/detail")
    ArticleTemplateBO detail(@RequestParam("id") String id);

    @Operation(summary = "条件查询详情")
    @PostMapping("api/articleTemplate/detailByCondition")
    ArticleTemplateBO detailByCondition(@Valid @RequestBody ArticleTemplateQueryDO dto);

    @Operation(summary = "分页查询")
    @PostMapping("api/articleTemplate/page")
    Page<ArticleTemplateBO> page(@Valid @RequestBody ArticleTemplateQueryDO dto);

    @Operation(summary = "列表")
    @PostMapping("api/articleTemplate/list")
    List<ArticleTemplateBO> list(@Valid @RequestBody ArticleTemplateQueryDO dto);

    @Operation(summary = "总量计算")
    @PostMapping("api/articleTemplate/count")
    Long count(@Valid @RequestBody ArticleTemplateQueryDO dto);
}
```

### 5.2 Service接口定义

```java
public interface ArticleTemplateService extends IBaseService<ArticleTemplate> {
    String insert(ArticleTemplateAddDO dto);
    boolean update(ArticleTemplateUpdateDO dto);
    Long count(ArticleTemplateQueryDO dto);
    Page<ArticleTemplateBO> page(ArticleTemplateQueryDO dto);
    List<ArticleTemplateBO> list(ArticleTemplateQueryDO dto);
    ArticleTemplateBO detail(ArticleTemplateQueryDO dto);
    boolean delete(String id);
    ArticleTemplateBO detail(String id);
}
```

### 5.3 ServiceImpl标准实现

```java
@Service
@Primary
@Slf4j
@Transactional(rollbackFor = Exception.class)
public class ArticleTemplateServiceImpl 
    extends BaseServiceImpl<ArticleTemplateMapper, ArticleTemplate> 
    implements ArticleTemplateService {

    @Override
    public String insert(ArticleTemplateAddDO dto) {
        ArticleTemplate entity = BeanUtil.copyProperties(dto, ArticleTemplate.class);
        int count = this.getBaseMapper().insert(entity);
        return count <= 0 ? null : entity.getId().toString();
    }

    @Override
    public boolean update(ArticleTemplateUpdateDO dto) {
        ArticleTemplate entity = BeanUtil.copyProperties(dto, ArticleTemplate.class);
        return this.updateById(entity);
    }

    @Override
    public Page<ArticleTemplateBO> page(ArticleTemplateQueryDO dto) {
        Page<ArticleTemplate> page = getLambdaQueryChainWrapper(dto)
            .page(new Page<>(dto.getCurrent(), dto.getSize()));
        if (ObjectUtil.isEmpty(page.getRecords())) {
            return new Page<>(page.getCurrent(), page.getSize(), 0);
        }
        Page<ArticleTemplateBO> boPage = new Page<>(page.getCurrent(), page.getSize(), page.getTotal());
        boPage.setRecords(BeanUtil.copyToList(page.getRecords(), ArticleTemplateBO.class));
        return boPage;
    }

    @Override
    public List<ArticleTemplateBO> list(ArticleTemplateQueryDO dto) {
        List<ArticleTemplate> list = getLambdaQueryChainWrapper(dto).list();
        if (ObjectUtil.isEmpty(list)) {
            return new ArrayList<>();
        }
        return BeanUtil.copyToList(list, ArticleTemplateBO.class);
    }

    @Override
    public Long count(ArticleTemplateQueryDO dto) {
        return getLambdaQueryChainWrapper(dto).count();
    }

    @Override
    public ArticleTemplateBO detail(ArticleTemplateQueryDO dto) {
        ArticleTemplate entity = getLambdaQueryChainWrapper(dto).one();
        if (null == entity) {
            return null;
        }
        return BeanUtil.copyProperties(entity, ArticleTemplateBO.class);
    }

    @Override
    public boolean delete(String id) {
        return this.removeById(id);
    }

    @Override
    public ArticleTemplateBO detail(String id) {
        ArticleTemplate entity = this.getById(id);
        if (null == entity) {
            return null;
        }
        return BeanUtil.copyProperties(entity, ArticleTemplateBO.class);
    }

    // 构建查询条件
    public LambdaQueryChainWrapper<ArticleTemplate> getLambdaQueryChainWrapper(ArticleTemplateQueryDO dto) {
        return this.lambdaQuery()
            .eq(ObjectUtil.isNotEmpty(dto.getId()), ArticleTemplate::getId, dto.getId())
            .in(ObjectUtil.isNotEmpty(dto.getIdList()), ArticleTemplate::getId, dto.getIdList())
            .like(ObjectUtil.isNotEmpty(dto.getTemplateName()), ArticleTemplate::getTemplateName, dto.getTemplateName())
            // ... 其他字段条件
            .orderByDesc(SuperModel::getCreateTime);
    }
}
```

### 5.4 标准模板使用边界
- 本节示例用于说明**默认风格与推荐模式**，不是机械的绝对模板。
- 若生成规范文档、现有模块代码、基础类定义三者发生冲突，优先级为：**现有模块事实 > 架构文档中的明确约束 > 代码生成模板**。
- 在新增代码前，应先参考同模块最近的真实实现，避免仅凭模板生成与现有风格不一致的代码。

---

## 6. 基础类定义

### 6.1 SuperModel（基础实体类）

**位置**: `plt-framework-mybatisplus-starter`

```java
public abstract class SuperModel extends Model implements Serializable {
    
    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @JsonFormat(timezone = "GMT+8", pattern = "yyyy-MM-dd HH:mm:ss")
    @TableField(value = "create_time")
    public Date createTime;

    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @JsonFormat(timezone = "GMT+8", pattern = "yyyy-MM-dd HH:mm:ss")
    @TableField(value = "modify_time", fill = FieldFill.UPDATE, update = "now()")
    public Date modifyTime;

    public static final String CREATE_TIME = "create_time";
    public static final String MODIFY_TIME = "modify_time";
}
```

说明：
- `SuperModel` 已提供通用时间字段，普通 Entity 不应再次重复声明同名字段，避免字段遮蔽和序列化/映射歧义。
- 若实际代码中基类字段类型是 `Date`，则新增代码默认保持 `Date`；除非相关模块已整体迁移到 `LocalDateTime`，并有明确设计说明。

### 6.2 TenantSuperModel（多租户实体类）

```java
public class TenantSuperModel extends SuperModel {
    
    @TableField(value = "tenant_id")
    private Long tenantId;

    public static final String TENANT_ID = "tenant_id";
}
```

### 6.3 PageReq（分页请求基类）

**位置**: `plt-framework-common-core`

```java
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PageReq {
    
    @NotNull(message = "当前页码不能为空")
    @Min(value = 1, message = "当前页码不能小于1")
    private Integer current = 1;

    @NotNull(message = "页面大小不能为空")
    @Min(value = 1, message = "页码大小范围：1-1000")
    @Max(value = 1000, message = "页码大小范围：1-1000")
    private Integer size = 10;

    private String columnName;  // 排序字段
    private String sortType;    // 排序类型 DESC 或 ASC

    public Page toPage() {
        return new Page(this.current, this.size);
    }
}
```

---

## 7. 常用注解速查

### 7.1 实体类注解

| 注解 | 用法 |
|------|------|
| `@TableName("表名")` | 指定表名 |
| `@TableId(value = "id", type = IdType.ASSIGN_ID)` | 指定主键和类型 |
| `@TableLogic(value = "0", delval = "1")` | 逻辑删除 |
| `@TableField(value = "字段名")` | 字段映射 |
| `@Schema(description = "描述")` | Swagger字段说明 |

### 7.2 JSON注解

| 注解 | 用法 |
|------|------|
| `@JsonSerialize(using = ToStringSerializer.class)` | Long类型序列化为字符串（防止JS精度丢失） |
| `@JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")` | 时间格式化 |

### 7.3 校验注解

| 注解 | 用法 |
|------|------|
| `@NotNull(message = "不能为空")` | 非空校验 |
| `@NotBlank(message = "不能为空")` | 字符串非空校验 |
| `@Valid` | 开启参数校验 |
| `@Min/@Max` | 数值范围校验 |

---

## 8. 快速导航

| 需要了解的内容 | 查看位置 |
|--------------|---------|
| 代码生成规范 | [CODE_GENERATION_GUIDE.md](./CODE_GENERATION_GUIDE.md) |
| 框架层说明 | [plt-framework/README.md](./plt-framework/README.md) |
| 公共组件说明 | [plt-commons/README.md](./plt-commons/README.md) |
| 技术架构图 | [plt-framework/doc/images/Architecture.jpg](./plt-framework/doc/images/Architecture.jpg) |

---

## 9. 仓库配置

### 9.1 Maven仓库

```xml
<repositories>
    <repository>
        <id>dvp-maven</id>
        <url>https://ops.bsszxc.com.cn/nexus/repository/dvp-group/</url>
    </repository>
</repositories>
```

### 9.2 发布仓库

| 类型 | 地址 |
|------|------|
| Release | `https://ops.bsszxc.com.cn/nexus/repository/dvp-release/` |
| Snapshot | `https://ops.bsszxc.com.cn/nexus/repository/dvp-snapshots/` |

---

## 10. 各模块详细说明

### 10.1 plt-commons（公共基础组件库）

```
plt-commons/
├── common-all                        # 聚合模块
├── common-base                       # 基础类库（实体、常量、工具类）
├── common-data-permission-starter    # 数据权限Starter
├── common-filling-starter            # 参数自动填充Starter
├── common-log-record-stater          # 日志记录Starter
├── common-mq-stater                  # 消息队列Starter
└── common-pay                        # 支付模块
```

### 10.2 plt-framework（基础开发框架）

```
plt-framework/
├── plt-framework-common-core         # 公共核心组件库
├── plt-framework-api-starter         # API Starter
├── plt-framework-web-starter         # Web Starter
├── plt-framework-mybatisplus-starter # 数据库操作Starter
├── plt-framework-job-starter         # 定时任务Starter
├── plt-framework-stream-starter      # 消息队列Starter
├── plt-framework-cache-starter       # 缓存Starter
├── plt-framework-swagger-starter     # Swagger文档Starter
├── plt-framework-seata-starter       # 分布式事务Starter
├── plt-framework-redis-starter       # Redis操作Starter
├── plt-framework-easypoi-starter     # Excel操作Starter
├── plt-framework-fabric-sdk-starter  # 区块链操作Starter
├── plt-framework-workflow-starter    # 工作流Starter
├── plt-framework-fastdfs-starter     # FastDFS文件Starter
├── plt-framework-validation-starter  # 参数校验Starter
├── plt-framework-monitor-starter     # 监控Starter
└── plt-framework-code-generator      # 代码生成器
```

### 10.3 plt-core-service（核心业务服务）

```
plt-core-service/
├── plt-core-startup     # 启动模块
├── plt-app-service      # 应用服务
├── plt-base-service     # 基础服务
├── plt-cms-service      # CMS内容管理服务（分为 plt-cms-api + plt-cms-core）
├── plt-event-service    # 事件服务
├── plt-idcert-service   # 身份认证服务
├── plt-msg-service      # 消息服务
├── plt-pay-service      # 支付服务
├── plt-order-service    # 订单服务，OTA适配
├── plt-user-service     # 用户服务
└── plt-village-service  # 乡村服务
```

### 10.4 plt-gateway（API网关）

```
plt-gateway/
├── plt-gateway-comm     # 网关公共模块
├── plt-api-gateway      # API网关（对外接口）
├── plt-biz-gateway      # 业务网关
└── plt-boss-gateway     # 管理后台网关
```

### 10.5 plt-auth-service（认证授权服务）

```
plt-auth-service/
├── plt-auth-startup     # 启动模块
├── plt-auth-common      # 认证公共模块
├── plt-bizauth-api      # 业务端认证API
├── plt-bizauth-core     # 业务端认证核心
├── plt-bossauth-api     # 管理端认证API
└── plt-bossauth-core    # 管理端认证核心
```

### 10.6 plt-workflow-service（工作流服务）

```
plt-workflow-service/
├── agile-bpm            # 敏捷BPM引擎
├── agilebpm-autoconfigure # BPM自动配置
├── comm-sdk             # 通用SDK
├── plt-flow-service     # 流程服务
└── rdm-management       # RDM管理
```

---

**文档版本**: 1.0
**最后更新**: 2026-01-21
