#############################################################################################
# Author                Date            Version         Change
# Anurag Shrivastava    03/24/2025      1.0             EV Registration Read APIs
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

#### IMPLEMENTED #######################
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

#### NOT IMPLEMENTED DUE TO TIME CONSTRAINTS. IMPLEMENTATION PATTERN WOULD BE EXACTLY SAME AS THE ONES IMPLEMENTED. #######################
# @app.route("/get_all_counties", methods=['GET'])
# @app.route("/get_all_cities", methods=['GET'])
# @app.route("/get_all_zips", methods=['GET'])


from flask import Flask, request, jsonify, Response
from functools import wraps
import sys
import datetime

sys.path.append("/app/containers/ev-apis/util")
sys.path.append("/app/containers/ev-apis/config")
from db_helper import *
from general_helper import *
from log_helper import *
from api_auth_helper import *
from autopylogger import init_logging


# Logger utility. Supports auto-rotate, loglevels and formats. Helps build unified logging structure for all APIs.
logger = init_logging(log_name='ev_apis_logs', log_directory="/tmp", console_log=True, log_level='DEBUG', log_format='[%(asctime)s]|%(levelname)s|%(filename)s|%(funcName)s|Line: %(lineno)d|%(message)s')

route_name=""

app = Flask(__name__)

@app.route("/", methods=['GET'])
@requires_auth
def get_welome():
   return "Welcome to EV GET API Page"

# Route contoller for the service
@app.route("/get_state_id", methods=['GET'])
# Handling API Authentication
@requires_auth
# Handling API Call
def get_state():

   # Record Start time of the API for telemetory collection later.
   api_start_time=datetime.utcnow()   
   # Unique route id being generated for each API run. This is also passed later to the database functions as a param called run_id.
   # Helps understand the end to end API performance including the API and database for each call.
   route_name="ev_api_get_state_id"
   route_id=generate_module_runtime_id(route_name)

   try:
      # Getting JSON data from the client call.
      data = request.get_json()
      if not data:
          return jsonify({"error": "No data received"}), 400
  
      state_name = data.get('state')

      # Logging info
      lmsg='Get request for state id.'
      logger.info(concat_log_msg(route_id, lmsg))

      # Database connection from DB Helper
      conn = get_db_conn(logger, route_id)
      cur = get_db_cursor(conn, logger, route_id)

      # Calling pre-compiled database function and passing state id and route id.
      cur=execute_select(conn, cur, logger, route_id, "SELECT m.fn_get_state_id('" + state_name + "', '" + route_id + "')")
      rows = cur.fetchall()
      for data in rows:
          state_id = str(data[0])

      # Close DB connection
      close_db_conn_cur(conn, cur, logger, route_id)
      
      # Record end time of the API for telemetory collection into a file to be later processed by a batch telemetory job.
      log_api_completion_time(logger, route_id, api_start_time)

      # Return the 200 response.
      return jsonify({"state_id": state_id}), 200
   except Exception as e:
      
      # Log and return error response.
      lmsg="get state api_error: " + repr(e)
      logger.error(concat_log_msg(route_id, lmsg))
      log_api_completion_time(logger, route_id, api_start_time)
      return jsonify({"error_code": 400, "msg": "Some issue happened. Please try again"}), 400

@app.route("/get_cavf_id", methods=['GET'])
@requires_auth
def get_cavf():
   
   api_start_time=datetime.utcnow()   
   route_name="ev_api_get_cavf_id"
   route_id=generate_module_runtime_id(route_name)

   try:
      data = request.get_json()
      if not data:
          return jsonify({"error": "No data received"}), 400

      cavf = data.get('cavf')

      lmsg='Get request for cavf id.'
      logger.info(concat_log_msg(route_id, lmsg))
      conn = get_db_conn(logger, route_id)
      cur = get_db_cursor(conn, logger, route_id)
      query = "SELECT m.fn_get_cavf_id('" + cavf + "', '" + route_id + "')"
      cur=execute_select(conn, cur, logger, route_id, query)

      rows = cur.fetchall()
      for data in rows:
          cavf_id = str(data[0])

      close_db_conn_cur(conn, cur, logger, route_id)
      log_api_completion_time(logger, route_id, api_start_time)

      return jsonify({"cavf_id": cavf_id}), 200

   except Exception as e:
      lmsg="get cavf api_error: " + repr(e)
      logger.error(concat_log_msg(route_id, lmsg))
      log_api_completion_time(logger, route_id, api_start_time)
      return jsonify({"error_code": 400, "msg": "Some issue happened. Please try again."}), 400

@app.route("/get_ev_type_id", methods=['GET'])
@requires_auth
def get_ev_type():

   api_start_time=datetime.utcnow()   
   route_name="ev_api_get_ev_type_id"
   route_id=generate_module_runtime_id(route_name)

   try:
      data = request.get_json()
      if not data:
          return jsonify({"error": "No data received"}), 400

      ev_type = data.get('ev_type')

      lmsg='Get request for ev_type id.'
      logger.info(concat_log_msg(route_id, lmsg))
      conn = get_db_conn(logger, route_id)
      cur = get_db_cursor(conn, logger, route_id)
      query = "SELECT m.fn_get_ev_type_id('" + ev_type + "', '" + route_id + "')"
      cur=execute_select(conn, cur, logger, route_id, query)

      rows = cur.fetchall()
      for data in rows:
          ev_type_id = str(data[0])

      close_db_conn_cur(conn, cur, logger, route_id)
      log_api_completion_time(logger, route_id, api_start_time)
      return jsonify({"ev_type_id": ev_type_id}), 200

   except Exception as e:
      lmsg="get ev_type api_error: " + repr(e)
      logger.error(concat_log_msg(route_id, lmsg))
      log_api_completion_time(logger, route_id, api_start_time)
      return jsonify({"error_code": 400, "msg": "Some issue happened. Please try again."}), 400

@app.route("/get_model_id", methods=['GET'])
@requires_auth
def get_model():
   
   api_start_time=datetime.utcnow()   
   route_name="ev_api_get_model_id"
   route_id=generate_module_runtime_id(route_name)

   try:
      data = request.get_json()
      if not data:
          return jsonify({"error": "No data received"}), 400

      m_year = data.get('m_year')
      model = data.get('model')
      make = data.get('make')

      lmsg='Get request for model id.'
      logger.info(concat_log_msg(route_id, lmsg))
      conn = get_db_conn(logger, route_id)
      cur = get_db_cursor(conn, logger, route_id)
      query = "SELECT m.fn_get_model_id(" + str(m_year) + ", '" + make + "', '" + model + "', '" + route_id + "')"
      cur=execute_select(conn, cur, logger, route_id, query)
      rows = cur.fetchall()
      for data in rows:
          model_id = str(data[0])

      close_db_conn_cur(conn, cur, logger, route_id)
      log_api_completion_time(logger, route_id, api_start_time)
      return jsonify({"model_id": model_id}), 200

   except Exception as e:
      lmsg="get model api_error: " + repr(e)
      logger.error(concat_log_msg(route_id, lmsg))
      log_api_completion_time(logger, route_id, api_start_time)
      return jsonify({"error_code": 400, "msg": "Some issue happened. Please try again."}), 400

@app.route("/get_county_id", methods=['GET'])
@requires_auth
def get_county():

   api_start_time=datetime.utcnow()   
   route_name="ev_api_get_county_id"
   route_id=generate_module_runtime_id(route_name)

   try:
      data = request.get_json()
      if not data:
          return jsonify({"error": "No data received"}), 400

      county = data.get('county')
      state = data.get('state')

      county_id = 0

      lmsg='Get request for county id.'
      logger.info(concat_log_msg(route_id, lmsg))
      conn = get_db_conn(logger, route_id)
      cur = get_db_cursor(conn, logger, route_id)

      query = "SELECT m.fn_get_state_id('" + state + "', '" + route_id + "')"
      cur=execute_select(conn, cur, logger, route_id, query)
      rows = cur.fetchall()
      for data in rows:
          state_id = str(data[0])

      if state_id is None:
         log_api_completion_time(logger, route_id, api_start_time)
         return jsonify({"county_id": 0, "msg": "The state is not registered. Please register it first."}), 400

      cur=execute_select(conn, cur, logger, route_id, "SELECT m.fn_get_county_id_for_state('" + state + "', '" + county + "', '" + route_id + "')")
      rows = cur.fetchall()
      for data in rows:
          county_id = str(data[0])

      close_db_conn_cur(conn, cur, logger, route_id)
      
      if int(county_id) == 0:
         log_api_completion_time(logger, route_id, api_start_time)
         return jsonify({"county_id": county_id, "msg": "The state and county combination is not registered. Please register it first."}), 400

      log_api_completion_time(logger, route_id, api_start_time)

      return jsonify({"county_id": county_id}), 200

   except Exception as e:
      lmsg="get county api_error: " + repr(e)
      logger.error(concat_log_msg(route_id, lmsg))
      log_api_completion_time(logger, route_id, api_start_time)
      return jsonify({"error_code": 400, "msg": "Some issue happened. Please try again."}), 400

@app.route("/get_reg_loc_id", methods=['GET'])
@requires_auth
def get_reg_loc():

   api_start_time=datetime.utcnow()   
   route_name="ev_api_get_reg_loc_id"
   route_id=generate_module_runtime_id(route_name)

   try:
      data = request.get_json()
      if not data:
          return jsonify({"error": "No data received"}), 400

      county = data.get('county')
      state = data.get('state')
      city = data.get('city')
      zip = data.get('zip')

      reg_loc_id = 0

      lmsg='Get request for reg_loc id.'
      logger.info(concat_log_msg(route_id, lmsg))
      conn = get_db_conn(logger, route_id)
      cur = get_db_cursor(conn, logger, route_id)

      query = "SELECT m.fn_get_state_id('" + state + "', '" + route_id + "')"
      cur=execute_select(conn, cur, logger, route_id, query)
      rows = cur.fetchall()
      for data in rows:
          state_id = str(data[0])

      if state_id is None:
         log_api_completion_time(logger, route_id, api_start_time)
         return jsonify({"reg_loc_id": 0, "msg": "The state is not registered. Please register it first."}), 400
      query = "SELECT m.fn_get_county_id_for_state('" + state + "', '" + county + "', '" + route_id + "')"
      cur=execute_select(conn, cur, logger, route_id, query)
      rows = cur.fetchall()
      for data in rows:
          county_id = str(data[0])

      if int(county_id) == 0:
         log_api_completion_time(logger, route_id, api_start_time)
         return jsonify({"reg_loc_id": 0, "msg": "The state and county combination is not registered. Please register it first."}), 400
      
      query = "SELECT m.fn_get_reg_loc_id('" + state + "', '" + county + "', '" + city + "', " + str(zip) + ", '" + route_id + "')"
      cur=execute_select(conn, cur, logger, route_id, query)
      rows = cur.fetchall()
      for data in rows:
          reg_loc_id = str(data[0])

      close_db_conn_cur(conn, cur, logger, route_id)

      if int(reg_loc_id) == 0:
         log_api_completion_time(logger, route_id, api_start_time)
         return jsonify({"reg_loc_id": 0, "msg": "The state, county, city and zip combination is not registered. Please register it first."}), 400      

      log_api_completion_time(logger, route_id, api_start_time)

      return jsonify({"reg_loc_id": reg_loc_id}), 200

   except Exception as e:
      lmsg="get reg_loc api_error: " + repr(e)
      logger.error(concat_log_msg(route_id, lmsg))
      log_api_completion_time(logger, route_id, api_start_time)
      return jsonify({"error_code": 400, "msg": "Some issue happened. Please try again."}), 400

@app.route("/get_census_t_id", methods=['GET'])
@requires_auth
def get_census_t():

   api_start_time=datetime.utcnow()   
   route_name="ev_api_get_census_t_id"
   route_id=generate_module_runtime_id(route_name)

   try:
      data = request.get_json()
      if not data:
          return jsonify({"error": "No data received"}), 400

      county = data.get('county')
      state = data.get('state')
      census_t = data.get('census_t')

      census_t_id = 0

      lmsg='Get request for census_t id.'
      logger.info(concat_log_msg(route_id, lmsg))
      conn = get_db_conn(logger, route_id)
      cur = get_db_cursor(conn, logger, route_id)
      
      query = "SELECT m.fn_get_state_id('" + state + "', '" + route_id + "')"
      cur=execute_select(conn, cur, logger, route_id, query)
      rows = cur.fetchall()
      for data in rows:
          state_id = str(data[0])

      if state_id is None:
         log_api_completion_time(logger, route_id, api_start_time)
         return jsonify({"census_t_id": 0, "msg": "The state is not registered. Please register it first."}), 400
      
      query = "SELECT m.fn_get_county_id_for_state('" + state + "', '" + county + "', '" + route_id + "')"
      cur=execute_select(conn, cur, logger, route_id, query)
      rows = cur.fetchall()
      for data in rows:
          county_id = str(data[0])

      if int(county_id) == 0:
         log_api_completion_time(logger, route_id, api_start_time)
         return jsonify({"census_t_id": 0, "msg": "The state and county combination is not registered. Please register it first."}), 400
      
      query = "SELECT m.fn_get_census_t_id('" + state + "', '" + county + "', " + str(census_t) + ", '" + route_id + "')"
      cur=execute_select(conn, cur, logger, route_id, query)
      rows = cur.fetchall()
      for data in rows:
          census_t_id = str(data[0])

      close_db_conn_cur(conn, cur, logger, route_id)

      if int(census_t_id) == 0:
         log_api_completion_time(logger, route_id, api_start_time)
         return jsonify({"census_t_id": 0, "msg": "The state, county and census_t_id combination is not registered. Please register it first."}), 400      

      log_api_completion_time(logger, route_id, api_start_time)

      return jsonify({"census_t_id": census_t_id}), 200

   except Exception as e:
      lmsg="get census_t api_error: " + repr(e)
      logger.error(concat_log_msg(route_id, lmsg))
      log_api_completion_time(logger, route_id, api_start_time)
      return jsonify({"error_code": 400, "msg": "Some issue happened. Please try again."}), 400


@app.route("/get_regs_by_vin", methods=['GET'])
@requires_auth
def get_regs_by_vin():

   api_start_time=datetime.utcnow()   
   route_name="ev_api_get_regs_by_vin"
   route_id=generate_module_runtime_id(route_name)

   try:
      data = request.get_json()
      if not data:
          return jsonify({"error": "No data received"}), 400
  
      vin = data.get('vin').upper()

      lmsg='Get request for registrations by vin'
      logger.info(concat_log_msg(route_id, lmsg))
      conn = get_db_conn(logger, route_id)
      cur = get_db_cursor(conn, logger, route_id)
      query = "SELECT m.fn_get_regs_by_vin('" + vin + "', '" + route_id + "')"
      cur=execute_select(conn, cur, logger, route_id, query)
      rows = cur.fetchall()
      for data in rows:
          vin_details = str(data[0])

      close_db_conn_cur(conn, cur, logger, route_id)
      log_api_completion_time(logger, route_id, api_start_time)
      return vin_details, 200

   except Exception as e:
      lmsg="get state api_error: " + repr(e)
      logger.error(concat_log_msg(route_id, lmsg))
      log_api_completion_time(logger, route_id, api_start_time)
      return jsonify({"error_code": 400, "msg": "Some issue happened. Please try again"}), 400

@app.route("/get_regs_by_dol_veh_id", methods=['GET'])
@requires_auth
def get_regs_by_dol_veh_id():

   api_start_time=datetime.utcnow()   
   route_name="ev_api_get_regs_by_dol_veh_id"
   route_id=generate_module_runtime_id(route_name)

   try:
      data = request.get_json()
      if not data:
          return jsonify({"error": "No data received"}), 400
  
      dol_veh_id = data.get('dol_veh_id')

      lmsg='Get request for registrations by dol_veh_id'
      logger.info(concat_log_msg(route_id, lmsg))
      conn = get_db_conn(logger, route_id)
      cur = get_db_cursor(conn, logger, route_id)
      query = "SELECT m.fn_get_regs_by_dol_veh_id(" + str(dol_veh_id) + ", '" + route_id + "')"

      cur=execute_select(conn, cur, logger, route_id, query)
      rows = cur.fetchall()
      for data in rows:
          dol_veh_id_details = str(data[0])       

      close_db_conn_cur(conn, cur, logger, route_id)
      log_api_completion_time(logger, route_id, api_start_time)
      return dol_veh_id_details, 200

   except Exception as e:
      lmsg="get regisrations error api_error: " + repr(e)
      logger.error(concat_log_msg(route_id, lmsg))
      log_api_completion_time(logger, route_id, api_start_time)
      return jsonify({"error_code": 400, "msg": "Some issue happened. Please try again"}), 400

@app.route("/get_all_models", methods=['GET'])
@requires_auth
def get_all_models():

   api_start_time=datetime.utcnow()   
   route_name="ev_api_get_all_models"
   route_id=generate_module_runtime_id(route_name)

   try:

      lmsg='Get request for all models'
      logger.info(concat_log_msg(route_id, lmsg))
      conn = get_db_conn(logger, route_id)
      cur = get_db_cursor(conn, logger, route_id)
      query = "SELECT m.fn_get_all_models('" + route_id + "')"

      cur=execute_select(conn, cur, logger, route_id, query)
      rows = cur.fetchall()
      for data in rows:
          models = str(data[0])

      close_db_conn_cur(conn, cur, logger, route_id)
      log_api_completion_time(logger, route_id, api_start_time)
      return models, 200

   except Exception as e:
      lmsg="get all models api_error: " + repr(e)
      logger.error(concat_log_msg(route_id, lmsg))
      log_api_completion_time(logger, route_id, api_start_time)
      return jsonify({"error_code": 400, "msg": "Some issue happened. Please try again"}), 400

@app.route("/get_all_ev_types", methods=['GET'])
@requires_auth
def get_all_ev_types():

   api_start_time=datetime.utcnow()   
   route_name="ev_api_get_all_ev_types"
   route_id=generate_module_runtime_id(route_name)

   try:

      lmsg='Get request for all ev_types'
      logger.info(concat_log_msg(route_id, lmsg))
      conn = get_db_conn(logger, route_id)
      cur = get_db_cursor(conn, logger, route_id)
      query = "SELECT m.fn_get_all_ev_types('" + route_id + "')"

      cur=execute_select(conn, cur, logger, route_id, query)
      rows = cur.fetchall()
      for data in rows:
          ev_types = str(data[0])

      close_db_conn_cur(conn, cur, logger, route_id)
      log_api_completion_time(logger, route_id, api_start_time)
      return ev_types, 200

   except Exception as e:
      lmsg="get all ev_types api_error: " + repr(e)
      logger.error(concat_log_msg(route_id, lmsg))
      log_api_completion_time(logger, route_id, api_start_time)
      return jsonify({"error_code": 400, "msg": "Some issue happened. Please try again"}), 400

@app.route("/get_all_cavf", methods=['GET'])
@requires_auth
def get_all_cavf():

   api_start_time=datetime.utcnow()   
   route_name="ev_api_get_all_cavf"
   route_id=generate_module_runtime_id(route_name)

   try:

      lmsg='Get request for all cavf'
      logger.info(concat_log_msg(route_id, lmsg))
      conn = get_db_conn(logger, route_id)
      cur = get_db_cursor(conn, logger, route_id)
      query = "SELECT m.fn_get_all_cavf('" + route_id + "')"

      cur=execute_select(conn, cur, logger, route_id, query)
      rows = cur.fetchall()
      for data in rows:
          cavf = str(data[0])

      close_db_conn_cur(conn, cur, logger, route_id)
      log_api_completion_time(logger, route_id, api_start_time)
      return cavf, 200

   except Exception as e:
      lmsg="get all cavf api_error: " + repr(e)
      logger.error(concat_log_msg(route_id, lmsg))
      log_api_completion_time(logger, route_id, api_start_time)
      return jsonify({"error_code": 400, "msg": "Some issue happened. Please try again"}), 400

@app.route("/get_all_states", methods=['GET'])
@requires_auth
def get_all_states():

   api_start_time=datetime.utcnow()   
   route_name="ev_api_get_all_states"
   route_id=generate_module_runtime_id(route_name)

   try:

      lmsg='Get request for all states'
      logger.info(concat_log_msg(route_id, lmsg))
      conn = get_db_conn(logger, route_id)
      cur = get_db_cursor(conn, logger, route_id)
      query = "SELECT m.fn_get_all_states('" + route_id + "')"

      cur=execute_select(conn, cur, logger, route_id, query)
      rows = cur.fetchall()
      for data in rows:
          cavf = str(data[0])

      close_db_conn_cur(conn, cur, logger, route_id)
      log_api_completion_time(logger, route_id, api_start_time)
      return cavf, 200

   except Exception as e:
      lmsg="get all states api_error: " + repr(e)
      logger.error(concat_log_msg(route_id, lmsg))
      log_api_completion_time(logger, route_id, api_start_time)
      return jsonify({"error_code": 400, "msg": "Some issue happened. Please try again"}), 400

@app.route("/get_all_regs", methods=['GET'])
@requires_auth
def get_all_regs():

   api_start_time=datetime.utcnow()   
   route_name="ev_api_get_all_regs"
   route_id=generate_module_runtime_id(route_name)

   try:


      data = request.get_json()
      if not data:
          return jsonify({"error": "No data received"}), 400
  
      max_count = data.get('max_count')

      lmsg='Get request for all registrations'
      logger.info(concat_log_msg(route_id, lmsg))
      conn = get_db_conn(logger, route_id)
      cur = get_db_cursor(conn, logger, route_id)
      query = "SELECT m.fn_get_all_regs(" + str(max_count) + ", '" + route_id + "')"

      cur=execute_select(conn, cur, logger, route_id, query)
      rows = cur.fetchall()
      for data in rows:
          regs = str(data[0])

      close_db_conn_cur(conn, cur, logger, route_id)
      log_api_completion_time(logger, route_id, api_start_time)
      return regs, 200

   except Exception as e:
      lmsg="get all registrations api_error: " + repr(e)
      logger.error(concat_log_msg(route_id, lmsg))
      log_api_completion_time(logger, route_id, api_start_time)
      return jsonify({"error_code": 400, "msg": "Some issue happened. Please try again"}), 400

@app.route("/get_all_counties", methods=['GET'])
@requires_auth
def get_all_counties():

   api_start_time=datetime.utcnow()   
   route_name="ev_api_get_all_counties"
   route_id=generate_module_runtime_id(route_name)
   log_api_completion_time(logger, route_id, api_start_time)
   return unimplemented_get_api_msg(), 200

@app.route("/get_all_cities", methods=['GET'])
@requires_auth
def get_all_cities():

   api_start_time=datetime.utcnow()   
   route_name="ev_api_get_all_cities"
   route_id=generate_module_runtime_id(route_name)
   log_api_completion_time(logger, route_id, api_start_time)
   return unimplemented_get_api_msg(), 200

@app.route("/get_all_zips", methods=['GET'])
@requires_auth
def get_all_zips():

   api_start_time=datetime.utcnow()   
   route_name="ev_api_get_all_zips"
   route_id=generate_module_runtime_id(route_name)
   log_api_completion_time(logger, route_id, api_start_time)
   return unimplemented_get_api_msg(), 200      

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5001)
