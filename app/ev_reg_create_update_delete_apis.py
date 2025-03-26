#############################################################################################
# Author                Date            Version         Change
# Anurag Shrivastava    03/24/2025      1.0             EV Registration Create/Update/Delete APIs
#
#############################################################################################

# Improvement areas: 
# 1. All core services are implemented. A few services like delete city, county etc. are implemented as dummy due to time constraint.
# 2. Currently adding telemetry details only to the file to be later read by an agent in batch mode. Can be directly sent over to the
#    telemetry tool using REST APIs in real time.
# 3. Secure the APIs using TLS and Certs
# 4. Further code refinement to find opportunities to reuse code.
# 5. Optional: Services can be clubbed based on domains if business needs it. Like one each for mangaing services for city, county, censut tract etc.
#    Currently, they are arranged as two categories Create/Update/Delete and Read.
# 6. Only a few APIs are commented due to time contraints as the pattern is same for all.

# This file has the following services. 
# Some are unimplemented due to time constraints. Though the database has the required functions in place. Also, the
# implementation pattern would be exactly same as the ones implemented. In addition, these features must be priority 2, I guess.

# Please see acceptable data format for each in the test client submitted with the code.

#### IMPLEMENTED #######################
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

#### NOT IMPLEMENTED DUE TO TIME CONSTRAINTS. IMPLEMENTATION PATTERN WOULD BE EXACTLY SAME AS THE ONES IMPLEMENTED. #######################
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

from flask import Flask, request, jsonify, Response
import requests
import json
from functools import wraps
import sys
import datetime
from db_helper import *
from general_helper import *
from log_helper import *
from api_auth_helper import *
from autopylogger import init_logging
import os

# Logger utility. Supports auto-rotate, loglevels and formats. Helps build unified logging structure for all APIs.
logger = init_logging(log_name='ev_apis_logs', log_directory="/tmp", console_log=True, log_level='DEBUG', log_format='[%(asctime)s]|%(levelname)s|%(filename)s|%(funcName)s|Line: %(lineno)d|%(message)s')

route_name=""
get_api_username = "admin"
get_api_password = "secret"
print(os.environ['EV_API_GET_HOME']) #Should look like this: get_api_host = "http://127.0.0.1:5001"
get_api_host=os.environ['EV_API_GET_HOME']
header={'Content-type':'application/json', 'Accept':'application/json'}


app = Flask(__name__)

def call_ev_get_apis(url, data):
   return requests.get(url, data=data, auth=(get_api_username, get_api_password), headers = header)    

# Route contoller for the service
@app.route("/create_state", methods=['POST'])
# Handling API Authentication
@requires_auth
# Handling API Call
def create_state():

   # Record Start time of the API for telemetory collection later.
   api_start_time=datetime.utcnow()   

   # Unique route id being generated for each API run. This is also passed later to the database functions as a param called run_id.
   # Helps understand the end to end API performance including the API and database for each call.   
   route_name="ev_api_create_state"
   route_id=generate_module_runtime_id(route_name)

   try:
      # Getting JSON data from the client call.
      data = request.get_json()
      if not data:
          return jsonify({"error": "No data received"}), 400
  
      state_name = data.get('state')

      # Logging info
      lmsg='Create request for state'
      logger.info(concat_log_msg(route_id, lmsg))

      # Database connection from DB Helper
      conn = get_db_conn(logger, route_id)
      cur = get_db_cursor(conn, logger, route_id)

      # Calling pre-compiled database function and passing state id and route id.
      query = "SELECT m.fn_create_state('" + state_name + "', '" + route_id + "')"
      cur=execute_write(conn, cur, logger, route_id, query)
      rows = cur.fetchall()
      for data in rows:
          state_json = json.loads(str(data[0]))
          state_id = state_json.get('state_id')
          msg = state_json.get('return_msg')          

      # State already exist. For security purposes decided to get state id as 0 if the state exists during registration.
      if int(state_id) == 0:
            return jsonify({"msg": msg}), 400

      # Close DB connection
      close_db_conn_cur(conn, cur, logger, route_id)

      # Record end time of the API for telemetory collection into a file to be later processed by a batch telemetory job.      
      log_api_completion_time(logger, route_id, api_start_time)

      # Return the 200 response.
      return jsonify({"msg": msg}), 200

   except Exception as e:
      # Log and return error response.      
      lmsg="create state api_error: " + repr(e)
      logger.error(concat_log_msg(route_id, lmsg))
      log_api_completion_time(logger, route_id, api_start_time)
      return jsonify({"error_code": 400, "msg": "Some issue happened. Please try again"}), 400

@app.route("/create_county", methods=['POST'])
@requires_auth
def create_county():

   api_start_time=datetime.utcnow()   
   route_name="ev_api_create_county"
   route_id=generate_module_runtime_id(route_name)

   try:
      data = request.get_json()
      if not data:
          return jsonify({"error": "No data received"}), 400
  
      state_name = data.get('state')
      county = data.get('county')

      lmsg='Create request for new county'
      logger.info(concat_log_msg(route_id, lmsg))
      conn = get_db_conn(logger, route_id)
      cur = get_db_cursor(conn, logger, route_id)
      query = "SELECT m.fn_create_county_state('" + state_name + "', '" + county + "', '" + route_id + "')"
      cur=execute_write(conn, cur, logger, route_id, query)
      rows = cur.fetchall()
      for data in rows:
          county_json = json.loads(str(data[0]))
          county_id = county_json.get('county_id')
          msg = county_json.get('return_msg')

      if int(county_id) == 0:
            return jsonify({"msg": msg}), 400

      close_db_conn_cur(conn, cur, logger, route_id)
      log_api_completion_time(logger, route_id, api_start_time)

      return jsonify({"msg": "State and county combination for " + state_name + ", " + county + " registered successfully"}), 200

   except Exception as e:
      lmsg="create county api_error: " + repr(e)
      logger.error(concat_log_msg(route_id, lmsg))
      log_api_completion_time(logger, route_id, api_start_time)
      return jsonify({"error_code": 400, "msg": "Some issue happened. Please try again"}), 400      

@app.route("/create_census_t", methods=['POST'])
@requires_auth
def create_census_t():

   api_start_time=datetime.utcnow()   
   route_name="ev_api_create_census_t"
   route_id=generate_module_runtime_id(route_name)

   try:
      data = request.get_json()
      if not data:
          return jsonify({"error": "No data received"}), 400
  
      state_name = data.get('state')
      county = data.get('county')
      census_t = data.get('census_t')

      lmsg='Create request for new census_t'
      logger.info(concat_log_msg(route_id, lmsg))
      conn = get_db_conn(logger, route_id)
      cur = get_db_cursor(conn, logger, route_id)
      query = "SELECT m.fn_create_census_t('" + state_name + "', '" + county + "', " + str(census_t) + ", '" + route_id + "')"
      print(query)
      cur=execute_write(conn, cur, logger, route_id, query)
      rows = cur.fetchall()
      for data in rows:
          census_t_json = json.loads(str(data[0]))
          census_t_id = census_t_json.get('census_t_id')
          msg = census_t_json.get('return_msg')

      if int(census_t_id) == 0:
            return jsonify({"msg": msg}), 400

      close_db_conn_cur(conn, cur, logger, route_id)
      log_api_completion_time(logger, route_id, api_start_time)

      return jsonify({"msg": msg}), 200

   except Exception as e:
      lmsg="create census_t api_error: " + repr(e)
      logger.error(concat_log_msg(route_id, lmsg))
      log_api_completion_time(logger, route_id, api_start_time)
      return jsonify({"error_code": 400, "msg": "Some issue happened. Please try again"}), 400      

@app.route("/create_reg_loc", methods=['POST'])
@requires_auth
def create_reg_loc():

   api_start_time=datetime.utcnow()   
   route_name="ev_api_create_reg_loc"
   route_id=generate_module_runtime_id(route_name)

   try:
      data = request.get_json()
      if not data:
          return jsonify({"error": "No data received"}), 400
  
      state_name = data.get('state')
      county = data.get('county')
      city = data.get('city')
      zip = data.get('zip')

      lmsg='Create request for creating new registration location'
      
      logger.info(concat_log_msg(route_id, lmsg))
      conn = get_db_conn(logger, route_id)
      cur = get_db_cursor(conn, logger, route_id)
      query = "SELECT m.fn_create_reg_loc_t('" + state_name + "', '" + county + "', '" + city + "', " + str(zip) + ", '" + route_id + "')"
      print(query)
      cur=execute_write(conn, cur, logger, route_id, query)
      rows = cur.fetchall()
      for data in rows:
          reg_loc_json = json.loads(str(data[0]))
          reg_loc_id = reg_loc_json.get('reg_loc_id')
          msg = reg_loc_json.get('return_msg')

      if int(reg_loc_id) == 0:
            return jsonify({"msg": msg}), 400

      close_db_conn_cur(conn, cur, logger, route_id)
      log_api_completion_time(logger, route_id, api_start_time)

      return jsonify({"msg": msg}), 200

   except Exception as e:
      lmsg="create registration location api_error: " + repr(e)
      logger.error(concat_log_msg(route_id, lmsg))
      log_api_completion_time(logger, route_id, api_start_time)
      return jsonify({"error_code": 400, "msg": "Some issue happened. Please try again"}), 400      


@app.route("/create_cavf", methods=['POST'])
@requires_auth
def create_cavf():

   api_start_time=datetime.utcnow()   
   route_name="ev_api_create_cavf_id"
   route_id=generate_module_runtime_id(route_name)

   try:
      data = request.get_json()
      if not data:
          return jsonify({"error": "No data received"}), 400
  
      cavf_name = data.get('cavf')

      lmsg='Create request for cavf id.'
      logger.info(concat_log_msg(route_id, lmsg))
      conn = get_db_conn(logger, route_id)
      cur = get_db_cursor(conn, logger, route_id)
      query = "SELECT m.fn_create_cavf('" + cavf_name + "', '" + route_id + "')"
      print(query)
      cur=execute_write(conn, cur, logger, route_id, query)
      rows = cur.fetchall()
      for data in rows:
          print(str(data[0]))
          cavf_json = json.loads(str(data[0]))
          cavf_id = cavf_json.get('cavf_id')
          msg = cavf_json.get('return_msg')              

      if int(cavf_id) == 0:
            return jsonify({"msg": msg}), 400

      close_db_conn_cur(conn, cur, logger, route_id)
      log_api_completion_time(logger, route_id, api_start_time)

      return jsonify({"msg": msg}), 200
   except Exception as e:
      lmsg="create cavf api_error: " + repr(e)
      logger.error(concat_log_msg(route_id, lmsg))
      log_api_completion_time(logger, route_id, api_start_time)
      return jsonify({"error_code": 400, "msg": "Some issue happened. Please try again"}), 400   

@app.route("/create_ev_type", methods=['POST'])
@requires_auth
def create_ev_type():

   api_start_time=datetime.utcnow()   
   route_name="ev_api_create_ev_type"
   route_id=generate_module_runtime_id(route_name)

   try:
      data = request.get_json()
      if not data:
          return jsonify({"error": "No data received"}), 400
  
      ev_type = data.get('ev_type')

      lmsg='Create request for ev_type id.'
      logger.info(concat_log_msg(route_id, lmsg))
      conn = get_db_conn(logger, route_id)
      cur = get_db_cursor(conn, logger, route_id)
      query = "SELECT m.fn_create_ev_type('" + ev_type + "', '" + route_id + "')"
      print(query)
      cur=execute_write(conn, cur, logger, route_id, query)
      rows = cur.fetchall()
      for data in rows:
          ev_type_json = json.loads(str(data[0]))
          ev_type_id = ev_type_json.get('ev_type_id')
          msg = ev_type_json.get('return_msg')  

      if int(ev_type_id) == 0:
            return jsonify({"msg": msg}), 400

      close_db_conn_cur(conn, cur, logger, route_id)
      log_api_completion_time(logger, route_id, api_start_time)

      return jsonify({"msg": msg}), 200

   except Exception as e:
      lmsg="create ev_type api_error: " + repr(e)
      logger.error(concat_log_msg(route_id, lmsg))
      log_api_completion_time(logger, route_id, api_start_time)
      return jsonify({"error_code": 400, "msg": "Some issue happened. Please try again"}), 400

@app.route("/create_model", methods=['POST'])
@requires_auth
def create_model():

   api_start_time=datetime.utcnow()   
   route_name="ev_api_create_model"
   route_id=generate_module_runtime_id(route_name)

   try:
      data = request.get_json()
      if not data:
          return jsonify({"error": "No data received"}), 400
  
      model = data.get('model').upper()
      make = data.get('make').upper()
      m_year = data.get('m_year')

      lmsg='Create request for a new model'
      logger.info(concat_log_msg(route_id, lmsg))
      conn = get_db_conn(logger, route_id)
      cur = get_db_cursor(conn, logger, route_id)
      query = "SELECT m.fn_create_model(" + str(m_year) + ", '" + make + "', '" + model + "', '" + route_id + "')"
      print(query)
      cur=execute_write(conn, cur, logger, route_id, query)
      rows = cur.fetchall()
      for data in rows:
          print(str(data[0]))
          model_json = json.loads(str(data[0]))
          model_id = model_json.get('model_id')
          msg = model_json.get('return_msg')  

      if int(model_id) == 0:
            return jsonify({"msg": msg}), 400

      close_db_conn_cur(conn, cur, logger, route_id)
      log_api_completion_time(logger, route_id, api_start_time)

      return jsonify({"msg": msg}), 200

   except Exception as e:
      lmsg="create model api_error: " + repr(e)
      logger.error(concat_log_msg(route_id, lmsg))
      log_api_completion_time(logger, route_id, api_start_time)
      return jsonify({"error_code": 400, "msg": "Some issue happened. Please try again"}), 400

@app.route("/create_update_registration/<action>", methods=['POST', 'PUT'])
@requires_auth
def create_update_registration(action: str):
      
   api_start_time=datetime.utcnow()   
   route_name="ev_api_create_reg"
   route_id=generate_module_runtime_id(route_name)
   
   if action not in ('create', 'update'):
      lmsg="Only actions: create or update are allowed."
      logger.error(concat_log_msg(route_id, lmsg))
      log_api_completion_time(logger, route_id, api_start_time) 
      return jsonify({"msg": lmsg}), 400

   try:

      data = request.get_json()
      print(data)
      if not data:
          log_api_completion_time(logger, route_id, api_start_time) 
          return jsonify({"error": "No data received"}), 400
  
      vin = data.get('vin')
      county = data.get('county')      
      city = data.get('city')      
      state_name = data.get('st')
      zip = data.get('zip')
      m_year = data.get('m_year')
      make = data.get('make')
      model = data.get('model')
      ev_type = data.get('ev_type')
      cavf = data.get('cavf')
      ev_range = data.get('ev_range')
      msrp = data.get('msrp')
      leg_dist = data.get('leg_dist')
      dol_veh_id = data.get('dol_veh_id')    
      veh_location = data.get('veh_location_gps')
      el_utility = data.get('el_utility')
      census_t = data.get('census_t')      

      state_id = 0    
      cavf_id = 0
      ev_type_id = 0
      census_t_id = 0
      model_id = 0                        
      county_id = 0
      reg_loc_id = 0                                    
      

      lmsg='Create request for creating new registration'
      logger.info(concat_log_msg(route_id, lmsg))


      ####### START: Record and it's pre-req checks. ###################################      

      url = get_api_host + '/get_regs_by_dol_veh_id'      
      data = '{"dol_veh_id": ' + str(dol_veh_id) + '}'
      response = call_ev_get_apis(url, data)
      # For successful API call, response code will be 200 (OK)
      if(response.ok):
       #   print("ok response")

          # Loading the response data into a dict variable
          # json.loads takes in only binary or string variables so using content to fetch binary content
          # Loads (Load String) takes a Json file and converts into python data structure (dict or list, depending on JSON)
        #  print(response.content)
        #  print(response.text)
          if response.text != "None" and action == 'create':
             lmsg="DOL registration already exist for " + str(dol_veh_id)
             logger.error(concat_log_msg(route_id, lmsg))
             log_api_completion_time(logger, route_id, api_start_time)              
             return jsonify({"msg": lmsg}), 400

          if response.text == "None" and action == 'update':
             lmsg="DOL registration does exist for " + str(dol_veh_id) + " . Nothing to update."
             logger.error(concat_log_msg(route_id, lmsg))
             log_api_completion_time(logger, route_id, api_start_time)                
             return jsonify({"msg": lmsg}), 400             
      else:
          # If response code is not ok (200), print the resulting http error code with description
           lmsg="Some error occurred while checking the existence of " + str(dol_veh_id)
           logger.error(concat_log_msg(route_id, lmsg))          
           response.raise_for_status()
           log_api_completion_time(logger, route_id, api_start_time)                 
           return jsonify({"msg": lmsg}), 400

      url = get_api_host + '/get_state_id'
      data = '{"state": "' + str(state_name) + '"}'
      response = call_ev_get_apis(url, data)
      # For successful API call, response code will be 200 (OK)
      if(response.ok):
          print("ok response")
          #print(response.text)
          print(response.text)
          if "None" in response.text:
             lmsg="State: " + str(state_name) + " is not registered for DOL Vehicle Id: " + str(dol_veh_id) + " . Please register it first."
             logger.error(concat_log_msg(route_id, lmsg))
             log_api_completion_time(logger, route_id, api_start_time)                             
             return jsonify({"msg": lmsg}), 400
          state_json = json.loads(response.text)
          state_id = state_json["state_id"]
      else:
          # If response code is not ok (200), print the resulting http error code with description
           lmsg="Some error occurred while checking the existence for state of " + str(dol_veh_id)
           logger.error(concat_log_msg(route_id, lmsg))          
           response.raise_for_status()    
           log_api_completion_time(logger, route_id, api_start_time)                           
           return jsonify({"msg": lmsg}), 400
      
      url = get_api_host + '/get_cavf_id'
      data = '{"cavf": "' + cavf + '"}'
      response = call_ev_get_apis(url, data)
      # For successful API call, response code will be 200 (OK)
      if(response.ok):
          print("ok response")
          print(response.text)
          print(response.text)
          if response.text == "None":
             lmsg="CAVF: '" + cavf + "' is not registered. Please register it first."
             logger.error(concat_log_msg(route_id, lmsg))
             log_api_completion_time(logger, route_id, api_start_time)                
             return jsonify({"msg": lmsg}), 400
          else:
             cavf_json = json.loads(response.text)
             if cavf_json["cavf_id"] == "0":
                lmsg="CAVF: '" + cavf + "' is not registered. Please register it first."
                logger.error(concat_log_msg(route_id, lmsg))
                log_api_completion_time(logger, route_id, api_start_time)   
                return jsonify({"msg": lmsg}), 400   
          
             cavf_id = cavf_json["cavf_id"]
      else:
          # If response code is not ok (200), print the resulting http error code with description
           lmsg="Some error occurred while checking the existence for state of " + str(dol_veh_id)
           logger.error(concat_log_msg(route_id, lmsg))          
           response.raise_for_status()    
           log_api_completion_time(logger, route_id, api_start_time)              
           return jsonify({"msg": lmsg}), 400

      url = get_api_host + '/get_ev_type_id'
      data = '{"ev_type": "' + ev_type + '"}'
      response = call_ev_get_apis(url, data)

      # For successful API call, response code will be 200 (OK)
      if(response.ok):
          print("ok response")
          print(response.text)
          print(response.text)
          if response.text == "None":
             lmsg="EV Type: '" + ev_type + "' is not registered. Please register it first."
             logger.error(concat_log_msg(route_id, lmsg))
             log_api_completion_time(logger, route_id, api_start_time)   
             return jsonify({"msg": lmsg}), 400
          else:
             ev_type_json = json.loads(response.text)
             if ev_type_json["ev_type_id"] == "0":
                lmsg="EV Type: '" + ev_type + "' is not registered. Please register it first."
                print("here1")
                logger.error(concat_log_msg(route_id, lmsg))
                log_api_completion_time(logger, route_id, api_start_time)                   
                return jsonify({"msg": lmsg}), 400    
             ev_type_id = ev_type_json["ev_type_id"]
      else:
          # If response code is not ok (200), print the resulting http error code with description
           lmsg="Some error occurred while checking the existence for EV Type of " + str(ev_type)
           logger.error(concat_log_msg(route_id, lmsg))          
           response.raise_for_status()
           log_api_completion_time(logger, route_id, api_start_time)   
           return jsonify({"msg": lmsg}), 400        

      url = get_api_host + '/get_model_id'
      data = '{"model": "' + model + '", "make": "' + make + '", "m_year": "' + str(m_year) + '"}'
      response = call_ev_get_apis(url, data)
      # For successful API call, response code will be 200 (OK)
      if(response.ok):
          print("ok response")
          print(response.text)
          print(response.text)
          if response.text == "None":
             lmsg="Make/Model/Year combination: " + make + "/" + model + "/" + str(m_year) + " is not registered. Please register it first."
             logger.error(concat_log_msg(route_id, lmsg))
             log_api_completion_time(logger, route_id, api_start_time)             
             return jsonify({"msg": lmsg}), 400
          else:
             model_json = json.loads(response.text)
             if model_json["model_id"] == "0":
                lmsg="Make/Model/Year combination: " + make + "/" + model + "/" + str(m_year) + " is not registered. Please register it first."
                logger.error(concat_log_msg(route_id, lmsg))
                log_api_completion_time(logger, route_id, api_start_time)
                return jsonify({"msg": lmsg}), 400  
             model_id = model_json["model_id"]
             print("model_id = " + str(model_id))                              
      else:
          # If response code is not ok (200), print the resulting http error code with description
           lmsg="Some error occurred while checking the existence for Make/Model/Year combination: " + make + "/" + model + "/" + m_year
           logger.error(concat_log_msg(route_id, lmsg))          
           response.raise_for_status()    
           log_api_completion_time(logger, route_id, api_start_time)                      
           return jsonify({"msg": lmsg}), 400                  
      
      url = get_api_host + '/get_county_id'
      data = '{"state": "' + state_name + '", "county": "' + county + '"}'
      print("json: " + data)
      response = call_ev_get_apis(url, data)
      # For successful API call, response code will be 200 (OK)
      if(response.ok):
          print("ok response")
          print(response.text)
          print(response.text)
          if response.text == "None":
             lmsg="State/County combination: " + state_name + "/" + county + " is not registered. Please register it first."
             logger.error(concat_log_msg(route_id, lmsg))
             log_api_completion_time(logger, route_id, api_start_time)           
             return jsonify({"msg": lmsg}), 400
          else:
             county_json = json.loads(response.text)
             if county_json["county_id"] == "0":
                lmsg="State/County combination: " + state_name + "/" + county + " is not registered. Please register it first."
                logger.error(concat_log_msg(route_id, lmsg))
                log_api_completion_time(logger, route_id, api_start_time)                           
                return jsonify({"msg": lmsg}), 400  
             county_id = county_json["county_id"]
      else:
          # If response code is not ok (200), print the resulting http error code with description
           lmsg="Some error occurred while checking the existence for State/County combination: " + state_name + "/" + county
           logger.error(concat_log_msg(route_id, lmsg))          
           response.raise_for_status()    
           log_api_completion_time(logger, route_id, api_start_time)           
           return jsonify({"msg": lmsg}), 400                  

      url = get_api_host + '/get_reg_loc_id'
      data = '{"state": "' + state_name + '", "county": "' + county + '", "city": "' + city + '", "zip": "' + str(zip) + '"}' 
      print("json: " + data)
      response = call_ev_get_apis(url, data)
      # For successful API call, response code will be 200 (OK)
      if(response.ok):
          print("ok response")
          print(response.text)
          if response.text == "None":
             lmsg="State/County/City/Zip combination is not registered. Please register it first."
             logger.error(concat_log_msg(route_id, lmsg))
             log_api_completion_time(logger, route_id, api_start_time)
             return jsonify({"msg": lmsg}), 400
          else:
             city_json = json.loads(response.text)
             if city_json["reg_loc_id"] == "0":
                lmsg="State/County/City/Zip combination is not registered. Please register it first."
                logger.error(concat_log_msg(route_id, lmsg))
                log_api_completion_time(logger, route_id, api_start_time)                
                return jsonify({"msg": lmsg}), 400 
             reg_loc_id = city_json["reg_loc_id"]
             print("reg_loc_id = " + str(reg_loc_id))                              
      else:
          # If response code is not ok (200), print the resulting http error code with description
           lmsg="Some error occurred while checking the existence for State/County combination: " + state_name + "/" + county
           logger.error(concat_log_msg(route_id, lmsg))          
           response.raise_for_status()    
           log_api_completion_time(logger, route_id, api_start_time)           
           return jsonify({"msg": lmsg}), 400                  

      url = get_api_host + '/get_census_t_id'
      data = '{"state": "' + state_name + '", "county": "' + county + '", "census_t": ' + str(census_t) + '}' 
      response = call_ev_get_apis(url, data)
      # For successful API call, response code will be 200 (OK)
      if(response.ok):
          if response.text == "None":
             lmsg="State/County/Census Tract combination is not registered. Please register it first."
             logger.error(concat_log_msg(route_id, lmsg))
             return jsonify({"msg": lmsg}), 400
          else:
             ct_json = json.loads(response.text)
             if ct_json["census_t_id"] == "0":
                lmsg="State/County/Census Tract combination is not registered. Please register it first."
                logger.error(concat_log_msg(route_id, lmsg))
                return jsonify({"msg": lmsg}), 400 
             census_t_id = ct_json["census_t_id"]
             print("census_t_id = " + str(census_t_id))                              
      else:
          # If response code is not ok (200), print the resulting http error code with description
           lmsg="Some error occurred while checking the existence for State/County/Census Tract combination: " + state_name + "/" + county
           logger.error(concat_log_msg(route_id, lmsg))          
           response.raise_for_status()  
           log_api_completion_time(logger, route_id, api_start_time)
           return jsonify({"msg": lmsg}), 400   

      ####### END: Record and it's pre-req checks. ###################################      

      conn = get_db_conn(logger, route_id)
      cur = get_db_cursor(conn, logger, route_id)

      if action == 'create':
        lmsg="Creating registration for " + str(dol_veh_id)
        query = "insert into m.t_ev_regs values (default, '" + vin + "', " + str(dol_veh_id) + ", " + str(reg_loc_id) + ", " + str(model_id) + ", " + str(ev_type_id) + ", " + str(cavf_id) + ", " + str(ev_range) + "," + str(msrp) + ", " +  str(leg_dist) + ", '" + veh_location + "','" + el_utility + "'," + str(census_t_id) + ", current_timestamp, current_timestamp, current_user, current_user);"

      if action == 'update':
        lmsg="Updating registration for " + str(dol_veh_id)
        query = "update m.t_ev_regs set vin = '" + vin + "', id_reg_loc = " + str(reg_loc_id) + ", id_model = " + str(model_id) + ", id_ev_type = " + str(ev_type_id) + ", id_cavf = " + str(cavf_id) + ", ev_range = " + str(ev_range) + ", msrp = " + str(msrp) + ", leg_dist = " +  str(leg_dist) + ", veh_location_gps = '" + veh_location + "', el_utility = '" + el_utility + "', id_census_t = " + str(census_t_id) + ", reg_update_time = current_timestamp, reg_updated_by = current_user where dol_veh_id = " + str(dol_veh_id) + ";"

      cur=execute_write(conn, cur, logger, route_id, query)
      lmsg = "Created/Update registration for dol_veh_id = " + str(dol_veh_id)
      logger.info(concat_log_msg(route_id, lmsg))
      return jsonify({"msg": lmsg}), 200

      close_db_conn_cur(conn, cur, logger, route_id)
      log_api_completion_time(logger, route_id, api_start_time)

      return jsonify({"msg": msg}), 200

   except Exception as e:
      lmsg="create registration location api_error: " + repr(e)
      logger.error(concat_log_msg(route_id, lmsg))
      log_api_completion_time(logger, route_id, api_start_time)
      return jsonify({"error_code": 400, "msg": "Some issue happened. Please try again"}), 400        

@app.route("/delete_registration_by_dol_veh_id", methods=['DELETE'])
@requires_auth
def delete_registration_by_dol_veh_id():
      
   api_start_time=datetime.utcnow()   
   route_name="ev_api_delete_reg"
   route_id=generate_module_runtime_id(route_name)
   
   try:

      data = request.get_json()
      print(data)
      if not data:
          log_api_completion_time(logger, route_id, api_start_time) 
          return jsonify({"error": "No data received"}), 400
  
      dol_veh_id = data.get('dol_veh_id')    

      lmsg='Delete request for creating new registration'
      logger.info(concat_log_msg(route_id, lmsg))
      
      url = get_api_host + '/get_regs_by_dol_veh_id'      
      data = '{"dol_veh_id": ' + str(dol_veh_id) + '}'
      response = call_ev_get_apis(url, data)
      # For successful API call, response code will be 200 (OK)
      if(response.ok):
          if response.text == "None":
             lmsg="DOL registration does exist for " + str(dol_veh_id) + " . Nothing to update."
             logger.error(concat_log_msg(route_id, lmsg))
             log_api_completion_time(logger, route_id, api_start_time)                
             return jsonify({"msg": lmsg}), 400             
      else:
          # If response code is not ok (200), print the resulting http error code with description
           lmsg="Some error occurred while checking the existence of " + str(dol_veh_id)
           logger.error(concat_log_msg(route_id, lmsg))          
           response.raise_for_status()
           log_api_completion_time(logger, route_id, api_start_time)                 
           return jsonify({"msg": lmsg}), 400


      conn = get_db_conn(logger, route_id)
      cur = get_db_cursor(conn, logger, route_id)

      lmsg="Deleting registration for " + str(dol_veh_id)
      query = "delete from m.t_ev_regs where dol_veh_id = " + str(dol_veh_id) + ";"

      cur=execute_write(conn, cur, logger, route_id, query)
      lmsg = "Deleted registration for dol_veh_id = " + str(dol_veh_id)
      logger.info(concat_log_msg(route_id, lmsg))
      return jsonify({"msg": lmsg}), 200

      close_db_conn_cur(conn, cur, logger, route_id)
      log_api_completion_time(logger, route_id, api_start_time)

      return jsonify({"msg": msg}), 200

   except Exception as e:
      lmsg="delete registration location api_error: " + repr(e)
      logger.error(concat_log_msg(route_id, lmsg))
      log_api_completion_time(logger, route_id, api_start_time)
      return jsonify({"error_code": 400, "msg": "Some issue happened. Please try again"}), 400      

@app.route("/delete_state", methods=['DELETE'])
@requires_auth
def delete_state():
      
   api_start_time=datetime.utcnow()   
   route_name="ev_api_delete_reg"
   route_id=generate_module_runtime_id(route_name)
   
   try:

      data = request.get_json()
      print(data)
      if not data:
          log_api_completion_time(logger, route_id, api_start_time) 
          return jsonify({"error": "No data received"}), 400
  
      state = data.get('state')    

      lmsg='Deleting state: ' + state
      logger.info(concat_log_msg(route_id, lmsg))
      conn = get_db_conn(logger, route_id)
      cur = get_db_cursor(conn, logger, route_id)

      query = "delete from m.t_states where st = '" + state + "';"

      cur=execute_write(conn, cur, logger, route_id, query)
      lmsg='Deleted state: ' + state
      logger.info(concat_log_msg(route_id, lmsg))
      return jsonify({"msg": lmsg}), 200

      close_db_conn_cur(conn, cur, logger, route_id)
      log_api_completion_time(logger, route_id, api_start_time)

      return jsonify({"msg": msg}), 200

   except Exception as e:
      lmsg="delete registration location api_error: " + repr(e)
      logger.error(concat_log_msg(route_id, lmsg))
      log_api_completion_time(logger, route_id, api_start_time)
      return jsonify({"error_code": 400, "msg": "Some issue happened. Please try again"}), 400      

@app.route("/update_model", methods=['PUT'])
@requires_auth
def update_model():

   api_start_time=datetime.utcnow()   
   route_name="ev_api_update_unimplemented"
   route_id=generate_module_runtime_id(route_name)
   lmsg = 'Unimplemented API. Implementation very similar to other APIs in the same class..'
   log_api_completion_time(logger, route_id, api_start_time)
   return jsonify({"msg": lmsg}), 200

@app.route("/update_ev_type", methods=['PUT'])
@requires_auth
def update_ev_type():

   api_start_time=datetime.utcnow()   
   route_name="ev_api_update_unimplemented"
   route_id=generate_module_runtime_id(route_name)
   lmsg = 'Unimplemented API. Implementation very similar to other APIs in the same class..'
   log_api_completion_time(logger, route_id, api_start_time)
   return jsonify({"msg": lmsg}), 200

@app.route("/update_cavf", methods=['PUT'])
@requires_auth
def update_cavf():

   api_start_time=datetime.utcnow()   
   route_name="ev_api_update_unimplemented"
   route_id=generate_module_runtime_id(route_name)
   lmsg = 'Unimplemented API. Implementation very similar to other APIs in the same class..'
   log_api_completion_time(logger, route_id, api_start_time)
   return jsonify({"msg": lmsg}), 200

@app.route("/update_county_state", methods=['PUT'])
@requires_auth
def update_county_state():

   api_start_time=datetime.utcnow()   
   route_name="ev_api_update_unimplemented"
   route_id=generate_module_runtime_id(route_name)
   lmsg = 'Unimplemented API. Implementation very similar to other APIs in the same class..'
   log_api_completion_time(logger, route_id, api_start_time)
   return jsonify({"msg": lmsg}), 200   

@app.route("/update_reg_loc", methods=['PUT'])
@requires_auth
def update_reg_loc():

   api_start_time=datetime.utcnow()   
   route_name="ev_api_update_unimplemented"
   route_id=generate_module_runtime_id(route_name)
   lmsg = 'Unimplemented API. Implementation very similar to other APIs in the same class..'
   log_api_completion_time(logger, route_id, api_start_time)
   return jsonify({"msg": lmsg}), 200      

@app.route("/update_census_t", methods=['PUT'])
@requires_auth
def update_census_t():

   api_start_time=datetime.utcnow()   
   route_name="ev_api_update_unimplemented"
   route_id=generate_module_runtime_id(route_name)
   lmsg = 'Unimplemented API. Implementation very similar to other APIs in the same class..'
   log_api_completion_time(logger, route_id, api_start_time)
   return jsonify({"msg": lmsg}), 200       

@app.route("/delete_reg_loc", methods=['DELETE'])
@requires_auth
def delete_reg_loc():

   api_start_time=datetime.utcnow()   
   route_name="ev_api_delete_unimplemented"
   route_id=generate_module_runtime_id(route_name)
   lmsg = 'Unimplemented API. Implementation very similar to other APIs in the same class.. Assumption: All the foreign keys are already deleted.'
   log_api_completion_time(logger, route_id, api_start_time)
   return jsonify({"msg": lmsg}), 200  


@app.route("/delete_census_t", methods=['DELETE'])
@requires_auth
def delete_census_t():

   api_start_time=datetime.utcnow()   
   route_name="ev_api_delete_unimplemented"
   route_id=generate_module_runtime_id(route_name)
   lmsg = 'Unimplemented API. Implementation very similar to other APIs in the same class.. Assumption: All the foreign keys are already deleted.'
   log_api_completion_time(logger, route_id, api_start_time)
   return jsonify({"msg": lmsg}), 200  

@app.route("/delete_county", methods=['DELETE'])
@requires_auth
def delete_county():

   api_start_time=datetime.utcnow()   
   route_name="ev_api_delete_unimplemented"
   route_id=generate_module_runtime_id(route_name)
   lmsg = 'Unimplemented API. Implementation very similar to other APIs in the same class.. Assumption: All the foreign keys are already deleted.'
   log_api_completion_time(logger, route_id, api_start_time)
   return jsonify({"msg": lmsg}), 200    

@app.route("/delete_cavf", methods=['DELETE'])
@requires_auth
def delete_cavf():

   api_start_time=datetime.utcnow()   
   route_name="ev_api_delete_unimplemented"
   route_id=generate_module_runtime_id(route_name)
   lmsg = 'Unimplemented API. Implementation very similar to other APIs in the same class.. Assumption: All the foreign keys are already deleted.'
   log_api_completion_time(logger, route_id, api_start_time)
   return jsonify({"msg": lmsg}), 200    

@app.route("/delete_ev_type", methods=['DELETE'])
@requires_auth
def delete_ev_type():

   api_start_time=datetime.utcnow()   
   route_name="ev_api_delete_unimplemented"
   route_id=generate_module_runtime_id(route_name)
   lmsg = 'Unimplemented API. Implementation very similar to other APIs in the same class.. Assumption: All the foreign keys are already deleted.'
   log_api_completion_time(logger, route_id, api_start_time)
   return jsonify({"msg": lmsg}), 200 

@app.route("/delete_model", methods=['DELETE'])
@requires_auth
def delete_model():

   api_start_time=datetime.utcnow()   
   route_name="ev_api_delete_unimplemented"
   route_id=generate_module_runtime_id(route_name)
   lmsg = 'Unimplemented API. Implementation very similar to other APIs in the same class.. Assumption: All the foreign keys are already deleted.'
   log_api_completion_time(logger, route_id, api_start_time)
   return jsonify({"msg": lmsg}), 200       

app.run(debug=True, host='0.0.0.0', port=5002)
