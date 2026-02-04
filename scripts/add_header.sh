#!/bin/bash

output_dir="ruleset_txt"

for file in "$output_dir"/*.txt; do
    name=$(basename "$file" .txt)
    count=$(grep -v '^#' "$file" | sed '/^$/d' | wc -l)

    sed -i "1i # 规则名称: $name" "$file"
    sed -i "2i # 规则统计: $count" "$file"
    sed -i '3a\\' "$file"
done
