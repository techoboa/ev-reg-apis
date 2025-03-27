# Project: ev-reg-apis: Creating APIs for EV Registration Data
Creating CRUD APIs to be able to for EV registration related operations.

# NFR Assumptions
- **Bulk load of data:** The provided recordset has ~250K records in total. It will take a lot of time to insert them one at a time in a normalized relational database. Bulk load should be ok.
- **Read v/s Create/Update/Delete operation counts:** In the DMV office, Read operation counts must be more than the total of Create/Update/Delete.
- **Realtime Telemetry:** Since these are operations are not too frequent, batch posting of telemetry every min to the telemetry tools should be fine instead of real time posting of data.

# Architecture
Solution can be run in etc.
Block diagram and explaination
Database design
Talk about design decisions

# Prerequisites
The solution can be run in both local laptop/VM or in Kubernetes/Minikube. I used minikube on my laptop to deploy due to cost contraints for 2 weeks on Kubernetes on any public cloud. Minikube is free and works 90% same as any public cloud hosted Kubernetes cluster.

In any scenario, you need the following minimally to run the program:
- Postgres database for relational data schemas
- Python 3.8+ for APIs
- OS and Python dependencies. I used Debian container to run this. Please modity to brew or yum based on the system being used.
  Install the following OS and Python dependencies before you can run the code. This should be done in the Container or local system/VM running the APIs. Please remove the ones from the list which are already installed. They are mentioned here: https://github.com/techoboa/ev-reg-apis/blob/main/install/install.sh
- psql for testing postgres connectivity or running commands. I used "brew install libpq" to install psql on Mac. It gets installed in /usr/local/opt/libpq/bin, in case it helps.
- PGADMIN: can be used as an alternative to psql

I ran Postgres in a container and also deployed APIs in containers. In that regards, you need:
- Kubernetes cluster/Minikube on laptop
- Container registry of your choice. Could be docker hub or a local running container registry (on VM or in Docker). I am considering setting up Kubernetes cluster to be able to push/pull images from the registry of your choice, to be out of requirement. Assuming thats setup already.
  Running docker container registry in docker:  https://www.paulsblog.dev/how-to-install-a-private-docker-container-registry-in-kubernetes/

# How to deploy

## Kubernetes/Minikube:

### Minikube

brew uninstall minikube

brew install minikube

minikube start


### Database
Deploy postgres in containers using the following procedure. Followed this tutorial: https://medium.com/@hijessicahsu/deploy-postgres-on-minikube-5cd8f9ffc9c

#### Creating Database

- Install helm and add bitnami helm repo for postgres

brew install helm

helm repo add bitnami https://charts.bitnami.com/bitnami

- Create Persistent volume and claim for the database using kubectl apply -f on the following two files in order:
  
https://github.com/techoboa/ev-reg-apis/blob/main/postgres/kubernetes/postgres_pv.yml

https://github.com/techoboa/ev-reg-apis/blob/main/postgres/kubernetes/postgres_pvc.yml

- Download chart, untar the tgz, find the values.yaml, take a look, and update it, if needed.

helm pull bitnami/postgresql

tar -xvf postgresql-16.5.3.tgz

helm install postgres bitnami/postgresql -f _Chart_Location_/postgresql/values.yaml

- Post Install Steps:

1. PostgreSQL can be accessed via port 5432 on the following DNS names from within your cluster:

    postgres-postgresql.default.svc.cluster.local - Read/Write connection

2. To get the password for "postgres" run:

    export POSTGRES_PASSWORD=$(kubectl get secret --namespace default postgres-postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)

3. Test a client connection

To connect to your database run the following command:

    kubectl run postgres-postgresql-client --rm --tty -i --restart='Never' --namespace default --image docker.io/bitnami/postgresql:17.4.0-debian-12-r9 --env="PGPASSWORD=$POSTGRES_PASSWORD" \
      --command -- psql --host postgres-postgresql -U postgres -d postgres -p 5432

    > NOTE: If you access the container using bash, make sure that you execute "/opt/bitnami/scripts/postgresql/entrypoint.sh /bin/bash" in order to avoid the error "psql: local user with ID 1001} does not exist"

4. To connect to your database from outside the cluster using pgadmin or psql, execute the following commands. This step is necessary specifically if working with Minikube. Its also added here: https://github.com/techoboa/ev-reg-apis/blob/main/containers/minikube_tunnel.sh . Alternately create a new NodePort Service and use Minikube tunneling as done in the API side (explained later)

    kubectl port-forward --namespace default svc/postgres-postgresql 5432:5432 &
    PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d postgres -p 5432


#### Bulk Data Load Process

### APIs
#### Deploying APIs

## On Laptop/VM:
If you have a local postgres database on laptop, import the SQL script in the repo. Please manually create a schema named "m" under defaukt database postgres. I forgot to add the code for schema creation in the sql script. And yes, I am guilty of naming it a random "m". But later I have done a good job of naming all other objects.

For API services, change the database details in the db.properties file and just run the two services file using:

- All get APIs: python3 ev_reg_read_apis.py
- All CUD APIs: python3 ev_reg_create_update_delete_apis.py

The log and telemetry files are created by default in /tmp. Its hardcoded.

## Database
### Creating Database
### Bulk Data Load Process

## APIs
### Deploying APIs
### How to test and use

# APIs created and arranged
# Database procedures

# Command Line Clients

# Test cases and results

# Updating Records for EV Model and Make (Tesla Model Y in this example)

# Tracking and Telemetery

# Improvements which can be done

# References

