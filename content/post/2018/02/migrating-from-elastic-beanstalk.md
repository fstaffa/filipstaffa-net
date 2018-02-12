---
title: "Migrating From Elastic Beanstalk"
date: 2018-02-12T18:59:30+01:00
tags: ['devops', 'aws', 'ecs']
---

Our team started deploying to AWS two years ago. After getting more experience with it we have decided to reevaluate our options and decrease costs.

# Previous state and requirements

We were deploying Node.js microservices to Elastic Beanstalk with one node process per machine and Nginx as a reverse proxy. Each service is deployed on several instances behind an AWS classic load balancer and has simple autoscaling rules.

We have over 30 microservices and need to be able to quickly and easily create and deploy new services. We don't have dedicated support or infrastructure team and we handle both ourselves.

Based on our previous experience with Elastic Beanstalk we came up with following requirements:

* continuous delivery and zero downtime deployment
* lower infrastructure costs
* easy deployment of new version of services
* easy creation of new service
* disaster recovery - in case any part of infrastructure breaks down
* low maintenance overhead
* autoscaling
* monitoring
* logging

# Options

After setting requirements we discussed options for deployment and decided to create a POC for first three.

## Docker Swarm

[Docker Swarm](https://docs.docker.com/engine/swarm/) is similar to Docker compose but spreads across several machines. Main concepts in Docker Swarm are:

* task - Docker container with commands to run inside
* service - definition of tasks to run in Docker Swarm (e.g. how many)
* worker node - runs tasks
* manager node - orchestrates which tasks should run on which worker nodes. There can be multiple master nodes which share the cluster state and decide by majority. They can also act as nodes.

Docker Swarm is natively supported by Docker so one of the benefits is that it requires less applications for basic operations. Using CloudFormation templates on Docker website, we were able to get basic system running very fast. It also supports load balancing, internal DNS and secure communication between containers in overlay network.

While a lot of the features we were interested worked out of the box, there were many open questions about how to integrate this with AWS and how reliable it would be compared to AWS alternatives.

Similar case was monitoring and autoscaling. Docker Swarm does not provide them and needs a separate service (like [Prometheus](https://prometheus.io/)) which again increases complexity of the solution.

Both of those are solvable but we didn't manage to do it during POC.

## Elastic Container Service

ECS is like lightweight Kubernetes. It is managed by Amazon and allows deployment and running of containers. There are three main concepts in ECS:

* cluster - EC2 instances on which Docker containers are run
* task - defines which containers should run together to provide functionality (in our case Nginx proxy and an application) and their configuration
* service - specifies how tasks should be run on the cluster (count, how they should be spread across cluster, integration with load balancers, etc.)

When a new task should be started (either as a part of service or because it was scheduled ad hoc) ECS scheduler identifies which machines in cluster could run it and starts it there. Scheduler also stops or starts new tasks if the service definition requires it.

ECS is very well integrated with rest of AWS and uses load balancers, publishes CloudWatch metrics and can easily scale based on them. Compared to Docker Swarm, the "master node" is managed by Amazon and you need to handle only "slaves" (cluster).


## Elastic Beanstalk Multicontainer Docker Environments

Elastic Beanstalk (EB) is a PaaS solution which allows running an application (Node.js, Python, Java, ...) in managed environment. You provide application, select runtime and instance count. AWS creates a cluster of machines, deploys the application there and manages autoscaling, load balancing, restarts and deployment of newer versions.

For multi container deployment the underlaying runtime is ECS. To run application you need to define which containers should run there and the configuration is very similar to ECS task definition. The result is comparable to having a an ECS cluster with a single task (composed of all containers which would run on EB) and having the task run on each machine in cluster.

The obvious disadvantage is that all containers in the task are deployed on all machines in EB cluster. If you have six containers and you want to run some on three instances and some on five, there is not an easy way to do it. Because deployment unit is a task (with all containers inside) instead of a container, change in one container requires redeployment of all containers in task. Also if you need to be able to create and deploy new services, you would either need to increase size of machines in EB cluster (in which case you might have too many containers in one task and would have frequent redeployments of all containers) or create new EB cluster and deploy new services there (in which case you would need to consider when to split and deploy to a new cluster, and reevaluate grouping of containers on clusters if some container changes resource usage).


<!--  LocalWords:  EB
 -->
Advantage is that EB is more integrated. An example is updating machines to new image. In ECS you have to coordinate stopping old machines with stopping tasks running on them while Elastic Beanstalk does it automatically and supports rollbacks in case there is problem.

## Kubernetes

We decided not to try Kubernetes because it seemed to be too complex for our team. Installation and maintenance looked difficult but our biggest worry was support. In case anything went wrong with the cluster it could bring down all of our applications and people on support would have to know it enough to fix it.

## AWS Lambda

Our services need a reliable response time around 500 milliseconds and cold starts (even with various workarounds like preheating) don't support this.

## EKS and Fargate

Several days after we decided to use ECS there was AWS re:Invent conference and Amazon announced [EKS](https://aws.amazon.com/eks/) (managed Kubernetes service) and [Fargate](https://aws.amazon.com/fargate/) (managed ECS service). We looked into those very briefly but because they were very new and not officially available we decided to ignore them for now.

# Conclusion

All three options support most of our requirements. We decided not to use Docker Swarm because there were several unknowns. It also required a lot of manual work (monitoring, alerts) and had higher maintenance without any clear benefit over ECS or Elastic Beanstalk.

It was a close call between ECS and EB but we decided to use ECS. Main reason was that we didn't want to partition our services between EB clusters. We also didn't realize that we would need to manually replicate some functionality which we would get from EB for free. Even if we knew we would still choose ECS because it is more flexible but it is something to be aware of.

If we had smaller team and less services, we would have chosen Elastic Beanstalk. 
