# Lambda Runtime Bulk Updater — STAR Method

## Situation

During my internship, I was assigned a project to update the runtimes of Lambda functions across the AWS account. Several functions were running on deprecated runtimes (Python 3.8, Python 3.9) that were approaching end of support. These needed to be upgraded to a supported version to maintain security patches and compatibility.

The account had a growing number of Lambda functions, and the only available method was updating each one manually through the AWS Console — clicking into each function, changing the runtime, and saving. This was time-consuming, repetitive, and prone to human error, especially when dealing with dozens or hundreds of functions.

## Task

My goal was to find a way to update all Lambda functions running on deprecated runtimes to a supported version efficiently, without having to touch each function individually in the console. The solution needed to:

- Handle multiple old runtimes in a single run (e.g. Python 3.8 and 3.9 together)
- Work at scale (100+ functions)
- Avoid hitting AWS API rate limits
- Be simple enough for any team member to use

## Action

I built a bash script that automates the entire process:

- The script queries the AWS Lambda API to discover all functions running on the specified old runtimes
- It updates them in parallel, batched in groups of 10 to stay within AWS API throttling limits
- Each batch completes before the next one starts, ensuring reliability at scale
- The script outputs real-time progress showing which functions were updated and which failed
- It can be run locally with AWS CLI credentials or directly in AWS CloudShell with zero setup

I also wrote a comprehensive README with step-by-step instructions, a full runtime reference table, and examples for Python, Node.js, Java, Ruby, and .NET — so anyone on the team could use it without needing to understand the internals.

## Result

What previously took hours of manual clicking through the AWS Console was reduced to a single command that completes in minutes. The script successfully updated all targeted Lambda functions with zero errors. Key outcomes:

- A task that took an entire day manually now runs in under 5 minutes
- Eliminated human error from manual runtime selection
- The script is reusable for future runtime upgrades — just change two variables
- Documented and shared with the team as a standard operational tool
- Applicable to any AWS account regardless of the number of Lambda functions
