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

**Step 1: Set up AWS credentials**

If you haven't configured the AWS CLI before, run:

```bash
aws configure
```

It will prompt you for 4 things:

```
AWS Access Key ID: paste your access key here
AWS Secret Access Key: paste your secret key here
Default region name: us-east-1 (or your preferred region)
Default output format: json (or just press Enter)
```

To get your Access Key and Secret Key:
1. Go to AWS Console → IAM → Users → select your user
2. Click "Security credentials" tab
3. Under "Access keys", click "Create access key"
4. Copy the Access Key ID and Secret Access Key

**Step 2: Verify credentials are working**

```bash
aws sts get-caller-identity
```

You should see your account ID and user info. If you get an error, your credentials are wrong.

**Step 3: Run the script**

```bash
chmod +x update-lambda-runtimes.sh
./update-lambda-runtimes.sh
```

### Option 2: AWS CloudShell (no credentials needed)

1. Log into the AWS Console
2. Click the CloudShell icon (terminal icon, top right near the search bar)
3. Make sure you're in the correct region
4. Click Actions → Upload file → select `update-lambda-runtimes.sh`
5. If re-uploading, delete the old file first then re-upload:

```bash
rm update-lambda-runtimes.sh
```

6. Run:

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
- If a Lambda is managed by CloudFormation, this will cause stack drift:
  - The Lambda runtime gets updated, but the CloudFormation template still has the old runtime
  - If the stack is redeployed later, CloudFormation will revert the runtime back to what the template says
  - To fix this permanently, also update the runtime in the CloudFormation template and redeploy the stack
  - Recommended approach: run the script first for the immediate upgrade, then update the templates afterwards so future deployments don't revert it
  - The drift itself doesn't break anything — the Lambda keeps running fine on the new runtime
  - It only causes issues if: the stack is redeployed (reverts the runtime), the stack is deleted and recreated (uses old runtime), or drift detection audits flag the mismatch
  - If the stack is never touched again, no problem. But if it's actively maintained, update the template too
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

## Runtime Reference

| Console Name | Script Value |
|---|---|
| .NET 8 (C#/F#/PowerShell) | `dotnet8` |
| .NET 10 (C#/F#/PowerShell) | `dotnet10` |
| Java 8 on Amazon Linux 2 | `java8.al2` |
| Java 11 | `java11` |
| Java 17 | `java17` |
| Java 21 | `java21` |
| Java 25 | `java25` |
| Node.js 20.x | `nodejs20.x` |
| Node.js 22.x | `nodejs22.x` |
| Node.js 24.x | `nodejs24.x` |
| Python 3.10 | `python3.10` |
| Python 3.11 | `python3.11` |
| Python 3.12 | `python3.12` |
| Python 3.13 | `python3.13` |
| Python 3.14 | `python3.14` |
| Ruby 3.2 | `ruby3.2` |
| Ruby 3.3 | `ruby3.3` |
| Ruby 3.4 | `ruby3.4` |
| Amazon Linux 2 | `provided.al2` |
| Amazon Linux 2023 | `provided.al2023` |
