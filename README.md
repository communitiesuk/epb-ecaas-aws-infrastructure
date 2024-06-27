# EPB ECaaS AWS Infrastructure

Infrastructure definition using Terraform for Energy Calculation as a Service (ECaaS).

## Terraform Setup

### Terraform installation

1. Install Terraform:
   <https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli>
2. Install AWS Vault: <https://github.com/99designs/aws-vault>
3. Set up AWS access [via aws-vault profile](https://tech-docs.epcregisters.net/dev-setup.html#create-an-aws-vault-profile)

### tfvars

In terraform, we use modules which may require variables to be set. Even the top level (root) terraform definitions may require variables.

These variables may be sensitive, so they should be stored securely and not checked into git.

To avoid having to type each var whenever you run `terraform apply` command, it is good idea to keep a private set of variables in `tfvars` file.
Better yet, to make things less verbose to run, store them in `.auto.tfvars` file.

Example `.auto.tfvars` file:

```hcl
account_map = {
  "integration" = "123456789012",
  "staging" = "1111111111111",
}

prefix = "some-string-prefix"

some_list = [1, 5, 2]
```

More info in [official documentation](https://developer.hashicorp.com/terraform/language/values/variables)

#### Maintaining tfvars

tfvars are currently stored alongside the state file in the S3 bucket `epbr-{env}-terraform-state`.
When updating the tfvars, make sure you update the file in the S3 bucket to avoid others being unable to deploy their changes.

There are handy `just` scripts which automate the process:

```bash
just tfvars-put ecaas-infrastructure {env}  # where env is one of ecaas-integration, ecaas-staging or ecaas-production

just tfvars-get ecaas-infrastructure {env}  # where env is one of ecaas-integration, ecaas-staging or ecaas-production
```

**NOTE**
 * `tfvars-put` uploads the local file `{env}.tfvars` to the remote S3 state storage bucket
 * `tfvars-get` downloads the remote tfvars file into `{env}.tfvars` **and also** copies it into `.auto.tfvars` locally

So a typical development flow might be:

1. `tfvars-get` from the remote 
2. Update values in the file `{env}.tfvars`
3. `tfvars-put` to push the updates to the remote
4. `tfvars-get` to update `.auto.tfvars` file
5. Run a `terraform apply` that will use values from the `.auto.tfvars` file

#### Securely handling tfvars

Currently the tfvars are stored in plaintext on your machine to run the terraform scripts.
We are planning on moving sensitive values to a more secure place.
Until then, take care when handling the tfvars

* Don't check them into git!
* When adding new vars, mark them as `sensitive = true` in Terraform
* Don't store tfvars files on your machine - only download them to run the script, then delete
* Only pass them to others via the S3 bucket, as documented in previous section


## Terraforming infrastrcuture
The repo is subdivided into terraform for the following ECaaS infrastructure:

- /ecaas-infrastructure terraform for all resources in ecaas-integration, ecaas-staging and ecaas-production accounts
- /ci terraform for all resources in AWS EPB ci account

### Making changes to ecaas-infrastructure

1. From root `cd ecaas-infrastructure`

2. Switch profile to environment you want to make changes in

   `just set-profile {AWS_profile_name_for_environment}`

   Example:

   `just set-profile ecaas-integration`

3. Initialize your Terraform environment using the correct backend-config file

   `aws-vault exec {AWS_profile_name_for_environment} -- terraform init -backend-config=backend_{profile}.hcl`

   Example:

   `aws-vault exec ecaas-integration -- terraform init -backend-config=backend_ecaas_integration.hcl`

4. To run terraform you will need to download a copy of the parameters stored as tfvars in the environment. To do this run

   `just tfvars-get ecaas-infrastructure {AWS_profile_name_for_environment}`
   
   Example:  
   `just tfvars-get ecaas-infrastructure ecaas-integration`

5. Run a terraform plan and check all planned changes are expected:

   `aws-vault exec {AWS_profile_name_for_environment} -- terraform plan -out=tfplan`

   Example:  
   `aws-vault exec ecaas-integration -- terraform plan`

6. Once you are happy that all the changes are as expected, apply them

   `aws-vault exec {AWS_profile_name_for_environment} -- terraform apply tfplan`

7. (Optional) Once successfully applied, you should be able to see the changes in the AWS Management Console.
   Sanity check the changes have been applied as you expected.


## Deleting infrastructure

When deployed infrastructure is no longer needed

1. `aws-vault exec {AWS_profile_name_for_environment} -- terraform destroy`

2. Because the state of the S3 and DynamoDB are not stored in a permanent backend, those resources should be deleted
   through AWS console


## Other infrastructure related tasks

You can see full documentation about
[working in our AWS accounts](https://tech-docs.epcregisters.net/aws.html#working-in-our-aws-accounts) in tech
docs.


## Making changes to ci
1. From root `cd ci`
2. Follow the steps from applying Terraform changes to ecaas-infrastructure, but use your profile for the ecaas-ci 
   account, e.g. `just set-profile ecaas-ci`
3. Download the latest version of `.auto.tfvars` from AWS using the just command `tfvars-get-for-ci`
4. If you make changes to `.auto.tfvars` remember to upload it back to AWS using `tfvars-put-for-ci`


## Setting up tfstate management (Initial setup only)

__Note__: Do not do this if the infrastructure state management exists already - only for use in fresh AWS accounts

Before starting to terraform the infrastructure of an environment, you will need to set up an S3 bucket and DynamoDB 
table, so that terraform can store / lock the state.

The infrastructure used for an S3 backend is defined in the `/state-init` directory:

1. `cd /state-init`

2. Initialize your Terraform enivronment  
   `aws-vault exec {profile_name_for_AWS_environment} -- terraform init`

   Example:  
   `aws-vault exec ecaas-newaccount -- terraform init`

3. Create infrastructure
   `aws-vault exec {profile_name_for_AWS_environment} -- terraform apply`

   Example:  
   `aws-vault exec ecaas-newaccount -- terraform apply`
