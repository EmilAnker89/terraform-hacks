cd ~/terraform-modules/infrastructures/cluster2.eu-west-1.e-boks-int.com/tier3-s3

aws-vault exec eboks-int-test -d 12h -- terraform show -json > ~/state.json
cat ~/state.json | jq '.values.root_module.child_modules[4].address'
# "module.s3"
cat ~/state.json | jq '.values.root_module.child_modules[4].resources[].address'
"aws_iam_access_key.key_artifact"
"aws_iam_user.iam_artifact"
"aws_iam_user_policy.policy_artifact"
"aws_s3_bucket.s3_bucket_buffer"
"aws_s3_bucket.s3_bucket_storage"
"aws_s3_bucket_policy.bucket_policy-buffer"
"aws_s3_bucket_policy.bucket_policy-storage"
"aws_s3_bucket_public_access_block.block_msg_buffer"
"aws_s3_bucket_public_access_block.block_msg_storage"
"aws_secretsmanager_secret.s3_secret"
"aws_secretsmanager_secret_version.s3_access"
"data.template_file.buffer_policy_template"
"data.template_file.iam_policy_template"
"data.template_file.secret_template"
"data.template_file.storage_policy_template"

cat ~/state.json | jq '.values.root_module.child_modules[0].address'
"module.iam_user_developer"
cat ~/state.json | jq '.values.root_module.child_modules[0].resources[].address'
"aws_iam_access_key.access_key"
"aws_iam_user.iam_user"
"aws_secretsmanager_secret.iam_secret"
"aws_secretsmanager_secret_version.s3_access"
"data.template_file.secret_template"

# brief overview of resources in state file:
terraform state list


# move resource to other module. write result to tmp.statefile

aws-vault exec eboks-int-test -d 12h -- terraform state pull > ~/tmp.tfstate
aws-vault exec eboks-int-test -d 12h -- terraform state mv -state=~/tmp.tfstate -state-out=~/tmp.tfstate module.s3.aws_iam_user.iam_artifact module.iam_user_artifactservice.aws_iam_user.iam_user

aws-vault exec int-test-load -d 12h -- terraform state mv module.s3.aws_iam_user.iam_artifact module.iam_user_artifactservice.aws_iam_user.iam_user




# Move one resource at a time:
# Policies, roles, templates etc. can just be recreated. Users, credentials and buckets just cannot!
ENV=preprod
aws-vault exec ${ENV} -d 12h -- terraform state mv module.s3.data.template_file.secret_template module.iam_user_artifactservice.data.template_file.secret_template
aws-vault exec ${ENV} -d 12h -- terraform state mv module.s3.aws_iam_access_key.key_artifact module.iam_user_artifactservice.aws_iam_access_key.access_key
aws-vault exec ${ENV} -d 12h -- terraform state mv module.s3.aws_iam_user.iam_artifact module.iam_user_artifactservice.aws_iam_user.iam_user
aws-vault exec ${ENV} -d 12h -- terraform state mv module.s3.aws_s3_bucket.s3_bucket_buffer module.s3_message_buffer.aws_s3_bucket.s3_bucket
aws-vault exec ${ENV} -d 12h -- terraform state mv module.s3.aws_s3_bucket.s3_bucket_storage module.s3_perm_storage.aws_s3_bucket.s3_bucket
aws-vault exec ${ENV} -d 12h -- terraform state mv module.s3.aws_secretsmanager_secret.s3_secret module.iam_user_artifactservice.aws_secretsmanager_secret.iam_secret
aws-vault exec ${ENV} -d 12h -- terraform state mv module.s3.aws_secretsmanager_secret_version.s3_access module.iam_user_artifactservice.aws_secretsmanager_secret_version.s3_access
aws-vault exec ${ENV} -d 12h -- terraform state mv module.s3.aws_s3_bucket_public_access_block.block_msg_buffer module.s3_message_buffer.aws_s3_bucket_public_access_block.block_public_access
aws-vault exec ${ENV} -d 12h -- terraform state mv module.s3.aws_s3_bucket_public_access_block.block_msg_storage module.s3_perm_storage.aws_s3_bucket_public_access_block.block_public_access
aws-vault exec ${ENV} -d 12h -- terraform state mv module.s3.aws_s3_bucket_policy.bucket_policy-buffer module.s3_message_buffer.aws_s3_bucket_policy.bucket_policy-storage
aws-vault exec ${ENV} -d 12h -- terraform state mv module.s3.aws_s3_bucket_policy.bucket_policy-storage module.s3_perm_storage.aws_s3_bucket_policy.bucket_policy-storage



terraform state mv module.s3.data.template_file.secret_template module.iam_user_artifactservice.data.template_file.secret_template
terraform state mv module.s3.aws_iam_access_key.key_artifact module.iam_user_artifactservice.aws_iam_access_key.access_key
terraform state mv module.s3.aws_iam_user.iam_artifact module.iam_user_artifactservice.aws_iam_user.iam_user
terraform state mv module.s3.aws_s3_bucket.s3_bucket_buffer module.s3_message_buffer.aws_s3_bucket.s3_bucket
terraform state mv module.s3.aws_s3_bucket.s3_bucket_storage module.s3_perm_storage.aws_s3_bucket.s3_bucket
terraform state mv module.s3.aws_secretsmanager_secret.s3_secret module.iam_user_artifactservice.aws_secretsmanager_secret.iam_secret
terraform state mv module.s3.aws_secretsmanager_secret_version.s3_access module.iam_user_artifactservice.aws_secretsmanager_secret_version.s3_access
terraform state mv module.s3.aws_s3_bucket_public_access_block.block_msg_buffer module.s3_message_buffer.aws_s3_bucket_public_access_block.block_public_access
terraform state mv module.s3.aws_s3_bucket_public_access_block.block_msg_storage module.s3_perm_storage.aws_s3_bucket_public_access_block.block_public_access




# remove output from module.s3
# touch ./tmp/providers.tf
provider "aws" {
  version = "2.7"
  region  = "eu-west-1"
}

provider "template" {
  version = "2.1"
}

# add to main.tf:
module "s3" {
  source = "./tmp"
}
# remove after next apply.



######################################
#reorg of terraform module madness:

```
terraform state list
    data.terraform_remote_state.k8s
    kubernetes_namespace.project
    module.k8s-azdo.data.terraform_remote_state.k8s
    module.k8s_admin_access.kubernetes_role_binding.namespaces["default"]
    module.k8s_admin_access.kubernetes_role_binding.namespaces["kube-system"]
    module.k8s_admin_access.kubernetes_role_binding.namespaces["nginx-external"]
    module.k8s_admin_access.kubernetes_role_binding.namespaces["nginx-internal"]
    module.k8s_view_access.kubernetes_role_binding.namespaces["default"]
    module.k8s_view_access.kubernetes_role_binding.namespaces["nginx-external"]
    module.k8s_view_access.kubernetes_role_binding.namespaces["nginx-internal"]
    module.k8s-azdo.module.k8s_environments.data.azuredevops_project.project
    module.k8s-azdo.module.k8s_environments.data.kubernetes_secret.token
    module.k8s-azdo.module.k8s_environments.azuredevops_resource_authorization.auth
    module.k8s-azdo.module.k8s_environments.azuredevops_serviceendpoint_kubernetes.service_account
    module.k8s-azdo.module.k8s_environments.kubernetes_cluster_role.main[0]
    module.k8s-azdo.module.k8s_environments.kubernetes_cluster_role_binding.main[0]
    module.k8s-azdo.module.k8s_environments.kubernetes_namespace.project["cert-manager"]
    module.k8s-azdo.module.k8s_environments.kubernetes_namespace.project["nginx-external"]
    module.k8s-azdo.module.k8s_environments.kubernetes_namespace.project["nginx-internal"]
    module.k8s-azdo.module.k8s_environments.kubernetes_role_binding.helm["cert-manager"]
    module.k8s-azdo.module.k8s_environments.kubernetes_role_binding.helm["nginx-external"]
    module.k8s-azdo.module.k8s_environments.kubernetes_role_binding.helm["nginx-internal"]
    module.k8s-azdo.module.k8s_environments.kubernetes_service_account.helm
# remove namespace from statefile and import at another destination

terraform state mv module.k8s-azdo.module.k8s_environments.kubernetes_cluster_role.main module.k8s_environments.kubernetes_cluster_role.main
terraform state mv module.k8s-azdo.module.k8s_environments.kubernetes_cluster_role_binding.main module.k8s_environments.kubernetes_cluster_role_binding.main
terraform state mv module.k8s-azdo.module.k8s_environments.data.azuredevops_project.project module.k8s_environments.data.azuredevops_project.project
terraform state mv module.k8s-azdo.module.k8s_environments.data.kubernetes_secret.token module.k8s_environments.data.kubernetes_secret.token
terraform state mv module.k8s-azdo.module.k8s_environments.azuredevops_resource_authorization.auth module.k8s_environments.azuredevops_resource_authorization.auth
terraform state mv module.k8s-azdo.module.k8s_environments.azuredevops_serviceendpoint_kubernetes.service_account module.k8s_environments.azuredevops_serviceendpoint_kubernetes.service_account
terraform state mv module.k8s-azdo.module.k8s_environments.kubernetes_namespace.project module.k8s_environments.kubernetes_namespace.project
terraform state mv module.k8s-azdo.module.k8s_environments.kubernetes_service_account.helm module.k8s_environments.kubernetes_service_account.helm
terraform state mv module.k8s-azdo.module.k8s_environments.kubernetes_role_binding.helm module.k8s_environments.kubernetes_role_binding.helm

terraform import 'module.k8s_environments.kubernetes_namespace.project["csi-driver"]' csi-driver
terraform state rm kubernetes_namespace.project
terraform state rm module.k8s-azdo.data.terraform_remote_state.k8s

terraform state list
    data.terraform_remote_state.k8s
    module.k8s-azdo.data.terraform_remote_state.k8s
    module.k8s_admin_access.kubernetes_role_binding.namespaces["default"]
    module.k8s_admin_access.kubernetes_role_binding.namespaces["kube-system"]
    module.k8s_admin_access.kubernetes_role_binding.namespaces["nginx-external"]
    module.k8s_admin_access.kubernetes_role_binding.namespaces["nginx-internal"]
    module.k8s_environments.data.azuredevops_project.project
    module.k8s_environments.data.kubernetes_secret.token
    module.k8s_environments.azuredevops_resource_authorization.auth
    module.k8s_environments.azuredevops_serviceendpoint_kubernetes.service_account
    module.k8s_environments.kubernetes_cluster_role.main[0]
    module.k8s_environments.kubernetes_cluster_role_binding.main[0]
    module.k8s_environments.kubernetes_namespace.project["cert-manager"]
    module.k8s_environments.kubernetes_namespace.project["csi-driver"]
    module.k8s_environments.kubernetes_namespace.project["nginx-external"]
    module.k8s_environments.kubernetes_namespace.project["nginx-internal"]
    module.k8s_environments.kubernetes_role_binding.helm["cert-manager"]
    module.k8s_environments.kubernetes_role_binding.helm["nginx-external"]
    module.k8s_environments.kubernetes_role_binding.helm["nginx-internal"]
    module.k8s_environments.kubernetes_service_account.helm
    module.k8s_view_access.kubernetes_role_binding.namespaces["default"]
    module.k8s_view_access.kubernetes_role_binding.namespaces["nginx-external"]
    module.k8s_view_access.kubernetes_role_binding.namespaces["nginx-internal"]


```

# Move resources from a master project to separate new projects
```
pwd
# ~/Infrastructure/Infra-DevOps/terraform/env-test/virtualmachines
# Create provider configuration and remote backend config in ./arch
terraform state pull > arch/terraform.tfstate
cd arch
terraform init #yes - import state from local
# now remove all of the stuff not managed by the arch project
terraform state rm module.test
terraform state rm module.pgw module.pgw.module.vm_i module.pgw.module.vm_p
terraform state rm module.dot module.dot.module.dot_1
terraform state rm 'module.coinroutes' 'module.coinroutes.module.ays' 'module.coinroutes.module.rsg' 'module.coinroutes.module.subnet'
# apparently the single quotes are important!
terraform state rm 'module.coinroutes.module.server[0]'
terraform state rm 'module.cusa' 'module.cusa.module.vm_i' 'module.cusa.module.vm_p'
terraform state rm 'module.core' 'module.core.module.vm_i' 'module.core.module.vm_p' 'module.core.module.rsg'

# and move the arch stuff to their new location (not wrapped in a module):
terraform state mv 'module.arch.data.azurerm_route_table.main' 'data.azurerm_route_table.main'
terraform state mv 'module.arch.data.azurerm_virtual_network.vnet' 'data.azurerm_virtual_network.vnet'
terraform state mv 'module.arch.azurerm_role_assignment.main' 'azurerm_role_assignment.main'
terraform state mv 'module.arch.module.rsg' 'module.rsg'
terraform state mv 'module.arch.module.vm_i' 'module.vm_i'

cd ..
terraform state rm 'module.arch' 'module.arch.module.vm_i' 'module.arch.module.rsg'

# comment out the code defining the arch project resources in the original project.

``` 

# then move test
```
pwd
# ~/Infrastructure/Infra-DevOps/terraform/env-test/virtualmachines
# Create provider configuration and remote backend config in ./test
terraform state pull > test/terraform.tfstate
cd test
terraform init #yes - import state from local
# now remove all of the stuff not managed by the arch project
# apparently the single quotes are important!

terraform state rm 'module.pgw' 'module.pgw.module.vm_i' 'module.pgw.module.vm_p'
terraform state rm 'module.cusa' 'module.cusa.module.vm_i' 'module.cusa.module.vm_p'
terraform state rm 'module.dot' 'module.dot.module.dot_1'
terraform state rm 'module.coinroutes' 'module.coinroutes.module.ays' 'module.coinroutes.module.rsg' 'module.coinroutes.module.subnet'
terraform state rm 'module.coinroutes.module.server[0]'
terraform state rm 'module.core' 'module.core.module.vm_i' 'module.core.module.vm_p' 'module.core.module.rsg'

terraform state list
# and move the arch stuff to their new location (not wrapped in a module):
terraform state mv 'module.test.data.terraform_remote_state.applications' 'data.terraform_remote_state.applications'
terraform state mv 'module.test.azurerm_resource_group.main' 'azurerm_resource_group.main'
terraform init
terraform plan -var-file=../shared.tfvars

cd ..
terraform state rm 'module.test.data.terraform_remote_state.applications' 'module.test.azurerm_resource_group.main'

# comment out the code defining the arch project resources in the original project.

``` 

```bash
terraform init
terraform state pull > terraform.tfstate
ROOT_MODULES=($(cat terraform.tfstate | jq '.resources[] | select(.module|test("module\\..*\\.module")|not) | .module' | jq -rs '. | unique[]'))
for MODULE in ${ROOT_MODULES[@]}; do
  echo "The module name is ${MODULE}"
  DIR=$(echo $MODULE | sed 's/module\.//')
#  OBJECTS=($(terraform state list -state=terraform.tfstate | grep ^$MODULE | sed 's/\[.*\]//'))
  OBJECTS=($(terraform state list -state=terraform.tfstate | grep ^$MODULE))
  for OBJ in ${OBJECTS[@]}; do
    RES=$(echo $OBJ | sed "s/^${MODULE}\.//")
    echo "$RES iteration"
    terraform state mv -state=terraform.tfstate -state-out=$DIR/terraform.tfstate "$OBJ" "$RES"
    (cd $DIR && terraform state show $RES)
  done
# terraform state rm ${OBJECTS[@]}
done

# After the config has been updated etc. run terraform init in all of the subdirectories.
# Will ask you to approve that you want to copy the local terraform state to the remote state if configured.
# need to remove all of the resources from the 

```