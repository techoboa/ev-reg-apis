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
  Install the following OS and Python dependencies before you can run the code. This should be done in the Container or local system/VM running the APIs. Please remove the ones from the list which are already installed.


  OS Dependecies and utilities. Based on Debian. 
  **Repo update**
  
apt update

apt -y upgrade


    **pre req for Python postgres library**
apt-get -y install procps



apt-get install libpq5 


apt-get install libssl-dev


apt-get install libpq-dev


    **Helpful troublshooting utilities**
apt -y install curl


apt -y install net-tools    


apt-get install netcat-traditional


apt-get -y install vim



**Python API Dependecies**

pip3 install flask


pip3 install fastapi


pip3 install uvicorn


pip3 install pytest


pip3 install httpx


pip3 install psycopg2-binary


pip3 install autopylogger


pip3 install requests


    


# How to deploy

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

