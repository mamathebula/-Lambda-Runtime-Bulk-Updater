#!/bin/bash
# ============================================
# Bulk Lambda Runtime Updater
# ============================================
# Update these variables before running:
OLD_RUNTIMES=("python3.8" "python3.9")
NEW_RUNTIME="python3.11"
# ============================================

# Optional: set your target region
# export AWS_REGION=us-east-1

# Build query to match all old runtimes
QUERY_PARTS=()
for rt in "${OLD_RUNTIMES[@]}"; do
  QUERY_PARTS+=("Runtime=='${rt}'")
done
QUERY=$(IFS=" || "; echo "${QUERY_PARTS[*]}")

# Get all functions matching any of the old runtimes
FUNCTIONS=$(aws lambda list-functions \
  --query "Functions[?${QUERY}].[FunctionName, Runtime]" \
  --output text)

if [ -z "$FUNCTIONS" ]; then
  echo "No functions found on: ${OLD_RUNTIMES[*]}"
  exit 0
fi

echo "Found functions to update → ${NEW_RUNTIME}:"
echo "$FUNCTIONS"
echo ""

count=0

# Update all in parallel (batches of 10 to avoid throttling)
while IFS=$'\t' read -r fn current_runtime; do
  (
    echo "Updating $fn (${current_runtime} → ${NEW_RUNTIME})..."
    aws lambda update-function-configuration \
      --function-name "$fn" \
      --runtime "$NEW_RUNTIME" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
      echo "✓ $fn updated"
    else
      echo "✗ $fn failed"
    fi
  ) &

  count=$((count + 1))
  if (( count % 10 == 0 )); then
    wait
  fi
done <<< "$FUNCTIONS"

# Wait for remaining
wait
echo ""
echo "All done. Updated $count functions."
