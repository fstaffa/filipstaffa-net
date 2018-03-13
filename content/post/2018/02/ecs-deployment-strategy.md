---
title: "ECS Basic Setup"
date: 2018-03-13T20:36:39+01:00
tags: ['devops', 'aws', 'ecs']
---

# Without CloudFormation

When we started investigating ECS I started by reading basic AWS documentation and following several tutorials. Unfortunately I was following tutorials which used AWS console instead of CloudFormation.
It was mainly because I didn't have enough experience with CloudFormation and clicking in the AWS console seemed easier. 

Problem with not using CloudFormation was that I had to remember/make note of everything I did so I could repeat it. Several times I didn't remember the steps correctly and had to spend several hours trying to reproduce it. Another aspect is cleanup - it is very easy to forget what resources were created during manual POC and leave them unused in the AWS account.

Even worse is that if I had finished the POC without CloudFormation, I would still need to rewrite it to CloudFormation to deploy it to our production environment.

After several days I started really feeling that not being able to quickly recreate environment is a problem and I switched to CloudFormation.

## CloudFormation vs Terraform

Terraform is developed by HashiCorp and has similar usages as CloudFormation. It is platform agnostic (can be used with Azure or Google Cloud as well) and has some nice features (e.g. defining and using local variables inside template).

Problem is that it acts as layer of abstraction over CloudFormation.

Most articles about ECS are using CloudFormation so if you use Terraform, you need to translate them. While most features ECS related options are can be easily translated from CloudFormation (and AWS documentation) to Terraform there are some small differences which can make it harder to use.

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

When nested template contains parameters you can set it in parent template (line 14). If the nested template has any outputs (defined similarly to what is on line 16) you can reference them (example on line 14 ad 18).

## ECS reference architecture structure

The reference architecture is used running services on ECS (not standalone tasks) behind load balancer. Here are the key concepts used:

### Security groups

There are two important security groups for ECS deployment. First is load balancer security group which defines who can connect to the load balancer.

Second security group is applied to EC2 instances. This security group should have at least inbound access from load balancer. Without this the application won't be reachable from load balancer and would fail health checks. If everything seems to be fine but application keeps restarting, this is often the problem. For basic debugging it is useful to also enable ssh access to EC2 instances.

### Roles

There are two main IAM roles for ECS deployment. 

[ECS container instance role](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/instance_IAM_role.html) is applied to EC2 machines serving as container hosts. It contains permissions necessary to authorize with the ECS cluster, register itself as container instance and download images from ECR (Elastic Container Registry, is an Amazon hosted Docker registry).

This role is also inherited by all tasks run on the instance. If you need additional permissions for your tasks (e.g. S3 access) you can create [IAM roles for tasks](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-iam-roles.html) and assign them to tasks based on what they need. The alternative (easier, but less save) is to add additional permissions to the ECS container instance role.

[ECS service scheduler role](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service_IAM_role.html) role is used with application load balancer. The ECS service needs to be able to register and deregister containers to it and this role contains necessary rights to do it.

### Load balancer

ECS services can be used with both classic and application load balancer. There is a nice [article](https://www.sumologic.com/aws/elb/aws-elastic-load-balancers-classic-vs-application/) comparing their benefits. Most of the time application load balancer is a better choice.

It works on the layer 7 (application) of OSI model and can route traffic to different applications based on path or host. In the example this is used to use one load balancer for two different applications and routes based on path.

The biggest advantage is that it allows containers to use dynamic port mapping. This means that you don't have to specify how should application container port map to the host port. If you have many applications you don't have to keep track which application uses which port to make sure they don't clash when deployed on the same host. It also allows deploying the same application multiple times on the same host.


### Cluster

Easiest way to the ECS cluster is using Auto Scaling group. In the reference architecture example it creates several EC2 machines based on ECS optimized AMI (Amazon Machine Image). This AMI has ECS agent and it's prerequisites (e.g. Docker) preinstalled.

As a part of the machine setup, it defines the to which cluster it should connect and sets up logging to CloudWatch logs.

The machine uses ECS container instance role and has security group which allows inbound traffic from load balancer.

# Conclusion

ECS can be complicated because there are several concepts which need to be understood. ECS reference architecture from AWS is a good starting point because it shows most of them and how they relate to each other. It also shows it using CloudFormation template so it helps starting with your own cluster the right way.

# Resources

* ECS reference architecture - https://github.com/awslabs/ecs-refarch-cloudformation
* ECS container instance role - https://docs.aws.amazon.com/AmazonECS/latest/developerguide/instance_IAM_role.html
* ECS service scheduler role - https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service_IAM_role.html
* Application and classic load balancer comparison - https://www.sumologic.com/aws/elb/aws-elastic-load-balancers-classic-vs-application/
