#############################################################################################
# Author                Date            Version         Change
# Anurag Shrivastava    03/24/2025      1.0             General utility helper module.
#
#############################################################################################

from datetime import datetime
from datetime import date
import sys
from log_helper import *

def generate_module_runtime_id(comp_name):
    """
    Generate and return unique module_runtime_id for the module
    """
    
    ts = datetime.now().strftime('%Y%m%d-%H%M%S%f')[:-3]
    today = date.today()
  
    module_runtime_id = comp_name + "-" + str(ts)
    return module_runtime_id 

def log_api_completion_time(logger, route_id, api_start_time):
   api_end_time=datetime.utcnow()
   api_duration=api_end_time - api_start_time
   lmsg="api_duration: " + str(api_duration)
   logger.info(concat_log_msg(route_id, lmsg))
   file_path = "/tmp/telemetry_ev_get_apis.txt"
   file = open(file_path, "a")   
   file.write(route_id + "|" + str(api_start_time) + "|" + str(api_end_time) + "|" + str(api_duration) + "\n")
   file.close()

def unimplemented_get_api_msg():
    return '{"msg": "API to be implented. Output will be something similar as hitting http://127.0.0.1:5001/get_all_states"}'    
