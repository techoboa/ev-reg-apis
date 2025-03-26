#############################################################################################
# Author                Date            Version         Change
# Anurag Shrivastava    03/26/2025      1.0             Build and push docker image for CUD APIs (Create/Update/Delete).
#
#############################################################################################

# Usage guide:
# 1. Pass image version tag to the script. Else, it will build with latest tag be default.
# 2. Replace [registry_user_name] with Container Registry user name.

version=$1
docker build -t ev-app-cud . -f Dockerfile_ev_apis_cud
image=anuragpppp/ev-app-cud:v$version
docker tag ev-app-cud:latest $image
docker push $image
 
