eksctl create cluster -f adot-amp-amg-on-fargate/cluster.yaml

aws eks create-fargate-profile \
    --fargate-profile-name coredns \
    --cluster-name adot-on-fargate \
    --pod-execution-role-arn arn:aws:iam::<Account_Id>:role/eksctl-adot-on-fargate-clus-FargatePodExecutionRole-7tCPf1HyPq1L \
    --selectors namespace=kube-system,labels={k8s-app=kube-dns}

kubectl patch deployment coredns \
    -n kube-system \
    --type json \
    -p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]'

kubectl rollout restart -n kube-system deployment coredns

CLUSTER_NAME=YOUR-EKS-CLUSTER-NAME
REGION=YOUR-EKS-CLUSTER-REGION
SERVICE_ACCOUNT_NAMESPACE=fargate-container-insights
SERVICE_ACCOUNT_NAME=adot-collector
SERVICE_ACCOUNT_IAM_ROLE=EKS-Fargate-ADOT-ServiceAccount-Role
SERVICE_ACCOUNT_IAM_POLICY=arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy

eksctl utils associate-iam-oidc-provider \
--cluster=$CLUSTER_NAME \
--approve

eksctl create iamserviceaccount \
--cluster=$CLUSTER_NAME \
--region=$REGION \
--name=$SERVICE_ACCOUNT_NAME \
--namespace=$SERVICE_ACCOUNT_NAMESPACE \
--role-name=$SERVICE_ACCOUNT_IAM_ROLE \
--attach-policy-arn=$SERVICE_ACCOUNT_IAM_POLICY \
--approve

kubectl create namespace golang