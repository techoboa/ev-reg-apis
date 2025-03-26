#############################################################################################
# Author                Date            Version         Change
# Anurag Shrivastava    03/26/2025      1.0             Dependency Installation guide.
#
#############################################################################################

### Install the following OS and Python dependencies before you can run the code. This should be done in the Container or local system/VM running the APIs.
## Please remove the ones from the list which are already installed.


# OS Dependecies and utilities. Based on Debian. Please modity to brew or yum based on the system being used.
    #### Repo update
apt update
apt -y upgrade
    #### pre req for Python postgres library
apt-get -y install procps
apt-get install libpq5 
apt-get install libssl-dev
apt-get install libpq-dev
    #### Helpful troublshooting utilities
apt -y install curl
apt -y install net-tools    
apt-get install netcat-traditional
apt-get -y install vim

# Python Dependecies
pip3 install flask
pip3 install fastapi
pip3 install uvicorn
pip3 install pytest
pip3 install httpx
pip3 install psycopg2-binary
pip3 install autopylogger
pip3 install requests