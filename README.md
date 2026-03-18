# Lambda Runtime Bulk Updater

Bash script that updates the runtime of multiple Lambda functions in parallel across your AWS account.

## Prerequisites

- AWS CLI installed and configured (`aws configure`)
- Permissions: `lambda:ListFunctions` and `lambda:UpdateFunctionConfiguration`

## Setup

1. Open `update-lambda-runtimes.sh`
2. Edit these two variables at the top:

```bash
OLD_RUNTIMES=("python3.8" "python3.9")   # runtimes to replace
NEW_RUNTIME="python3.11"                   # runtime to update to
```

3. (Optional) Set your target region if not using your default:

```bash
export AWS_REGION=us-east-1
```

## Run

### Option 1: Local Terminal

```bash
aws configure   # set up credentials first
./update-lambda-runtimes.sh
```

If you get a permission denied error:

```bash
chmod +x update-lambda-runtimes.sh
./update-lambda-runtimes.sh
```

### Option 2: AWS CloudShell (no credentials needed)

1. Log into the AWS Console
2. Click the CloudShell icon (terminal icon, top right near the search bar)
3. Make sure you're in the correct region
4. Click Actions → Upload file → select `update-lambda-runtimes.sh`
5. Run:

```bash
chmod +x update-lambda-runtimes.sh
./update-lambda-runtimes.sh
```

CloudShell uses your console session credentials automatically — no setup required.

## Example Output

```
Found functions to update → python3.11:
MyFunction1    python3.8
MyFunction2    python3.9
ApiHandler     python3.9

Updating MyFunction1 (python3.8 → python3.11)...
Updating MyFunction2 (python3.9 → python3.11)...
Updating ApiHandler (python3.9 → python3.11)...
✓ MyFunction1 updated
✓ MyFunction2 updated
✓ ApiHandler updated

All done. Updated 3 functions.
```

## Notes

- Updates run in batches of 10 automatically to avoid AWS API throttling. To change the batch size, edit `count % 10` in the script to your preferred number (e.g. `count % 5` for batches of 5)
  - Example: 1000 functions = 100 batches of 10. Sends 10 updates in parallel → waits for all 10 to finish → sends the next 10 → repeats until all 1000 are done
- If a Lambda is managed by CloudFormation, this will cause stack drift — acceptable for bulk runtime upgrades but be aware
- The script only targets the current region. Run it again with a different `AWS_REGION` for multi-region accounts
- Common runtime values and examples:

  **Python:**
  ```bash
  OLD_RUNTIMES=("python3.8" "python3.9")
  NEW_RUNTIME="python3.13"
  ```

  **Node.js:**
  ```bash
  OLD_RUNTIMES=("nodejs16.x" "nodejs18.x")
  NEW_RUNTIME="nodejs20.x"
  ```

  **Java:**
  ```bash
  OLD_RUNTIMES=("java11")
  NEW_RUNTIME="java21"
  ```

  **Mixed (all old runtimes at once):**
  ```bash
  OLD_RUNTIMES=("python3.8" "python3.9" "nodejs16.x" "java11")
  NEW_RUNTIME="python3.13"
  ```
  ⚠️ Only mix runtimes of the same language — updating a Node.js function to a Python runtime will break it.
