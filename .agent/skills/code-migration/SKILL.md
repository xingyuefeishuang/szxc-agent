---
name: Code Migration
description: 在项目模块之间迁移代码的标准步骤，包含 BOM 编码处理和包名替换
---

# 代码迁移技能 (Code Migration)

本技能用于在不同项目模块之间迁移 Java 代码，解决常见的编码和依赖问题。

## 常见问题及解决方案

### 1. UTF-8 BOM 编码问题

**问题表现**:
- 编译报错: `非法字符: '\ufeff'`
- 编译报错: `需要 class、interface、enum 或 record`

**问题原因**:
源代码文件带有 UTF-8 BOM 头 (`0xEF 0xBB 0xBF`)，Java 编译器不识别这个字符。

**解决方案**:
使用以下 Python 脚本移除 BOM：

```python
import os
import glob

# 修改为目标目录路径
path = r'目标目录路径'
files = glob.glob(os.path.join(path, '**/*.java'), recursive=True)

for f in files:
    with open(f, 'rb') as file:
        content = file.read()
    
    if content[:3] == b'\xef\xbb\xbf':
        with open(f, 'wb') as file:
            file.write(content[3:])
        print(f'Fixed BOM in: {os.path.basename(f)}')
    else:
        print(f'No BOM in: {os.path.basename(f)}')

print('Done!')
```

**注意事项**:
- PowerShell 的 `Get-Content` 和 `Set-Content` 可能会引入编码问题，建议使用 Python 或直接使用 `robocopy` 复制文件
- 不要使用 PowerShell 的字符串替换来处理文件内容，可能导致编码损坏

### 2. 包名替换

**问题表现**:
复制的文件中包名仍指向原项目包，如 `cn.com.bsszxc.plt.opr` 需改为 `cn.com.bsszxc.plt.mobile`

**解决方案**:
使用 Python 脚本批量替换：

```python
import os
import glob
import re

# 修改为目标目录路径
path = r'目标目录路径'
old_package = 'cn.com.bsszxc.plt.opr'
new_package = 'cn.com.bsszxc.plt.mobile'

files = glob.glob(os.path.join(path, '**/*.java'), recursive=True)

for f in files:
    with open(f, 'r', encoding='utf-8') as file:
        content = file.read()
    
    # 替换包声明和导入语句
    new_content = content.replace(old_package + '.', new_package + '.')
    
    if content != new_content:
        with open(f, 'w', encoding='utf-8') as file:
            file.write(new_content)
        print(f'Updated: {os.path.basename(f)}')

print('Done!')
```

### 3. 文件复制推荐方式

**推荐使用 robocopy (Windows)**:
```powershell
robocopy "源目录" "目标目录" *.java /E
```

**不推荐方式**:
- 使用 PowerShell 的 `Get-Content`/`Set-Content` 进行复制并替换（可能导致编码问题）
- 使用 `&&` 连接命令（PowerShell 某些版本不支持）

## 迁移步骤

### 步骤1: 分析依赖关系

在迁移之前，先分析要迁移的代码依赖哪些类：

1. **Controller 层**: 通常依赖 Service 接口
2. **Service 层**: 依赖 API 接口、POJO 类、工具类、监听器等
3. **POJO 层**: 可能依赖其他 POJO 类

### 步骤2: 复制文件

1. 使用 `robocopy` 复制源文件到目标目录
2. 按照层次结构复制：Controller → Service → ServiceImpl → POJO → 工具类

### 步骤3: 处理 BOM

运行 BOM 移除脚本处理所有复制的 Java 文件。

### 步骤4: 替换包名

运行包名替换脚本，将所有旧包名替换为新包名。

### 步骤5: 编译验证

```powershell
$env:JAVA_HOME = "D:\05-Development\jdk-17"
mvn compile -DskipTests
```

### 步骤6: 处理缺失依赖

根据编译错误，逐一复制缺失的依赖文件：
- `程序包xxx不存在` → 复制对应的包/类文件
- `找不到符号` → 检查类是否已复制，包名是否正确

## 常见错误对照表

| 错误信息 | 可能原因 | 解决方案 |
|---------|---------|---------|
| `非法字符: '\ufeff'` | 文件包含 BOM | 运行 BOM 移除脚本 |
| `程序包xxx不存在` | 缺少依赖类 | 复制缺失的类文件 |
| `找不到符号` | 类未导入或不存在 | 检查 import 语句和类文件 |
| `未结束的字符串文字` | 编码转换错误导致中文乱码 | 重新复制文件，避免使用 PowerShell 处理 |

## 快速修复脚本

将以下脚本保存为 `fix_migration.py`，放在项目根目录执行：

```python
import os
import glob
import sys

def fix_bom(path):
    """移除 UTF-8 BOM"""
    files = glob.glob(os.path.join(path, '**/*.java'), recursive=True)
    fixed = 0
    for f in files:
        with open(f, 'rb') as file:
            content = file.read()
        if content[:3] == b'\xef\xbb\xbf':
            with open(f, 'wb') as file:
                file.write(content[3:])
            fixed += 1
    print(f'Fixed BOM in {fixed} files')
    return fixed

def replace_package(path, old_pkg, new_pkg):
    """替换包名"""
    files = glob.glob(os.path.join(path, '**/*.java'), recursive=True)
    updated = 0
    for f in files:
        with open(f, 'r', encoding='utf-8') as file:
            content = file.read()
        new_content = content.replace(old_pkg + '.', new_pkg + '.')
        if content != new_content:
            with open(f, 'w', encoding='utf-8') as file:
                file.write(new_content)
            updated += 1
    print(f'Updated package in {updated} files')
    return updated

if __name__ == '__main__':
    if len(sys.argv) < 4:
        print('Usage: python fix_migration.py <path> <old_package> <new_package>')
        sys.exit(1)
    
    path = sys.argv[1]
    old_pkg = sys.argv[2]
    new_pkg = sys.argv[3]
    
    print(f'Processing files in: {path}')
    fix_bom(path)
    replace_package(path, old_pkg, new_pkg)
    print('Done!')
```

使用方式：
```powershell
python fix_migration.py "src\main\java\cn\com\bsszxc\plt\mobile" "cn.com.bsszxc.plt.opr" "cn.com.bsszxc.plt.mobile"
```
