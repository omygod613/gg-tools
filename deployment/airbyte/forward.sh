# Push commands in the background, when the script exits, the commands will exit too
kubectl port-forward svc/isliao-airbyte-airbyte-webapp-svc 80:80 & \
kubectl port-forward svc/service2 80:80 & \

echo "Press CTRL-C to stop port forwarding and exit the script"
wait
