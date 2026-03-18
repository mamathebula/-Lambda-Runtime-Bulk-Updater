#!/bin/bash
# ============================================
# Bulk Lambda Runtime Updater
# ============================================
# Update these variables before running:
OLD_RUNTIMES=("python3.11" "python3.10")
NEW_RUNTIME="python3.13"
# ============================================

# Optional: set your target region
# export AWS_REGION=us-east-1

FUNCTIONS=""

# Get functions for each old runtime
for rt in "${OLD_RUNTIMES[@]}"; do
  RESULT=$(aws lambda list-functions \
    --query "Functions[?Runtime==\`${rt}\`].[FunctionName, Runtime]" \
    --output text 2>&1)
  if [ -n "$RESULT" ]; then
    if [ -n "$FUNCTIONS" ]; then
      FUNCTIONS="${FUNCTIONS}
${RESULT}"
    else
      FUNCTIONS="$RESULT"
    fi
  fi
done

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
