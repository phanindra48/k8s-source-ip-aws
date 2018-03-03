# k8s-source-ip-aws
Minimalistic kubernetes cluster to get source ip in aws cloud provider

kops `Version 1.7.1`

kubernetes 
```
Client Version: version.Info{Major:"1", Minor:"8", GitVersion:"v1.8.3", GitCommit:"f0efb3cb883751c5ffdbe6d515f3cb4fbe7b7acd", GitTreeState:"clean", BuildDate:"2017-11-09T07:26:38Z", GoVersion:"go1.9.2", Compiler:"gc", Platform:"darwin/amd64"}
Server Version: version.Info{Major:"1", Minor:"7", GitVersion:"v1.7.11", GitCommit:"b13f2fd682d56eab7a6a2b5a1cab1a3d2c8bdd55", GitTreeState:"clean", BuildDate:"2017-11-25T17:51:39Z", GoVersion:"go1.8.3", Compiler:"gc", Platform:"linux/amd64"}
```

Please follow instructions given [here](https://github.com/kubernetes/kops/blob/master/docs/aws.md)

1. Install `kops`
2. Install `kubectl`
3. Setup AWS - You can either setup aws environment manually by following the instruction given in the docs or you can leave that to kops (I preferred `kops` taking care of that stuff)
4. Configure [DNS](https://github.com/kubernetes/kops/blob/master/docs/aws.md#configure-dns)
5. Testing your DNS setup
```
dig ns subdomain.example.com
```

## PROCEED only after completing all above steps

## Create cluster state storage
```
aws s3api create-bucket --bucket your-domain-com-state-store --region us-east-1
```
## Create cluster
```
export AWS_ACCESS_KEY_ID=<access-key>
export AWS_SECRET_ACCESS_KEY=<secret-key>

export KUBERNETES_PROVIDER=aws;

export KOPS_STATE_STORE=s3://your-domain-com-state-store
export NAME=your.domain.com

export MASTER_SIZE=t2.micro;
export NODE_SIZE=t2.micro;
export NUM_NODES=2;
export NODE_ZONES=eu-central-1a,eu-central-1b;
export MASTER_ZONES=eu-central-1a;

export AWS_S3_REGION=eu-central-1;

kops create cluster \
   --cloud=$KUBERNETES_PROVIDER \
   --zones=$NODE_ZONES \
   --master-zones=$MASTER_ZONES \
   --node-count=$NUM_NODES \
   --node-size=$NODE_SIZE \
   --master-size=$MASTER_SIZE \
   --associate-public-ip=true \
   --name=$NAME \
   --yes

kops update cluster ${NAME} --yes

kops rolling-update cluster
```

## Create dashboard
```
kubectl create -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/kubernetes-dashboard/v1.5.0.yaml
```

## Create namespace

```
kubectl apply -f namespace.yaml
```

## Create default backend

```
kubectl apply -f default-backend.yaml
```

## create nginx-ingress

```
kubectl apply -f configmap.yaml
kubectl apply -f nginx-controller.yaml
```
Map your External IP that you have got from below command to some domain name.
```
kubectl get svc --namespace=nginx-ingress nginx-ingress
```
External IP from aws will be a DNS name. Create a CNAME record set in route53 under the hosted zone (in this case `your.domain.com`) and copy this DNS name in `value` field and save the record set.
eg: `something.your.domain.com`


## Create source ip app
```
kubectl apply -f source-ip-deploy.yaml
kubectl apply -f source-ip-svc.yaml

```
## Create ingress
Replace `host` in rules section of `ingress.yaml` with your domain that you mapped earlier

```
kubectl apply -f ingress.yaml
```

For more information checkout kubernetes [page](https://kubernetes.io/docs/tutorials/services/source-ip/)

Annotate nginx-ingress service of type=LoadBalancer using below command
```
kubectl annotate service --namespace=nginx-ingress nginx-ingress service.beta.kubernetes.io/aws-load-balancer-proxy-protocol: '*'
```

## Test for source ip
 ```
 curl http://something.your.domain.com/test
 ```
 check for `x-real-ip` field in the response (its a private ip)


## Clean up
```
kops delete cluster $NAME --yes
```
