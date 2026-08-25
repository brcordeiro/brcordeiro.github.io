---
layout: single
title: "Local Cloud Development with Floci and Terraform"
categories:
  - Infrastructure
  - DevOps
tags:
  - terraform
  - floci
  - aws
  - infrastructure-as-code
  - local-development
---

Infrastructure-as-code has a feedback loop problem. You write a Terraform module, push it, wait for CI, watch it fail against a real cloud account, fix it, repeat. Each iteration costs time and sometimes money. 

LocalStack has been by many teams to fix that problem but became less tenable when it started requiring an auth token even for basic local use. [Floci](https://floci.io/) fills that gap. It is a MIT-licensed, credential-free cloud emulator and supports AWS and Azure services.

This post walks through a practical Terraform workflow using Floci as the local target: installing the emulator, wiring the AWS provider to it, iterating on modules locally, and slotting the same setup into CI.

## Why a Local Cloud Target Matters

Terraform's `plan` output tells you what *will* happen, not what *does* happen. A plan succeeds on a module that tries to attach a non-existent security group to an RDS instance but the apply fails. Running `apply` against localhost instead of a staging account gives you real failure like permission errors, resource dependency cycles, naming conflicts, without the blast radius or the bill.

The other audience is AI coding agents. An agent that can spin up Floci, apply infrastructure, run integration tests against it, and read the output closes its own verification loop without touching a cloud account. No credentials to inject into the context, no risk of runaway Lambda invocations in a shared dev account.

## Installation

Floci ships as a native binary compiled with GraalVM. Install the CLI, which manages all four cloud emulators from one tool:

**macOS / Linux**
```bash
curl -fsSL https://floci.io/install.sh | sh
```

**Windows (PowerShell)**
```powershell
irm https://floci.io/install.ps1 | iex
```

Verify the installation and start the AWS emulator:

```bash
floci doctor   # checks Docker is running and ports are free
floci start    # pulls the image and starts the emulator on :4566
```

The first `start` pulls the Docker image. Subsequent starts take about 24 ms. You can confirm 75 services are live:

```bash
floci status
```

## Wiring Terraform to Floci

The AWS provider accepts endpoint overrides per service. For local iteration, the simplest setup is a `providers.tf` file you swap in during development:

```hcl
# providers.tf (local)
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3         = "http://localhost:4566"
    sqs        = "http://localhost:4566"
    dynamodb   = "http://localhost:4566"
    lambda     = "http://localhost:4566"
    iam        = "http://localhost:4566"
    sts        = "http://localhost:4566"
  }
}
```

A cleaner approach that avoids a separate file is the `AWS_ENDPOINT_URL` environment variable, which the AWS provider respects and routes all service calls through a single endpoint:

```bash
export AWS_ENDPOINT_URL=http://localhost:4566
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
```

With those variables set, your existing `provider "aws" {}` block works without endpoint block needed and no provider file to swap. This is the approach Floci's CLI automates:

```bash
floci env          # prints the export statements
eval $(floci env)  # sources them into your shell
```

On Windows:
```powershell
floci env | Invoke-Expression
```

## A Practical Example: Event-Driven Pipeline

Let's build a small but realistic module: an S3 bucket that triggers a Lambda function via SQS when objects are created. This covers the three services that appear most often in data pipelines.

**`main.tf`**
```hcl
resource "aws_s3_bucket" "landing" {
  bucket = "data-landing-zone"
}

resource "aws_sqs_queue" "object_events" {
  name                      = "s3-object-events"
  visibility_timeout_seconds = 30
}

resource "aws_s3_bucket_notification" "landing_notify" {
  bucket = aws_s3_bucket.landing.id

  queue {
    queue_arn     = aws_sqs_queue.object_events.arn
    events        = ["s3:ObjectCreated:*"]
    filter_suffix = ".parquet"
  }
}

resource "aws_lambda_function" "processor" {
  function_name = "object-processor"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "handler.lambda_handler"
  runtime       = "python3.12"
  filename      = "function.zip"

  environment {
    variables = {
      QUEUE_URL = aws_sqs_queue.object_events.url
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.object_events.arn
  function_name    = aws_lambda_function.processor.arn
  batch_size       = 10
}
```

Apply it locally:

```bash
eval $(floci env)
terraform init
terraform apply -auto-approve
```

Floci runs Lambda in real Docker containers and uses real SQS semantics, so the event source mapping actually fires when a message arrives. Drop a test object into the bucket:

```bash
aws s3 cp sample.parquet s3://data-landing-zone/2026/08/24/batch.parquet
```

And tail the Lambda logs:

```bash
floci logs object-processor --follow
```

## DynamoDB: Iterating on Table Design

Schema evolution in DynamoDB is painful once you have data. Floci makes it cheap to validate your key design before committing:

```hcl
resource "aws_dynamodb_table" "events" {
  name         = "events"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "pk"
  range_key    = "sk"

  attribute {
    name = "pk"
    type = "S"
  }

  attribute {
    name = "sk"
    type = "S"
  }

  global_secondary_index {
    name            = "gsi-by-source"
    hash_key        = "source"
    range_key       = "sk"
    projection_type = "ALL"
  }

  attribute {
    name = "source"
    type = "S"
  }
}
```

Apply, seed test data with the AWS CLI, query through each access pattern. If the GSI is wrong, `terraform destroy && terraform apply` resets in seconds. In a real account, that's a GSI deletion plus propagation delay. Here it's a container restart.

## Keeping Local and Production Configs Separate

The cleanest separation is a `terraform.tfvars` file or a Terraform workspace per environment, combined with a variable that switches the provider endpoint:

```hcl
# variables.tf
variable "aws_endpoint" {
  type    = string
  default = ""  # empty = use real AWS
}

# providers.tf
provider "aws" {
  region = "us-east-1"

  dynamic "endpoints" {
    for_each = var.aws_endpoint != "" ? [var.aws_endpoint] : []
    content {
      s3       = endpoints.value
      sqs      = endpoints.value
      dynamodb = endpoints.value
      lambda   = endpoints.value
      iam      = endpoints.value
    }
  }
}
```

Local:
```bash
terraform apply -var="aws_endpoint=http://localhost:4566"
```

Production: `terraform apply` with no override. The dynamic block is empty and the provider uses real AWS credentials.

## CI Integration

Floci's 24 ms startup makes it practical to run inside every CI job without a shared dev account. A minimal GitHub Actions step:

```yaml
jobs:
  infra-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install Floci
        run: curl -fsSL https://floci.io/install.sh | sh

      - name: Start AWS emulator
        run: floci start --detach

      - name: Terraform apply
        run: |
          eval $(floci env)
          terraform init
          terraform apply -auto-approve

      - name: Run integration tests
        run: |
          eval $(floci env)
          pytest tests/integration/
```

Each job gets an isolated emulator. No teardown step needed, the container dies with the runner. No shared state between jobs, no orphaned resources accumulating costs.

## Comparing Floci and LocalStack

Floci's differentiating choices relative to LocalStack are worth naming explicitly:

- **No auth token**: LocalStack Community requires a token since March 2026. Floci has no account, no token, no telemetry.
- **MIT license**: LocalStack's community tier restricts commercial use in some configurations. Floci is MIT-licensed with no feature gates.
- **Native binary**: Compiled with GraalVM Mandrel. The 24 ms cold start and 13 MiB idle footprint come from running natively, not on a JVM.
- **Real engines**: Lambda functions run in Docker, RDS uses real PostgreSQL/MySQL, ElastiCache runs real Redis. This matters for integration tests that depend on engine-specific behavior (triggers, constraints, Lua scripts).
- **Port compatibility**: Port 4566 is the same as LocalStack. The AWS SDK, Terraform provider, and CLI tools need no reconfiguration.

## What This Changes About the Workflow

The practical shift is that `terraform apply` becomes something you do in the inner loop, not at CI boundary. When a module change breaks a resource dependency, you find out in 10 seconds on your laptop instead of 5 minutes into a CI job. Lambda cold start behavior, IAM policy denials, SQS redrive logic, all of these are observable locally without staging environment access.

The credential-free design removes the category of incident where a developer runs infrastructure code against the wrong account. There is no wrong account to accidentally target when the default target is localhost.

Floci won't replace staging. Smoke tests against real infrastructure before production are worth running. The main benefit comes from it eliminating the round-trip for the majority of development iteration that doesn't require real account fidelity.
