# CMS 模板ID数据隔离功能实施计划

## 目标
为CMS模块的文章相关表增加 `template_id` 字段，实现不同业务文章的数据隔离。

## 涉及的表 (7个)
- `c_article`
- `c_article_ref_area`
- `c_article_ref_label`
- `c_category`
- `c_category_ref_content`
- `c_comment`
- `c_comment_black_user`

## 实施步骤与进度

### 1. 数据库实体类修改 (plt-cms-core/db/model) [已完成]
- [x] Article.java (字段 + 常量)
- [x] ArticleRefArea.java (字段 + 常量)
- [x] ArticleRefLabel.java (字段 + 常量)
- [x] Category.java (字段 + 常量)
- [x] CategoryRefContent.java (字段 + 常量)
- [x] Comment.java (字段 + 常量)
- [x] CommentBlackUser.java (字段 + 常量)

### 2. POJO类修改 (plt-cms-api/module/*/pojo) [进行中]
- [x] Article相关 (BO, AddDO, QueryDO, UpdateDO)
- [x] Category相关 (BO, AddDO, QueryDO, UpdateDO)
- [x] ArticleRefArea相关 (BO, AddDO, QueryDO, UpdateDO)
- [x] CategoryRefContent相关 (BO, AddDO, QueryDO, UpdateDO)
- [x] Comment相关 (BO, AddDO, QueryDO, UpdateDO)
- [ ] CommentBlackUser相关 (BO, AddDO, QueryDO, UpdateDO)

### 3. MyBatis XML映射文件修改 (plt-cms-core/resources/mapper) [待开始]
- [ ] ArticleMapper.xml
- [ ] ArticleRefAreaMapper.xml
- [ ] ArticleRefLabelMapper.xml
- [ ] CategoryMapper.xml
- [ ] CategoryRefContentMapper.xml
- [ ] CommenMapper.xml
- [ ] CommentBlackUserMapper.xml (Base_Column_List增加template_id)

### 4. 服务层逻辑修改 (templateId自动推算) [待开始]
- [ ] ArticleServiceImpl.java (通过Category推算)
- [ ] CategoryServiceImpl.java (前端传入)
- [ ] ArticleRefAreaServiceImpl.java (通过Article推算)
- [ ] ArticleRefLabelServiceImpl.java (通过Article推算)
- [ ] CategoryRefContentServiceImpl.java (通过Category推算)
- [ ] CommentServiceImpl.java (通过Article推算)
- [ ] CommentBlackUserServiceImpl.java (通过Comment推算)

### 5. 验证 [待开始]
- [ ] Maven编译验证 (SKILL: Maven Compile)
- [ ] 冒烟测试 (API调用验证)

## 验证计划
使用Maven Compile Skill进行编译验证：
```powershell
cd "d:\08-Work\01-博思\10-平台2.0\plt-core-service\plt-cms-service"
$env:JAVA_HOME = "D:\05-Development\jdk-17"; mvn clean compile -DskipTests
```
