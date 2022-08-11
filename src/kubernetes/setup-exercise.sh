#!/bin/bash
# 演習4.4で使う環境をセットアップするスクリプト

set -eu -o pipefail

BASE64_DECODE_FLAG="-D"

# ここにユーザーを定義
users=(mrtc0)

for user in ${users[@]}; do
  kubens ${user}

  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: mysql
  namespace: ${user}
spec:
  ports:
  - port: 3306
  selector:
    app: mysql 
  clusterIP: None

---
kind: Deployment
apiVersion: apps/v1
metadata:
  name: vuln-mysql
  namespace: ${user}
spec:
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - image: mysql:8.0.30
        name: mysql
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-credential
              key: MYSQL_PASSWORD
        ports:
        - containerPort: 3306
          name: mysql
---
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: camp-runner
  namespace: ${user}
automountServiceAccountToken: false

---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: camp-runner
  namespace: ${user}
rules:
  - apiGroups: ["batch", "extensions"]
    resources: ["jobs", "job/status"]
    verbs: ["*"]
  - apiGroups: [""]
    resources: ["pods", "pods/binding", "pods/log", "pods/status"]
    verbs: ["get", "list", "create", "patch"]

---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: camp-runner
  namespace: ${user}
subjects:
- kind: ServiceAccount
  name: camp-runner
  namespace: ${user}
roleRef:
  kind: Role
  name: camp-runner
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: v1
data:
  MYSQL_PASSWORD: c29yb3Nvcm90c3VrYXJldGE/
kind: Secret
metadata:
  name: mysql-credential
  namespace: ${user}
---
kind: Deployment
apiVersion: apps/v1
metadata:
  name: vuln-api
  namespace: ${user}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      serviceAccountName: camp-runner
      automountServiceAccountToken: true
      containers:
        - name: api
          image: alpine
          command: ["tail", "-f", "/dev/null"]
          env:
          - name: mysql-credential
            valueFrom:
              secretKeyRef:
                name: mysql-credential
                key: MYSQL_PASSWORD
---
kind: Deployment
apiVersion: apps/v1
metadata:
  name: vuln-front
  namespace: ${user}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      serviceAccountName: camp-runner
      automountServiceAccountToken: true
      containers:
        - name: front
          image: bitnami/kubectl:1.24.3
          command: ["tail", "-f", "/dev/null"]

EOF

done

