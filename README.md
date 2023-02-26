## create dev.tfvars
```tf
region         = "ap-northeast-1"
aws_access_key = "xxx"
aws_secret_key = "xxx"
```

## terraform plan
```bash
terraform plan -var-file ./vars/dev.tfvars
```

## terraform apply
```bash
terraform plan -var-file ./vars/dev.tfvars
```