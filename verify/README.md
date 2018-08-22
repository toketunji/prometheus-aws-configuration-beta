# Observe Prometheus on AWS #

Terraform module to deploy prometheus on AWS. This module creates a virtual machine with prometheus running on it. It does not create any of the 
networking components.

## Deployment ##

In order to deploy this you need some method of the authentication to AWS. In the observe team we utilize aws-vault in order
to authenticate to AWS.

Populate the variables accordingly and perform  terraform plan and then apply.