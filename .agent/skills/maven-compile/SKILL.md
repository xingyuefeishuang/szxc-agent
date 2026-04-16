---
name: Maven Compile
description: 使用 JDK 17 和 Maven 3.5.4 编译 plt-core-service 项目模块
---

# Maven 编译技能

本技能用于编译 `plt-core-service` 项目下的各个子模块。

## 环境配置

| 配置项 | 路径/值 |
|--------|---------|
| JDK 版本 | JDK 17 |
| JDK 路径 | `D:\05-Development\jdk-17` |
| Maven 版本 | 3.5.4 |
| Maven 路径 | `D:\05-Development Tools\apache-maven-3.5.4` |
| Settings 文件 | `D:\05-Development Tools\apache-maven-3.5.4\conf\settings.xml` |
| 本地仓库 | `D:\05-Development Tools\apache-maven-repo` |
| 远程仓库 | `https://ops.bsszxc.com.cn/nexus/repository/dvp-group/` |

## 编译步骤

### 1. 编译单个子模块

进入对应的子模块目录，执行以下命令：

```powershell
# 设置 JAVA_HOME 环境变量并编译
$env:JAVA_HOME = "D:\05-Development\jdk-17"; mvn clean compile -DskipTests
```

### 2. 编译指定模块（带 install）

如果需要将编译结果安装到本地仓库：

```powershell
$env:JAVA_HOME = "D:\05-Development\jdk-17"; mvn clean install -DskipTests
```

### 3. 仅编译不清理

快速增量编译（不执行 clean）：

```powershell
$env:JAVA_HOME = "D:\05-Development\jdk-17"; mvn compile -DskipTests
```

### 4. 编译并运行测试

```powershell
$env:JAVA_HOME = "D:\05-Development\jdk-17"; mvn clean test
```

### 5. 使用自定义 settings.xml

如果需要使用特定的 settings.xml 文件：

```powershell
$env:JAVA_HOME = "D:\05-Development\jdk-17"; mvn clean compile -DskipTests -s "D:\05-Development Tools\apache-maven-3.5.4\conf\settings.xml"
```

## 常用模块路径

| 模块名称 | 相对路径 |
|----------|----------|
| plt-cms-service | `plt-core-service\plt-cms-service` |
| plt-user-service | `plt-core-service\plt-user-service` |
| plt-base-service | `plt-core-service\plt-base-service` |
| plt-msg-service | `plt-core-service\plt-msg-service` |
| plt-auth-service | `plt-core-service\plt-auth-service` |
| plt-gateway | `plt-gateway` |
| plt-boss-gateway | `plt-boss-gateway` |

## 编译整个 plt-core-service

在项目根目录下编译所有子模块：

```powershell
cd "d:\08-Work\01-博思\10-平台2.0\plt-core-service"
$env:JAVA_HOME = "D:\05-Development\jdk-17"; mvn clean compile -DskipTests
```

## 常见问题

### 1. JAVA_HOME 环境变量错误

如果出现 `The JAVA_HOME environment variable is not defined correctly` 错误，确保：
- JDK 路径正确：`D:\05-Development\jdk-17`
- 路径中包含 `bin` 目录和 `java.exe`

### 2. 依赖下载超时

如果下载依赖超时，可以：
- 检查网络连接
- 配置代理（在 settings.xml 中）
- 使用 `-o` 参数离线编译（仅使用本地仓库）

### 3. 编译内存不足

增加 Maven 内存配置：

```powershell
$env:MAVEN_OPTS = "-Xmx2048m -XX:MaxPermSize=512m"
$env:JAVA_HOME = "D:\05-Development\jdk-17"; mvn clean compile -DskipTests
```

## 快速命令示例

// turbo-all

```powershell
# 编译 plt-cms-service
cd "d:\08-Work\01-博思\10-平台2.0\plt-core-service\plt-cms-service"
$env:JAVA_HOME = "D:\05-Development\jdk-17"; mvn clean compile -DskipTests
```
