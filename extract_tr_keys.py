import os
import re

# 匹配 tr('key') 或 tr("key") 的正则表达式
pattern = r'tr\(\s*["\']([^"\']+)["\']\s*\)'

# 要扫描的代码目录（根据项目结构调整）
scan_dirs = ['lib/pages', 'lib/main.dart', 'lib/po']

# 收集所有提取的key
translations = set()

# 扫描文件
for dir_path in scan_dirs:
    if os.path.isfile(dir_path):
        # 处理单个文件
        files = [dir_path]
    else:
        # 处理目录下的所有.dart文件
        files = [
            os.path.join(root, file)
            for root, _, files in os.walk(dir_path)
            for file in files
            if file.endswith('.dart')
        ]
    
    for file in files:
        with open(file, 'r', encoding='utf-8') as f:
            content = f.read()
            # 查找所有匹配的key
            matches = re.findall(pattern, content)
            for key in matches:
                translations.add(key)

# 生成.pot文件内容
pot_content = ''
for key in sorted(translations):
    pot_content += f'msgid "{key}"\n'
    pot_content += 'msgstr ""\n\n'

# 保存为.pot文件
with open('lib/po/app.pot', 'w', encoding='utf-8') as f:
    f.write(pot_content)

print(f'已提取 {len(translations)} 个翻译键，保存至 lib/po/app.pot')