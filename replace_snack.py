import os, glob
updated = 0
for filepath in glob.iglob('/home/mahdi/flutter_project/Right-Route-Running/lib/**/*.dart', recursive=True):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        if 'SnackPosition.BOTTOM' in content:
            content = content.replace('SnackPosition.BOTTOM', 'SnackPosition.TOP')
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f'Updated {filepath}')
            updated += 1
    except Exception as e:
        pass
print(f'Total files updated: {updated}')
