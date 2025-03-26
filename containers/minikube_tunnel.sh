#############################################################################################
# Author                Date            Version         Change
# Anurag Shrivastava    03/26/2025      1.0             Only required for creating network tunnel to access minikube
#                                                       for accessing the pods through the Nodeport services. 
#                                                       Run one at at time in foreground (remove &) to get the URLs.
#############################################################################################

# APIs
minikube service ev-get-app-service-nodeport --url &
minikube service ev-cud-app-service-nodeport --url &

# Postgres
kubectl port-forward --namespace default svc/postgres-postgresql 5432:5432
