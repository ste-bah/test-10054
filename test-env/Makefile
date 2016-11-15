# Makefile to kick of the terraform for this project
#
# You should set the following environment variable to authenticate 
# with AWS so you can store and retrieve the remote state befor you run this Makefile.
#
# export AWS_ACCESS_KEY_ID= <your key>
# export AWS_SECRET_ACCESS_KEY= <your secret>
# export AWS_DEFAULT_REGION= <your bucket region eg ap-southeast-2>
# export TF_VAR_access_key=$AWS_ACCESS_KEY # exposed as access_key in the terraform scripts
# export TF_VAR_secret_key=$AWS_SECRET_ACCESS_KEY
#
# ####################################################
#
STATEBUCKET = CHANGETHISTOYOURBUCKET
PREFIX = test
REGION = eu-west-1

# # Before we start test that we have the manditory executables avilable
 EXECUTABLES = git terraform
 K := $(foreach exec,$(EXECUTABLES),\
  $(if $(shell which $(exec)),some string,$(error "No $(exec) in PATH, consider apt-get install $(exec)")))
#
#     .PHONY: all s3bucket plan


.PHONY: all plan apply

all:	plan
	echo "All"

plan: 
	@echo "running terraform plan"
	rm -rf $(PREFIX)-environment.plan
	terraform remote config -backend=s3 -backend-config="region=$(REGION)" -backend-config="bucket=$(STATEBUCKET)" -backend-config="key=$(PREFIX)/terraform.tfstate"
	terraform plan -out $(PREFIX)-environment.plan -var-file="terraform.tfvars"

apply:
	@echo running terraform apply
	terraform apply $(PREFIX)-environment.plan

destroy:
	@echo running terraform destroy
	terraform destroy -var-file="terraform.tfvars" -var-file="terraform.tfvars"

# little hack target to prevent it running again without need
# for second nested Makefile
init.txt:
	@echo "initialise remote statefile"
	terraform --profile=end remote config -backend=s3 -backend-config="region=$(REGION)" -backend-config="bucket=$(STATEBUCKET)" -backend-config="key=$(PREFIX)/terraform.tfstate"
	echo "ran terraform remote config -backend=s3 -backend-config="region=$(REGION)" -backend-config=\"bucket=$(STATEBUCKET)\" -backend-config=\"key=$(PREFIX)/terraform.tfstate\"" > ./init.txt

