K8S 
===
create the ekscluster in public subnet using the script eksexistingvpc.yaml
replace every value mark with xxx with your appropriate value

```
eksctl create cluster -f eksexistingvpc.yaml
```
Deploy k8s resources

 create the SA using sa.yml

 deploy the confimap configmap.yaml

 deploy the nginx application nginx-deployment.yaml

 test to see what privis that token is given
```
k auth can-i delete secrets --as system:serviceaccount:default:build-robot
```
#This will default to no
use this command to check where the serviceaccount is mounted after logging into the pod 
```
mount | grep serv
```
```
curl -X GET https://kubernetes:443/api/v1/namespaces/default/pods/ --header "Authorization: Bearer xxxxxxxxxxxe" --cacert /run/secrets/kubernetes.io/serviceaccount/ca.crt
```
#then apply the permissive access This gives all SA admin privis 
```
kubectl create clusterrolebinding permissive-binding \
  --clusterrole=cluster-admin \
  --user=admin \
  --user=kubelet \
  --group=system:serviceaccounts
```

#test this out by runining
```
k auth can-i delete secrets --as system:serviceaccount:default:build-robot
```
#deploy the confimap configmap.yaml
#log into the pod and get pod info using this command
```
curl -X GET https://kubernetes:443/api/v1/namespaces/default/pods/ --header "Authorization: Bearer xxxxxxxxxxxe" --cacert /run/secrets/kubernetes.io/serviceaccount/ca.crt
```

#deploy the loadbalancer loadbalancer.yaml


