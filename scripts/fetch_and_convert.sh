#!/bin/bash

source_list="ruleset_sources.txt"
output_dir="ruleset_txt"

mkdir -p "$output_dir"

while IFS= read -r remote_url; do
    [[ -z "$remote_url" ]] && continue

    # 从 URL 提取文件名，例如 GeositeCN.yaml → GeositeCN
    base=$(basename "$remote_url")
    name="${base%.*}"

    temp_file="${name}_remote.yaml"
    output_file="$output_dir/$name.list"

    echo "处理规则集：$name"

    # 下载远程规则
    curl -s -L "$remote_url" -o "$temp_file"

    # 如果本地已有旧文件，检查是否变化
    if [ -f "$output_file" ]; then
        old_hash=$(grep -v '^#' "$output_file" | md5sum | cut -d' ' -f1)

        new_payload=$(yq '.payload[]' "$temp_file" | sed 's/^- *//' | sed 's/#.*//' | sed 's/ //g' | sed '/^$/d')
        new_hash=$(echo "$new_payload" | md5sum | cut -d' ' -f1)

        if [ "$old_hash" = "$new_hash" ]; then
            echo "→ $name 无变化，跳过"
            continue
        fi
    fi

    # 规则有变化 → 开始转换
    echo "# RuleSet generated from remote payload" > "$output_file"
    echo "# Source: $remote_url" >> "$output_file"
    echo "# Generated at $(date)" >> "$output_file"
    echo "" >> "$output_file"

    yq '.payload[]' "$temp_file" | \
    sed 's/^- *//' | \
    sed 's/#.*//' | \
    sed 's/ //g' | \
    sed '/^$/d' | \
    sort -u >> "$output_file"

    echo "→ $name 转换完成"

done < "$source_list"
