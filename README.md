# Project: ev-reg-apis: Creating APIs for EV Registration Data
Creating CRUD APIs to be able to for EV registration related operations.

# NFR Assumptions
- **Bulk load of data:** The provided recordset has ~250K records in total. It will take a lot of time to insert them one at a time in a normalized relational database. Bulk load should be ok.
- **Read v/s Create/Update/Delete operation counts:** In the DMV office, Read operation counts must be more than the total of Create/Update/Delete.
- **Realtime Telemetry:** Since these are operations are not too frequent, batch posting of telemetry every min to the telemetry tools should be fine instead of real time posting of data.

# Architecture

## **Runtime environment:** 

The solution can be run in both local laptop/VM or in Kubernetes/Minikube. I used minikube on my laptop to deploy due to cost contraints for 2 weeks on Kubernetes on any public cloud. Minikube is free and works 90% same as any public cloud hosted Kubernetes cluster.

**Architecture explaination:**

1. Relational features of Postgres are used as normalized data with better suit the requirement here.
2. One time data load ~250K records into database. Later normalized and transferred to different tables using stored procedures. This is one time activity and will take much longer if done via front end APIs. Post this on time step, all the data is normalized into the tables and ready for the APIs to be consumed and edited.
3. Instead of prepared statements, I have used postgres functions for straight forwards operations (create/update/view/delete) which do not require business rule coordination. Benefits: Faster execution as the stored procedures are pre-compiled.
4. Though to demonstrate the usability of the prepared statements, I have used it in a few delete/create APIs.
5. The APIs can be grouped into two ways. First based on the business tribe. Example: Location can be one tribe, Census can be other. I could not do it due to time constraints and grouped them only into two parts - read (get) and create/update/delete (cud). Get APIs are standalone but CUD APIs need to consult with GET APIs for pre-checks before registration creation. For example, before creating/updating a registration, we need to make sure base data like city, state, census tract, ev type, car model etc. exist. The CUD APIs call GET APIs for this.
6. CUD and GET APIs run in different pods and use Kubernetes Cluster IP to communicate.
7. Created "Get All" APIs as well (example: getAllEVTypes, getAllModels etc.) to help create a UI as frontend.
**8. Summary:** Database (in Kubernetes) holds normalized data after one time data load, APIs (in Kubernetes) talk to the database and with each other.
   
Please see following sections for other details like logging, telemetry, updating a certain type of models etc.

**Database Design:**
The database is normalized into various tables. Here are some considerations. (PK = Primary Key, FK = Foreign Key). The are taken into account after analyzing the bulk data.
1. State is unique and has PK. Has its own table.
2. State + County combination is unique. Same county name is present in multiple states. Hence a county table with County Id (PK) and has State Id (FK)
3. County Id + City + Zip combination tends to be unique. This is the registration location. Hence a reg_loc table (with PK) with County Id from table in #2 above as (FK)
4. Census Tract + County are considered a unique combination. Hence a census table (with PK) with County Id from table in #2 above as (FK)
5. Car model (make, model, year) is one unique table with PK.
6. EV Type is one unique table with PK.
7. CAVF is one unique table with PK.
8. DOL Vehicle id is unique. Seems like registration id. This can be considered primary key in the main Registraiton tables. VIN number repeats and each repetition has unique DOL Vehicle id.
9. The main Registraiton tables holds records like MSRP, GPS location etc. and joins the tables from #1 to #8 above to finally make the form. The following ERD Diagram and the JOIN statement explains this all.
10. Another table is created for looking at the performance of each Stored Procedure and Function. A unique run id is passed in the API and eventually to the DB to keep and end to end track of execution time.


[ERD Diagram](https://github.com/techoboa/ev-reg-apis/blob/main/pics/ERD_EV_DB.png?raw=true)

```
select			
	ev.vin, 
	ev.dol_veh_id,	
	r.city,
	r.zip,	
	st.st,
	cn.county,
	m.make,
	m.model,	
	m.m_year,	
	et.ev_type,
	ca.cavf,
	ev.ev_range,
	ev.msrp,
	ev.leg_dist,
	ev.veh_location_gps,
	ev.el_utility,
	ct.census_t
from 
	m.t_ev_regs ev,
	m.t_models m,
	m.t_reg_loc r,
	m.t_counties cn,	
	m.t_states st,		
	m.t_ev_type et,
	m.t_cavf ca,
	m.t_census_t ct
where
	ev.id_model = m.id_model and
	ev.id_ev_type = et.id_ev_type and
	ev.id_cavf = ca.id_cavf and
	ev.id_census_t = ct.id_census_t and
	ev.id_reg_loc = r.id_reg_loc and	
	cn.id_state = st.id_state and
	cn.id_county = r.id_county
```

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

```
brew uninstall minikube

brew install minikube

minikube start
```

### Database
Deploy postgres in containers using the following procedure. Followed this tutorial: https://medium.com/@hijessicahsu/deploy-postgres-on-minikube-5cd8f9ffc9c

#### Creating Database

**- Install helm and add bitnami helm repo for postgres**
```
brew install helm

helm repo add bitnami https://charts.bitnami.com/bitnami
```

**- Create Persistent volume and claim for the database **using kubectl apply -f on the following two files in order:
  ```
https://github.com/techoboa/ev-reg-apis/blob/main/postgres/kubernetes/postgres_pv.yml

https://github.com/techoboa/ev-reg-apis/blob/main/postgres/kubernetes/postgres_pvc.yml
```

**- Download chart, untar the tgz, find the values.yaml, take a look, and update it, if needed.**
```
helm pull bitnami/postgresql

tar -xvf postgresql-16.5.3.tgz

helm install postgres bitnami/postgresql -f _Chart_Location_/postgresql/values.yaml
```
**- Post Install Steps:**

1. PostgreSQL can be accessed via port 5432 on the following DNS names from within your cluster:
```
    postgres-postgresql.default.svc.cluster.local - Read/Write connection
```
2. To get the password for "postgres" run:
```
    export POSTGRES_PASSWORD=$(kubectl get secret --namespace default postgres-postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)
```
3. Test a client connection

To connect to your database run the following command:

    kubectl run postgres-postgresql-client --rm --tty -i --restart='Never' --namespace default --image docker.io/bitnami/postgresql:17.4.0-debian-12-r9 --env="PGPASSWORD=$POSTGRES_PASSWORD" \
      --command -- psql --host postgres-postgresql -U postgres -d postgres -p 5432

    > NOTE: If you access the container using bash, make sure that you execute "/opt/bitnami/scripts/postgresql/entrypoint.sh /bin/bash" in order to avoid the error "psql: local user with ID 1001} does not exist"

4. To connect to your database from outside the cluster using pgadmin or psql, execute the following commands. This step is necessary specifically if working with Minikube. Its also added here: https://github.com/techoboa/ev-reg-apis/blob/main/containers/minikube_tunnel.sh . Alternately create a new NodePort Service and use Minikube tunneling as done in the API side (explained later)
```
    kubectl port-forward --namespace default svc/postgres-postgresql 5432:5432 &
    PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d postgres -p 5432
```
#### Create schema:

The provided recordset has ~250K records in total. It will take a lot of time to insert them one at a time in a normalized relational database using Front end APIs. Bulk load should be better choice here as its a one time load. I followed the following steps:

- Please manually create a schema named "m" under default database postgres. I forgot to add the code for schema creation in the sql script. And yes, I am guilty of naming it a random "m". But later I have done a good job of naming all other objects.

- Then use the sql script to create the rest of the artifacts including tables, functions and prcodecures. This will create a temporary table m._t_ev for holding the raw records and analysis. This will also create the required procedures to normalize the bulk loaded in temporary table.
  
https://github.com/techoboa/ev-reg-apis/blob/main/postgres/sql/ev_api_data_layer.sql


#### Bulk Data Load Process

1. First load the downloaded CSV into the table m.t_ev using either PSQL or PGADMIN (Import/Export Data feature). For PSQL, first take the csv into the pod, and then run this command -
2. 
```
COPY table_name [(column_list)]
FROM 'file_name| file_path' 
CSV HEADER;
```

3. Call the following procedures from psql/pgadmin in order to load data from m.t_ev to other tables which are normalized. Unique Ids are generated on each row in the normalized tables.

```
**- call m.p_prep_bulk_models();** -- This one inserts data into the car model table

**- call m.p_prep_bulk_states();** -- This one inserts data into the states table

**- call m.p_prep_bulk_counties();** -- This one inserts data into the county table. Note that, State + County is a unique combination as same county can be in two states. State is a Foriegn Key here.

**- call m.p_prep_bulk_census_t();** -- This one inserts data into the census table. County id is a Foriegn Key here.

**- call m.p_prep_bulk_reg_loc();** -- This one inserts data into the reg_loc (registration location) table. County id is a Foriegn Key here. Table has city and zip.

**- call m.p_prep_bulk_ev_type();** -- This one inserts data into the ev type table

**- call m.p_prep_bulk_cavf();** -- This one inserts data into the cavf table

**- call m.p_prep_ev_regs();** -- This one JOINS all the above tables and inserts final records in the m.t_ev_regs table. This can take long to complete. Took me 8 mins as there are JOINS on various tables and 250K rows. Depending on the system performance, it can take longer or broken connection. In that case, process records in Bulk.
```

Post this on time step, all the data is normalized into the tables and ready for the APIs to be consumed and edited.

### APIs
 
Listing all services here. A few are unimplemented due to time constraints. Though the database has the required functions in place. Also, the implementation pattern would be exactly same as the ones implemented. In addition, these features must be priority 2, I guess.

Please see acceptable data format for each in the test client submitted with the code. Here: [Test Client and Data Format](https://github.com/techoboa/ev-reg-apis/blob/main/README.md#command-line-clients)


**Get APIs**

The GET file has the following services.
```
IMPLEMENTED
# @app.route("/", methods=['GET'])
# @app.route("/get_state_id", methods=['GET'])
# @app.route("/get_cavf_id", methods=['GET'])
# @app.route("/get_ev_type_id", methods=['GET'])
# @app.route("/get_model_id", methods=['GET'])
# @app.route("/get_county_id", methods=['GET'])
# @app.route("/get_reg_loc_id", methods=['GET'])
# @app.route("/get_census_t_id", methods=['GET'])
# @app.route("/get_regs_by_vin", methods=['GET'])
# @app.route("/get_regs_by_dol_veh_id", methods=['GET'])
# @app.route("/get_all_models", methods=['GET'])
# @app.route("/get_all_ev_types", methods=['GET'])
# @app.route("/get_all_cavf", methods=['GET'])
# @app.route("/get_all_states", methods=['GET'])
# @app.route("/get_all_regs", methods=['GET'])

NOT IMPLEMENTED DUE TO TIME CONSTRAINTS. IMPLEMENTATION PATTERN WOULD BE EXACTLY SAME AS THE ONES IMPLEMENTED.

# @app.route("/get_all_counties", methods=['GET'])
# @app.route("/get_all_cities", methods=['GET'])
# @app.route("/get_all_zips", methods=['GET'])
```
**CUD APIs:**

The CUD file has the following services.
```
IMPLEMENTED
# @app.route("/create_state", methods=['POST'])
# @app.route("/create_county", methods=['POST'])
# @app.route("/create_census_t", methods=['POST'])
# @app.route("/create_reg_loc", methods=['POST'])
# @app.route("/create_cavf", methods=['POST'])
# @app.route("/create_ev_type", methods=['POST'])
# @app.route("/create_model", methods=['POST'])
# @app.route("/create_update_registration/<action>", methods=['POST', 'PUT'])
# @app.route("/delete_registration_by_dol_veh_id", methods=['DELETE'])
# @app.route("/delete_state", methods=['DELETE'])

NOT IMPLEMENTED DUE TO TIME CONSTRAINTS. IMPLEMENTATION PATTERN WOULD BE EXACTLY SAME AS THE ONES IMPLEMENTED.
# @app.route("/update_model", methods=['PUT'])
# @app.route("/update_ev_type", methods=['PUT'])
# @app.route("/update_cavf", methods=['PUT'])
# @app.route("/update_county_state", methods=['PUT'])
# @app.route("/update_reg_loc", methods=['PUT'])
# @app.route("/update_census_t", methods=['PUT'])
# @app.route("/delete_reg_loc", methods=['DELETE'])
# @app.route("/delete_census_t", methods=['DELETE'])
# @app.route("/delete_county", methods=['DELETE'])
# @app.route("/delete_cavf", methods=['DELETE'])
# @app.route("/delete_ev_type", methods=['DELETE'])
# @app.route("/delete_model", methods=['DELETE'])
```

#### Deploying APIs

## On Laptop/VM:
If you have a local postgres database on laptop, import the SQL script in the repo. Please manually create a schema named "m" under defaukt database postgres. I forgot to add the code for schema creation in the sql script. And yes, I am guilty of naming it a random "m". But later I have done a good job of naming all other objects.

For API services, change the database details in the db.properties file and just run the two services file using:

```
- All get APIs: python3 ev_reg_read_apis.py
- All CUD APIs: python3 ev_reg_create_update_delete_apis.py
```

The log and telemetry files are created by default in /tmp. Its hardcoded.

## Database
### Creating Database
### Bulk Data Load Process

## APIs
### Deploying APIs

**1. Gathering required files:** Go to the directory "containers" in this repo. Copy files to the docker home dir. Code arrangement should be structured. I was running into problems at the last moment, so had to resort to this approach. This is a band-aid, time permitting, I would like to correct it.

cp -R app/*.py util/*.py config/*.properties ./containers/

**2. Confuguring DB Connection:** Make changes to the db.properties file as follows

```
(base) containers % cat db.properties
[db]
db_host=[db host]
db_name=postgres 
db_port=5432
db_schema=m 
db_user_key=[user]
db_passwd_key=[password]
db_retries_limit=50
db_retries_interval=10
```

db_host is ClusterIP or DNS name like "postgres-postgresql.default.svc.cluster.local", if running in Kubernetes.

**3. Create two Images** for the GET and CUD services.

Login to your choice of container repository. Can be online, your organization’s or local repository running on laptop or docker. Make sure you have access to pull and push images. Once that’s setup, build and upload images for EV registration GET and CUD API services.

I have made a couple of docker build scripts (One for get APIs and second for CUD APIs), which you only need to execute to create and push. Only two things to change:

- Pass image version tag to the script. Else, it will build with latest tag be default.
- Replace [registry_user_name] with Container Registry user name.

Execute both like this

```
./DockerBuild_get.sh 1
./DockerBuild_cud.sh 1
```

```
(base) containers % ./DockerBuild_get.sh 6
[+] Building 53.2s (10/10) FINISHED                                                                                                docker:desktop-linux
 => [internal] load build definition from Dockerfile_ev_apis_get                                                                                   0.1s
 => => transferring dockerfile: 1.54kB                                                                                                             0.0s
 => [internal] load metadata for docker.io/library/python:3.8-slim                                                                                 0.7s
 => [internal] load .dockerignore                                                                                                                  0.0s
 => => transferring context: 2B                                                                                                                    0.0s
 => [1/5] FROM docker.io/library/python:3.8-slim@sha256:1d52838af602b4b5a831beb13a0e4d073280665ea7be7f69ce2382f29c5a613f                           0.0s
 => [internal] load build context                                                                                                                  0.0s
 => => transferring context: 1.26kB                                                                                                                0.0s
 => CACHED [2/5] WORKDIR /app                                                                                                                      0.0s
 => [3/5] ADD . /app                                                                                                                               0.1s
 => [4/5] RUN apt update && apt -y upgrade && apt -y install curl && apt-get -y install procps && apt -y install net-tools && apt-get install li  40.5s
 => [5/5] RUN pip3 install flask && pip3 install fastapi && pip3 install uvicorn && pip3 install pytest && pip3 install httpx && pip3 install ps  11.2s 
…….
…….
…….
…….
e0d4d475838b: Pushed 
e097f7f5f56e: Pushed 
d9f9648a0ca7: Pushed 
37a1cefd45b9: Layer already exists 
71be48336db2: Layer already exists 
68927dfce826: Layer already exists 
01183e0d6e03: Layer already exists 
054df1200f3e: Layer already exists 
v6: digest: sha256:81da52e671a339ac9fb90540391d2df4e9cc74b785675e6c3bef45c03cf30e12 size: 1998
(base) containers % 
```
```
(base) containers % ./DockerBuild_cud.sh 4
[+] Building 71.4s (11/11) FINISHED                                                                                                docker:desktop-linux
 => [internal] load build definition from Dockerfile_ev_apis_cud                                                                                   0.1s
 => => transferring dockerfile: 1.72kB                                                                                                             0.0s
 => [internal] load metadata for docker.io/library/python:3.8-slim                                                                                 1.0s
 => [auth] library/python:pull token for registry-1.docker.io                                                                                      0.0s
 => [internal] load .dockerignore                                                                                                                  0.0s
 => => transferring context: 2B                                                                                                                    0.0s
 => [1/5] FROM docker.io/library/python:3.8-slim@sha256:1d52838af602b4b5a831beb13a0e4d073280665ea7be7f69ce2382f29c5a613f                           0.0s
 => [internal] load build context                                                                                                                  0.0s
 => => transferring context: 1.27kB                                                                                                                0.0s
 => CACHED [2/5] WORKDIR /app                                                                                                                      0.0s
 => [3/5] ADD . /app                                                                                                                               0.2s
 => [4/5] RUN apt update && apt -y upgrade && apt -y install curl && apt-get -y install procps && apt -y install net-tools && apt-get install li  45.9s
 => [5/5] RUN pip3 install flask && pip3 install fastapi && pip3 install uvicorn && pip3 install pytest && pip3 install httpx && pip3 install ps  21.7s 
…….
…….
…….
…….
2093624f706a: Pushed 
37a1cefd45b9: Layer already exists 
71be48336db2: Layer already exists 
68927dfce826: Layer already exists 
01183e0d6e03: Layer already exists 
054df1200f3e: Layer already exists 
v4: digest: sha256:fcecf7f2a7da8dc80f1d5701904519a214b5d6dcfc9bd7bf0646075331d28e8f size: 1998
(base) containers % 
```



**4. Modify kubernetes yamls: **

Edit BOTH the kubernetes yaml files for the image location and version in the deployment.

```
https://github.com/techoboa/ev-reg-apis/blob/main/containers/ev_cud_apis_k8s.yaml
https://github.com/techoboa/ev-reg-apis/blob/main/containers/ev_get_apis_k8s.yaml
```

```
       containers:
      - image: [image]:[version]
        name: ev-cud-app
```

**5. Apply the kubectl files** to create resources in the Minikube kubernetes cluster. 

```
(base) anuragshrivastava@Anurags-MacBook-Pro containers % kubectl apply -f ev_get_apis_k8s.yaml
deployment.apps/ev-get-app created
service/ev-get-app unchanged
ingress.networking.k8s.io/ev-get-app unchanged
service/ev-get-app-service-nodeport unchanged


(base) anuragshrivastava@Anurags-MacBook-Pro containers % kubectl apply -f ev_cud_apis_k8s.yaml
deployment.apps/ev-cud-app created
service/ev-cud-app unchanged
ingress.networking.k8s.io/ev-cud-app unchanged
service/ev-cud-app-service-nodeport unchanged
(base) anuragshrivastava@Anurags-MacBook-Pro containers % 
```

**6. Validate:** 

One pods for each service will show as running:

```
(base) anuragshrivastava@Anurags-MacBook-Pro containers % kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
ev-cud-app-6697f8598d-g5cbt   1/1     Running   0          5m33s
ev-get-app-b77455b54-nl62v    1/1     Running   0          40m
postgres-postgresql-0         1/1     Running   2          2d17h
(base) anuragshrivastava@Anurags-MacBook-Pro containers % 
```

7. Start minikube tunnel to the node port services, if working on minikube. Call services at these URLs from your local machine. If you need internet based access to these, then please create Load Balancer service instead of the Node Port.

```
minikube service ev-cud-app-service-nodeport --url
http://127.0.0.1:61991 ## Use this URL to connect from laptop

minikube service ev-get-app-service-nodeport --url
http://127.0.0.1:59825 ## Use this URL to connect from laptop
```


### How to test and use

Refer this: https://github.com/techoboa/ev-reg-apis/blob/main/README.md#command-line-clients


# Command Line Clients

Following command line clients were used for testing GET and CUD APIs. These files also have the required data formats to call each API.

```
https://github.com/techoboa/ev-reg-apis/blob/main/client_command_line/test_client_get_ev_api_cmd.sh
https://github.com/techoboa/ev-reg-apis/blob/main/client_command_line/test_client_cud_ev_api_cmd.sh
```

Run like this by passing API host for get and cud respectively. GET one, only need one. CUD one, needs both.
```
./test_client_get_ev_api_cmd.sh "http://127.0.0.1:59825"; cat /tmp/ev_api_cud_test_out.txt 
./test_client_cud_ev_api_cmd.sh "http://127.0.0.1:59825" "http://127.0.0.1:61991"; cat /tmp/ev_api_cud_test_out.txt
```


# Test cases and results
The test results are stored here:

```

https://github.com/techoboa/ev-reg-apis/blob/main/client_command_line/test_client_get_ev_api_cmd.sh
https://github.com/techoboa/ev-reg-apis/blob/main/client_command_line/test_client_cud_ev_api_cmd.sh


https://github.com/techoboa/ev-reg-apis/tree/main/test_results

```

# Updating Records for EV Model and Make (Tesla Model Y in this example)

There are around ~50K records Tesla Model Y belonging to different states. Initially MSRP is 0. Looking at other models, seems like price of same make/model/year can vary among states. With this in mind, I created the following JSON map to map state, make, model and year to different prices. Used CSV DB Export and Converted to JSON after adding price.

Then, I opened the JSON using SQL as a table row using a new feature JSON_TABLE in postgres. Updated the main table using JOINs as below.



```
do
$$
declare
msrp_map text;
BEGIN
	msrp_map = '[ { "st": "AK", "make": "TESLA", "model": "MODEL Y", "m_year": 2021, "msrp": 50000 }, { "st": "AL", "make": "TESLA", "model": "MODEL Y", "m_year": 2021, "msrp": 50000 }, { "st": "AZ", "make": "TESLA", "model": "MODEL Y", "m_year": 2022, "msrp": 50000 }, { "st": "AZ", "make": "TESLA", "model": "MODEL Y", "m_year": 2023, "msrp": 50000 }, { "st": "CA", "make": "TESLA", "model": "MODEL Y", "m_year": 2020, "msrp": 40000 }, { "st": "CA", "make": "TESLA", "model": "MODEL Y", "m_year": 2021, "msrp": 50000 }, { "st": "CA", "make": "TESLA", "model": "MODEL Y", "m_year": 2022, "msrp": 50000 }, { "st": "CA", "make": "TESLA", "model": "MODEL Y", "m_year": 2023, "msrp": 50000 }, { "st": "CA", "make": "TESLA", "model": "MODEL Y", "m_year": 2024, "msrp": 50000 }, { "st": "CO", "make": "TESLA", "model": "MODEL Y", "m_year": 2022, "msrp": 50000 }, { "st": "CO", "make": "TESLA", "model": "MODEL Y", "m_year": 2023, "msrp": 50000 }, { "st": "CT", "make": "TESLA", "model": "MODEL Y", "m_year": 2021, "msrp": 50000 }, { "st": "CT", "make": "TESLA", "model": "MODEL Y", "m_year": 2022, "msrp": 50000 }, { "st": "FL", "make": "TESLA", "model": "MODEL Y", "m_year": 2020, "msrp": 41000 }, { "st": "FL", "make": "TESLA", "model": "MODEL Y", "m_year": 2022, "msrp": 50000 }, { "st": "FL", "make": "TESLA", "model": "MODEL Y", "m_year": 2023, "msrp": 50000 }, { "st": "HI", "make": "TESLA", "model": "MODEL Y", "m_year": 2022, "msrp": 50000 }, { "st": "ID", "make": "TESLA", "model": "MODEL Y", "m_year": 2021, "msrp": 50000 }, { "st": "IL", "make": "TESLA", "model": "MODEL Y", "m_year": 2021, "msrp": 50000 }, { "st": "KS", "make": "TESLA", "model": "MODEL Y", "m_year": 2024, "msrp": 50000 }, { "st": "LA", "make": "TESLA", "model": "MODEL Y", "m_year": 2022, "msrp": 50000 }, { "st": "MA", "make": "TESLA", "model": "MODEL Y", "m_year": 2022, "msrp": 50000 }, { "st": "MA", "make": "TESLA", "model": "MODEL Y", "m_year": 2023, "msrp": 50000 }, { "st": "MD", "make": "TESLA", "model": "MODEL Y", "m_year": 2020, "msrp": 42000 }, { "st": "MD", "make": "TESLA", "model": "MODEL Y", "m_year": 2021, "msrp": 50000 }, { "st": "MD", "make": "TESLA", "model": "MODEL Y", "m_year": 2022, "msrp": 50000 }, { "st": "MD", "make": "TESLA", "model": "MODEL Y", "m_year": 2023, "msrp": 50000 }, { "st": "MD", "make": "TESLA", "model": "MODEL Y", "m_year": 2024, "msrp": 50000 }, { "st": "MO", "make": "TESLA", "model": "MODEL Y", "m_year": 2023, "msrp": 50000 }, { "st": "NC", "make": "TESLA", "model": "MODEL Y", "m_year": 2021, "msrp": 50000 }, { "st": "NC", "make": "TESLA", "model": "MODEL Y", "m_year": 2022, "msrp": 50000 }, { "st": "NC", "make": "TESLA", "model": "MODEL Y", "m_year": 2023, "msrp": 50000 }, { "st": "NJ", "make": "TESLA", "model": "MODEL Y", "m_year": 2022, "msrp": 50000 }, { "st": "NJ", "make": "TESLA", "model": "MODEL Y", "m_year": 2023, "msrp": 50000 }, { "st": "NV", "make": "TESLA", "model": "MODEL Y", "m_year": 2023, "msrp": 50000 }, { "st": "NY", "make": "TESLA", "model": "MODEL Y", "m_year": 2021, "msrp": 50000 }, { "st": "NY", "make": "TESLA", "model": "MODEL Y", "m_year": 2022, "msrp": 50000 }, { "st": "NY", "make": "TESLA", "model": "MODEL Y", "m_year": 2023, "msrp": 50000 }, { "st": "NY", "make": "TESLA", "model": "MODEL Y", "m_year": 2024, "msrp": 50000 }, { "st": "OH", "make": "TESLA", "model": "MODEL Y", "m_year": 2022, "msrp": 50000 }, { "st": "OR", "make": "TESLA", "model": "MODEL Y", "m_year": 2022, "msrp": 50000 }, { "st": "PA", "make": "TESLA", "model": "MODEL Y", "m_year": 2023, "msrp": 50000 }, { "st": "RI", "make": "TESLA", "model": "MODEL Y", "m_year": 2021, "msrp": 50000 }, { "st": "SC", "make": "TESLA", "model": "MODEL Y", "m_year": 2021, "msrp": 50000 }, { "st": "TN", "make": "TESLA", "model": "MODEL Y", "m_year": 2024, "msrp": 50000 }, { "st": "TX", "make": "TESLA", "model": "MODEL Y", "m_year": 2022, "msrp": 50000 }, { "st": "TX", "make": "TESLA", "model": "MODEL Y", "m_year": 2023, "msrp": 50000 }, { "st": "TX", "make": "TESLA", "model": "MODEL Y", "m_year": 2024, "msrp": 50000 }, { "st": "VA", "make": "TESLA", "model": "MODEL Y", "m_year": 2020, "msrp": 43000 }, { "st": "VA", "make": "TESLA", "model": "MODEL Y", "m_year": 2021, "msrp": 50000 }, { "st": "VA", "make": "TESLA", "model": "MODEL Y", "m_year": 2022, "msrp": 50000 }, { "st": "VA", "make": "TESLA", "model": "MODEL Y", "m_year": 2023, "msrp": 50000 }, { "st": "VA", "make": "TESLA", "model": "MODEL Y", "m_year": 2024, "msrp": 50000 }, { "st": "WA", "make": "TESLA", "model": "MODEL Y", "m_year": 2020, "msrp": 44000 }, { "st": "WA", "make": "TESLA", "model": "MODEL Y", "m_year": 2021, "msrp": 50000 }, { "st": "WA", "make": "TESLA", "model": "MODEL Y", "m_year": 2022, "msrp": 50000 }, { "st": "WA", "make": "TESLA", "model": "MODEL Y", "m_year": 2023, "msrp": 50000 }, { "st": "WA", "make": "TESLA", "model": "MODEL Y", "m_year": 2024, "msrp": 50000 }, { "st": "WA", "make": "TESLA", "model": "MODEL Y", "m_year": 2025, "msrp": 50000 }, { "st": "WY", "make": "TESLA", "model": "MODEL Y", "m_year": 2023, "msrp": 50000 } ]';

	update m.t_ev_regs r
		set msrp = mp.msrp
	from
		JSON_TABLE(msrp_map, '$[*]' COLUMNS (
			st text PATH '$.st',
			make text PATH '$.make',
			model text PATH '$.model',
			m_year integer PATH '$.m_year',
			msrp integer PATH '$.msrp'		
		)) as mp,
		m.t_models mo,
		m.t_counties c,
		m.t_states s,
		m.t_reg_loc rl
	where
		mo.make = 'TESLA'
		and mo.model = 'MODEL Y'
		and r.id_model = mo.id_model
		and r.id_reg_loc = rl.id_reg_loc
		and c.id_county = rl.id_county
		and c.id_state = s.id_state
		and mo.make = mp.make
		and mo.model = mp.model		
		and mo.m_year = mp.m_year
		and mp.st = s.st;
		
	commit;
END
$$
```

# Tracking and Telemetery

- **Performance:**
API call times and DB procedure/function times are being tracked and can be sent to telemetry servers. A unique end to end parameter (route id/run id) for each API call is tracked in app lgos and a database table.

The API times are being reported into a file called telemetry_ev_get_apis.txt. This can be sent periodically (every min) to the Telemetry server. They have (like elastic search or splunk) capability to read only the chagnes.

Alternatively, a light weight queueing engine like RabbitMQ, Mosquito etc. can be used to collect these for decoupling.

```
(base) /tmp % cat telemetry_ev_get_apis.txt
ev_api_get_regs_by_dol_veh_id-20250326-090928344|2025-03-26 16:09:28.344170|2025-03-26 16:09:30.929152|0:00:02.584982
ev_api_get_regs_by_dol_veh_id-20250326-091030469|2025-03-26 16:10:30.468790|2025-03-26 16:10:31.764578|0:00:01.295788
ev_api_update_unimplemented-20250326-091042242|2025-03-26 16:10:42.242161|2025-03-26 16:10:42.242732|0:00:00.000571
ev_api_get_regs_by_dol_veh_id-20250326-091107491|2025-03-26 16:11:07.491536|2025-03-26 16:11:09.640091|0:00:02.148555
ev_api_get_regs_by_dol_veh_id-20250326-091110690|2025-03-26 16:11:10.690979|2025-03-26 16:11:10.926792|0:00:00.235813
ev_api_get_regs_by_dol_veh_id-20250326-144000485|2025-03-26 21:40:00.485020|2025-03-26 21:40:16.270277|0:00:15.785257
(base) /tmp % 
```

The database is also holding a table which shows the total run time of the procedures/functions.

Use this query:

```
select run_id, sql_caller, run_duration from m.t_sql_proc_fn_logs order by id_sql_proc_fn_log desc limit 10;
```

Output:

```
"ev_api_get_regs_by_dol_veh_id-20250327-002301764"	"m.fn_get_regs_by_dol_veh_id"	"00:00:00.498845"
"ev_api_get_regs_by_dol_veh_id-20250327-002300170"	"m.fn_get_regs_by_dol_veh_id"	"00:00:00.605369"
"ev_api_get_regs_by_dol_veh_id-20250327-002259574"	"m.fn_get_regs_by_dol_veh_id"	"00:00:00.495647"
"ev_api_get_census_t_id-20250327-002258853"	"m.fn_get_census_t_id"	"00:00:00.001421"
"ev_api_get_census_t_id-20250327-002258853"	"m.fn_get_county_id_for_state"	"00:00:00.002525"
"ev_api_get_census_t_id-20250327-002258853"	"m.fn_get_state_id"	"00:00:00.086319"
"ev_api_get_reg_loc_id-20250327-002257941"	"m.fn_get_reg_loc_id"	"00:00:00.001765"
"ev_api_get_reg_loc_id-20250327-002257941"	"m.fn_get_county_id_for_state"	"00:00:00.097951"
"ev_api_get_reg_loc_id-20250327-002257941"	"m.fn_get_state_id"	"00:00:00.001346"
"ev_api_get_county_id-20250327-002257655"	"m.fn_get_county_id_for_state"	"00:00:00.001478"
```

Please see there is a correlation using route_id in the first column in telemetry log and first column in SQL output.

- **Logging:**
Sufficient logging has been provided at all levels from TRACE TO INFO. Common and easy to troubleshoot formatting configured which makes it easy to correlate logs from multiple folders to be able get a wholistic view.

```
(base) /tmp/ev_apis_logs % ls -ltr
total 0
drwxr-xr-x  3 root  wheel  96 Mar 26 14:37 Debug
drwxr-xr-x  3 root  wheel  96 Mar 26 14:37 Info
drwxr-xr-x  3 root  wheel  96 Mar 26 14:37 Warning
drwxr-xr-x  3 root  wheel  96 Mar 26 14:37 Error

(base) % cd Info; ls -ltr
total 8
-rw-r--r--  1 root  wheel  1506 Mar 26 14:40 ev_apis_logs.info

(base) % tail -10 ev_apis_logs.info
[2025-03-26 14:38:27,076]|INFO|ev_reg_read_apis.py|get_regs_by_dol_veh_id|Line: 470|ev_api_get_regs_by_dol_veh_id-20250326-143827073|Get request for registrations by dol_veh_id
[2025-03-26 14:40:00,485]|INFO|ev_reg_read_apis.py|get_regs_by_dol_veh_id|Line: 470|ev_api_get_regs_by_dol_veh_id-20250326-144000485|Get request for registrations by dol_veh_id
[2025-03-26 14:40:00,663]|INFO|db_helper.py|get_db_conn|Line: 50|ev_api_get_regs_by_dol_veh_id-20250326-144000485|New DB connection is created
[2025-03-26 14:40:00,664]|INFO|db_helper.py|get_db_cursor|Line: 62|ev_api_get_regs_by_dol_veh_id-20250326-144000485|New DB cursor is created
[2025-03-26 14:40:00,680]|INFO|db_helper.py|get_db_conn|Line: 50|ev_api_get_regs_by_dol_veh_id-20250326-144000485|New DB connection is created
[2025-03-26 14:40:00,680]|INFO|db_helper.py|get_db_cursor|Line: 62|ev_api_get_regs_by_dol_veh_id-20250326-144000485|New DB cursor is created
[2025-03-26 14:40:00,680]|INFO|db_helper.py|execute_select|Line: 75|ev_api_get_regs_by_dol_veh_id-20250326-144000485|Executing query
[2025-03-26 14:40:16,261]|INFO|db_helper.py|execute_select|Line: 78|ev_api_get_regs_by_dol_veh_id-20250326-144000485|Done executing query
[2025-03-26 14:40:16,268]|INFO|db_helper.py|close_db_conn_cur|Line: 110|ev_api_get_regs_by_dol_veh_id-20250326-144000485|Closed DB connection and cursor
[2025-03-26 14:40:16,270]|INFO|general_helper.py|log_api_completion_time|Line: 27|ev_api_get_regs_by_dol_veh_id-20250326-144000485|api_duration: 0:00:15.785257

```

# Improvements which can be done

1. All core services are implemented. A few services like delete city, county etc. are implemented as dummy due to time constraint.
2. Currently adding telemetry details only to the file to be later read by an agent in batch mode. Can be directly sent over to the telemetry tool using REST APIs in real time.
3. Secure the APIs using TLS and Certs
4. Further code refinement to find opportunities to reuse code.
5. Optional: Services can be clubbed based on domains if business needs it. Like one each for mangaing services for city, county, censut tract etc. Currently, they are arranged as two categories Create/Update/Delete and Read.
6. Only a few APIs are commented due to time contraints as the pattern is same for all.
7. Load Balancers/Scalability
8. Connection poolling
9. Queueing for telemetry.


