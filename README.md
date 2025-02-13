# Scope

The idea is to test AWS EC2 instance assuming IAM roles to access S3 buckets.

## Description

This is the content:
- We create a S3 bucket and put a random file in it.
- We create a role to be assumed by the EC2 instance. This role is going to have a policy that indicates what it can do with the S3 bucket (List, Read, Write...).
- We create a EC2 instance (profile, gateway, router, vpc, subnet, security_group)

## SSH Key pair

To access remotely the EC2 instance, you are going to need the password. In order to get it, AWS console is going to ask you for your private ssh key (the one matching the public key used to run terraform), to make sure it's you who spinned up the instance.

To generate a SSH key pair, just type this into your console:

```cmd
ssh-keygen -t rsa -b 2048 -m PEM -f ./my-ec2-key
```

> NOTE: Add a passphrase if you want or just hit enter all the way throu.

This will create two files:

 - my-ec2-key (private key)
 - my-ec2-key.pub (public key)

Store the private key (my-ec2-key) in a secure location, like C:\Users\YourUsername\.ssh\. Never share this file.

## Service account / principal

In order to run all this code, you need to have a user with the proper credentials. 

Create an IAM user with these inline policies:

- S3 bucket policy

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:ListBucket",
                "s3:CreateBucket",
                "s3:Delete*",
                "s3:PutObject"
            ],
            "Resource": "*"
        }
    ]
}
```

- EC2 instance policy

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Statement1",
            "Effect": "Allow",
            "Action": [
                "ec2:Create*",
                "ec2:Describe*",
                "ec2:Delete*",
                "ec2:Modify*",
                "ec2:Associate*",
                "ec2:Revoke*",
                "ec2:Authorize*",
                "ec2:AttachInternetGateway",
                "ec2:RunInstances",
                "ec2:DisassociateRouteTable",
                "ec2:TerminateInstances",
                "ec2:DetachInternetGateway",
                "ec2:ImportKeyPair"
            ],
            "Resource": "*"
        }
    ]
}
```

- IAM policy

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "iampolicy",
            "Effect": "Allow",
            "Action": [
                "iam:CreateRole",
                "iam:GetRole*",
                "iam:GetListRolePolicies",
                "iam:List*",
                "iam:Delete*",
                "iam:PutRolePolicy",
                "iam:CreateInstanceProfile",
                "iam:GetInstanceProfile",
                "iam:AddRoleToInstanceProfile",
                "iam:PassRole",
                "iam:Remove*"
            ],
            "Resource": "*"
        }
    ]
}
```

## Execution

```Terraform
terraform init
terraform plan
terraform apply --auto-appove
```

## Testing

Access the EC2 instance with the username(Administrator)/password and install the AWS CLI. Then run these commands:

:white_check_mark: Success

```cmd
# Test S3 access
aws s3 ls s3://your-bucket-name  # Use the bucket_name from terraform output
aws s3 cp s3://your-bucket-name/test.txt test.txt
```

:x: Access denied

Remove some actions from the IAM Policy

```cmd
{
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [          
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.test_bucket.arn,
          "${aws_s3_bucket.test_bucket.arn}/*"
        ]
      }
    ]
  }
```

Execute again the same two commands and see what happens.