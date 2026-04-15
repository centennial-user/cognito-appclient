#!/usr/bin/env bash
set -euo pipefail

FILE="variables.tf"

# 10 names you want in custom_attributes
NAMES=(
  "employee_id"
  "address"
  "city"
  "state"
  "postal_code"
  "country"
  "manager_id"
  "cost_center"
  "department_code"
  "site_code"
)

# Build replacement HCL blocks with requested schema defaults
build_blocks() {
  local total="${#NAMES[@]}"
  local i=0

  for n in "${NAMES[@]}"; do
    i=$((i + 1))
    echo "    {"
    echo "      name                     = \"${n}\""
    echo "      attribute_data_type      = \"String\""
    echo "      developer_only_attribute = false"
    echo "      mutable                  = true"
    echo "      required                 = false"
    echo "      min_length               = 0"
    echo "      max_length               = 2048"
    if [[ "$i" -lt "$total" ]]; then
      echo "    },"
    else
      echo "    }"
    fi
  done
}

NEW_BLOCKS="$(build_blocks)"

cp "$FILE" "${FILE}.bak"

awk -v repl="$NEW_BLOCKS" '
BEGIN {
  in_block=0
  block=""
  has_target=0
}
{
  if (!in_block && $0 ~ /^[[:space:]]*\{[[:space:]]*$/) {
    in_block=1
    block=$0 ORS
    has_target=0
    next
  }

  if (in_block) {
    block=block $0 ORS
    if ($0 ~ /name[[:space:]]*=[[:space:]]*"employee_id"/) {
      has_target=1
    }

    if ($0 ~ /^[[:space:]]*}[[:space:]]*,?[[:space:]]*$/) {
      if (has_target) {
        print repl
      } else {
        printf "%s", block
      }
      in_block=0
      block=""
      has_target=0
    }
    next
  }

  print
}
END {
  if (in_block) {
    printf "%s", block
  }
}
' "$FILE" > "${FILE}.tmp"

mv "${FILE}.tmp" "$FILE"

echo "Updated $FILE (backup: ${FILE}.bak)"
