#!/usr/bin/env bash
set -eu

OUTPUT_FILE="schema.out"

# Input names for schema blocks.
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

# Start with a clean output file.
: > "$OUTPUT_FILE"

# Emit schema blocks.
for n in "${NAMES[@]}"; do
  cat >> "$OUTPUT_FILE" <<EOF
schema {
  attribute_data_type      = "String"
  developer_only_attribute = false
  mutable                  = true
  name                     = "${n}"
  required                 = false
  string_attribute_constraints {
    min_length = 0
    max_length = 2048
  }
}

EOF
done

# Emit custom attribute key/value lines.
cat >> "$OUTPUT_FILE" <<'EOF'
# Custom attribute mappings
EOF

for n in "${NAMES[@]}"; do
  echo "\"custom:${n}\" = \"${n}\"" >> "$OUTPUT_FILE"
done

echo "Generated schema blocks and mappings in $OUTPUT_FILE"
