curl https://raw.githubusercontent.com/minio/docs/master/source/extra/examples/minio-dev.yaml -O

kubectl apply -f minio-dev.yaml
rm minio-dev.yaml
# kubectl port-forward pod/minio 9000 9090 -n minio-dev
# minioadmin | minioadmin
# https://min.io/docs/minio/kubernetes/upstream/index.html