kubectl apply -f source-ip-deploy.yaml
kubectl apply -f source-ip-svc.yaml

kubectl apply -f namespace.yaml

kubectl apply -f default-backend.yaml


kubectl apply -f configmap.yaml
kubectl apply -f nginx-controller.yaml

kubectl apply -f ingress.yaml
