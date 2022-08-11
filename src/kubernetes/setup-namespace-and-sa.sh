#!/bin/bash
# 受講生ごとに Namespace と ServiceAccount を発行し、
# その ServiceAccount でクラスタに接続できる kubeconfig を生成するスクリプト

set -eu -o pipefail

# source /etc/os-release
# 
# # Set OS specific values.
# if [[ "$OSTYPE" == "linux-gnu" ]]; then
#     BASE64_DECODE_FLAG="-d"
# elif [[ "$OSTYPE" == "darwin"* ]]; then
#     BASE64_DECODE_FLAG="-D"
# elif [[ "$OSTYPE" == "linux-musl" ]]; then
#     BASE64_DECODE_FLAG="-d"
# else
#     echo "Unknown OS ${OSTYPE}"
#     exit 1
# fi
BASE64_DECODE_FLAG="-D"

# ここにユーザー名を定義する
users=(mrtc0)

CURRENT_CONTEXT=$(kubectl config current-context)
CURRENT_CLUSTER=$(kubectl config view -o jsonpath="{.contexts[?(@.name == \"${CURRENT_CONTEXT}\"})].context.cluster}")
CURRENT_CLUSTER_ADDR=$(kubectl config view -o jsonpath="{.clusters[?(@.name == \"${CURRENT_CLUSTER}\"})].cluster.server}")

mkdir -p kube

for user in ${users[@]}; do
  kubectl create ns ${user}

  cat <<EOF | kubectl apply -f -
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: camper
  namespace: ${user}
rules:
- apiGroups:
  - ""
  resources:
  - pods/attach
  - pods/exec
  - pods/portforward
  - pods/proxy
  - secrets
  - services/proxy
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - ""
  resources:
  - serviceaccounts
  verbs:
  - impersonate
- apiGroups:
  - ""
  resources:
  - pods
  - pods/attach
  - pods/exec
  - pods/portforward
  - pods/proxy
  verbs:
  - create
  - delete
  - deletecollection
  - patch
  - update
- apiGroups:
  - ""
  resources:
  - configmaps
  - events
  - persistentvolumeclaims
  - replicationcontrollers
  - replicationcontrollers/scale
  - secrets
  - serviceaccounts
  - services
  - services/proxy
  verbs:
  - create
  - delete
  - deletecollection
  - patch
  - update
- apiGroups:
  - apps
  resources:
  - daemonsets
  - deployments
  - deployments/rollback
  - deployments/scale
  - replicasets
  - replicasets/scale
  - statefulsets
  - statefulsets/scale
  verbs:
  - create
  - delete
  - deletecollection
  - patch
  - update
- apiGroups:
  - autoscaling
  resources:
  - horizontalpodautoscalers
  verbs:
  - create
  - delete
  - deletecollection
  - patch
  - update
- apiGroups:
  - batch
  resources:
  - cronjobs
  - jobs
  verbs:
  - create
  - delete
  - deletecollection
  - patch
  - update
- apiGroups:
  - extensions
  resources:
  - daemonsets
  - deployments
  - deployments/rollback
  - deployments/scale
  - ingresses
  - networkpolicies
  - replicasets
  - replicasets/scale
  - replicationcontrollers/scale
  verbs:
  - create
  - delete
  - deletecollection
  - patch
  - update
- apiGroups:
  - policy
  resources:
  - poddisruptionbudgets
  verbs:
  - create
  - delete
  - deletecollection
  - patch
  - update
- apiGroups:
  - networking.k8s.io
  resources:
  - ingresses
  - networkpolicies
  verbs:
  - create
  - delete
  - deletecollection
  - patch
  - update
- apiGroups:
  - ""
  resources:
  - configmaps
  - endpoints
  - persistentvolumeclaims
  - persistentvolumeclaims/status
  - pods
  - replicationcontrollers
  - replicationcontrollers/scale
  - serviceaccounts
  - services
  - services/status
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - ""
  resources:
  - bindings
  - events
  - limitranges
  - namespaces/status
  - pods/log
  - pods/status
  - replicationcontrollers/status
  - resourcequotas
  - resourcequotas/status
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - discovery.k8s.io
  resources:
  - endpointslices
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - apps
  resources:
  - controllerrevisions
  - daemonsets
  - daemonsets/status
  - deployments
  - deployments/scale
  - deployments/status
  - replicasets
  - replicasets/scale
  - replicasets/status
  - statefulsets
  - statefulsets/scale
  - statefulsets/status
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - autoscaling
  resources:
  - horizontalpodautoscalers
  - horizontalpodautoscalers/status
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - batch
  resources:
  - cronjobs
  - cronjobs/status
  - jobs
  - jobs/status
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - extensions
  resources:
  - daemonsets
  - daemonsets/status
  - deployments
  - deployments/scale
  - deployments/status
  - ingresses
  - ingresses/status
  - networkpolicies
  - replicasets
  - replicasets/scale
  - replicasets/status
  - replicationcontrollers/scale
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - policy
  resources:
  - poddisruptionbudgets
  - poddisruptionbudgets/status
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - networking.k8s.io
  resources:
  - ingresses
  - ingresses/status
  - networkpolicies
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - rbac.authorization.k8s.io
  resources:
  - roles
  - rolebindings
  verbs:
  - get
  - list
  - patch
  - create
  - delete
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: camper
  namespace: ${user}
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: camper
  namespace: ${user}
subjects:
- kind: ServiceAccount
  name: camper
  namespace: ${user}
roleRef:
  kind: Role
  name: camper
  apiGroup: rbac.authorization.k8s.io
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: istio-edit
  namespace: ${user}
rules:
- apiGroups: ["", "extensions", "apps", "networking.k8s.io", "networking.istio.io", "authentication.istio.io",
              "rbac.istio.io", "config.istio.io", "security.istio.io"]
  resources: ["*"]
  verbs: ["*"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: istio-edit
  namespace: ${user}
subjects:
- kind: ServiceAccount
  name: camper
  namespace: ${user}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: istio-edit
EOF

  kubens ${user}
  SECRET_NAME=$(kubectl get sa camper -o json | jq -r '.secrets[].name')
  SA_TOKEN=$(kubectl get secrets ${SECRET_NAME} -o json | jq -r .data.token | base64 ${BASE64_DECODE_FLAG})
  CA_CERT=$(kubectl get secrets ${SECRET_NAME} -o json | jq -r '.data["ca.crt"]')
  
  cat > kube/kubeconfig.${user} <<EOF
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${CA_CERT}
    server: ${CURRENT_CLUSTER_ADDR}
  name: ${CURRENT_CLUSTER}
contexts:
- context:
    cluster: ${CURRENT_CLUSTER}
    user: ${CURRENT_CLUSTER}-camper
    namespace: ${user}
  name: ${CURRENT_CONTEXT}
current-context: ${CURRENT_CONTEXT}
kind: Config
preferences: {}
users:
- name: ${CURRENT_CLUSTER}-camper
  user:
    token: ${SA_TOKEN}
EOF

done

