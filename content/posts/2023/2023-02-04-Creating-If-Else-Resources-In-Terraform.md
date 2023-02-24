---
categories: terraform
date: "2023-02-24T08:00:00Z"
title: Creating If/Else Resources in Terraform
draft: false
---

A nice simple one. For some infrastructure at work I needed a way to provide an override value for teh DNS name in a production system. Otherwise, we could just use a calculated value with the environment name etc from earlier during testing. Something like the below shows how to pass an override and use that instead of teh 'calculated value' used for dev instances. It might not be rocket science but thought it worth sharing and remembering for my own needs. The example creates a local file for simplicity in showing the mechanism.

First, create a file call main.tf and use the below

```terraform
# PROVIDER
terraform {}

# VARIABLES
variable "my_dev_value" {
  description = "Example my_dev_value"
  type        = string
  default     = "DEV"
}
variable "my_specific_prod_value" {
  description = "Example my_specific_prod_value"
  type        = string
  default     = ""
}

# LOCALS
locals {
  calculated_dev_value_used_in_many_places = lower(format("calculated-value-%s", var.my_dev_value))
}

resource "local_file" "dev_ord_prod_var_value" {
  # if 'my_specific_prod_value' is blank, then fill in the dev value, if it is prod, put in the prod value
  content  = "${var.my_specific_prod_value}" == "" ? "${local.calculated_dev_value_used_in_many_places}" : "${var.my_specific_prod_value}"
  filename = "file.txt"
}
```

Then run it like this

```bash
terraform init
terraform apply -auto-approve                                                  # Uses the default value
terraform apply -auto-approve -var my_specific_prod_value=SPECIFIC-PROD-VALUE  # Uses the passed value
```
