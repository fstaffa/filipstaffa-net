---
title: "Ecs Deployment Strategy"
date: 2018-02-13T21:36:39+01:00
draft: true
tags: ['devops', 'aws', 'ecs']
---

# Without CloudFormation

When we started investigating ECS I started by reading basic AWS documentation and following several tutorial. Unfortunately I was following tutorials which used AWS console instead of CloudFormation.
It was mainly because I didn't have enough experience with CloudFormation and clicking in AWS console seemed easier. 

Problem with not using CloudFormation was that I had to remember/make note of everything I did so I could repeat it. Several times I didn't remember the steps correctly and had to spend several hours trying to reproduce it. Another aspect is cleanup - it is very easy to forget what resources were created during manual POC and leave them unused in the AWS account.

Even worse is that if I had finished the POC without CloudFormation, I would still need to rewrite it to CloudFormation to deploy it to our production environment.

After several days I started really feeling that not being able to quickly recreate environment is a problem and I switched to CloudFormation.

# ECS with CloudFormation

I didn't know how to start with CloudFormation but a colleague pointed me to [ECS reference architecture](https://github.com/awslabs/ecs-refarch-cloudformation). This is a repository showing example of deployment to ECS using CloudFormation developed by AWS labs. The template creates networking infrastructure, ECS cluster on an autoscaling group, load balancer and deploys two applications.

The template is very good to get understanding of basic ECS parts and how to organize the CloudFormation templates.

## Nested CloudFormation templates

When you deploy a CloudFormation stack to AWS it is defined by a single (root) template. For any non trivial project it is better to split it into several nested templates and call them from the root template. This works pretty much the same as functions in programming languages.

Nested templates allow code reuse (when you want to repeat a part of infrastructure multiple times) and allow scoping of template resources. For bigger templates it can get confusing to understand where various resources are used (and even if they are used at all).

When using a nested template, the parent has to specify it as a resource, point to it's location (S3) and set required parameters. Here is an simple example of usage:

```yml
Description: Creates security group and a load balancer

Resources:
  SecurityGroups:
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: https://s3.amazonaws.com/my-bucket/security-groups.yaml

  ALB:
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: https://s3.amazonaws.com/my-bucket/load-balancer.yaml
      Parameters:
        SecurityGroup: !GetAtt SecurityGroups.Outputs.LoadBalancerSecurityGroup
        
Outputs:
  LoadBalancerSecurityGroup:
    Value: !GetAtt SecurityGroups.Outputs.LoadBalancerSecurityGroup
```

This template is composed of two nested templates (SecurityGroups and ALB). For nested template you need to define the correct type and (lines 5 and 10) at least TemplateURL (line 7 and 12). 

When nested template contains parameters you can set it in parent template (line 14). When nested template has any outputs (defined similarly to what is on line 16) you can reference them (example on line 14 ad 18).

## ECS reference architecture structure






# CloudFormation vs Terraform

# Deployment

# Resources

* ECS reference architecture - https://github.com/awslabs/ecs-refarch-cloudformation


