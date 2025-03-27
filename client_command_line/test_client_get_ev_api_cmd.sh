get_api_host=$1
api_user="admin"
api_pass="secret"

tr_file=/tmp/ev_api_get_test_out.txt

echo "" > $tr_file

echo "##############################  START: Testing EV read API services ##############################" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Get Valid State ++++++++++++++++++++++++     " >> $tr_file
curl -X GET -H "Content-Type: application/json" -u $api_user:$api_pass -d '{"state": "AZ"}' $get_api_host"/get_state_id" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Get Invalid State ++++++++++++++++++++++++     " >> $tr_file
curl -X GET -H "Content-Type: application/json" -u $api_user:$api_pass -d '{"state": "NO"}' $get_api_host"/get_state_id" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Get Valid cavf ++++++++++++++++++++++++     " >> $tr_file
curl -X GET -H "Content-Type: application/json" -u $api_user:$api_pass -d '{"cavf": "Clean Alternative Fuel Vehicle Eligible"}' $get_api_host"/get_cavf_id" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Get Invalid cavf ++++++++++++++++++++++++     " >> $tr_file
curl -X GET -H "Content-Type: application/json" -u $api_user:$api_pass -d '{"cavf": "NClean Alternative Fuel Vehicle EligibleO"}' $get_api_host"/get_cavf_id" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Get Valid ev_type ++++++++++++++++++++++++     " >> $tr_file
curl -X GET -H "Content-Type: application/json" -u $api_user:$api_pass -d '{"ev_type": "Plug-in Hybrid Electric Vehicle (PHEV)"}' $get_api_host"/get_ev_type_id" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Get Invalid ev_type ++++++++++++++++++++++++     " >> $tr_file
curl -X GET -H "Content-Type: application/json" -u $api_user:$api_pass -d '{"ev_type": "Plug-in Hybrid Electric Vehicle"}' $get_api_host"/get_ev_type_id" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Get Valid model ++++++++++++++++++++++++     " >> $tr_file
curl -X GET -H "Content-Type: application/json" -u $api_user:$api_pass -d '{"m_year": 2024, "model": "ZDX", "make": "ACURA"}'  $get_api_host"/get_model_id" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Get Invalid model ++++++++++++++++++++++++     " >> $tr_file
curl -X GET -H "Content-Type: application/json" -u $api_user:$api_pass -d '{"m_year": 2024, "model": "ZDX", "make": "YACURAX"}'  $get_api_host"/get_model_id" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Get Valid county ++++++++++++++++++++++++     " >> $tr_file
curl -X GET -H "Content-Type: application/json" -u $api_user:$api_pass -d '{"state": "CA", "county": "Placer"}'   $get_api_host"/get_county_id" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Get Invalid county ++++++++++++++++++++++++     " >> $tr_file
curl -X GET -H "Content-Type: application/json" -u $api_user:$api_pass -d '{"state": "CA", "county": "Placer9"}'   $get_api_host"/get_county_id" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Get Valid Registry Location ++++++++++++++++++++++++     " >> $tr_file
curl -X GET -H "Content-Type: application/json" -u $api_user:$api_pass -d  '{"state": "WA", "county": "King", "city": "Issaquah", "zip": 98027}'  $get_api_host"/get_reg_loc_id" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Get Invalid  Registry Location ++++++++++++++++++++++++     " >> $tr_file
curl -X GET -H "Content-Type: application/json" -u $api_user:$api_pass -d  '{"state": "WA", "county": "King", "city": "Issaquah", "zip": 98227}'  $get_api_host"/get_reg_loc_id" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Get Registration by Valid VIN Number ++++++++++++++++++++++++     " >> $tr_file
curl -X GET -H "Content-Type: application/json" -u $api_user:$api_pass -d  '{"vin": "WA125BGF3S"}' $get_api_host"/get_regs_by_vin" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Get Registration by Invalid VIN Number ++++++++++++++++++++++++     " >> $tr_file
curl -X GET -H "Content-Type: application/json" -u $api_user:$api_pass -d  '{"vin": "WA125BGF2T"}' $get_api_host"/get_regs_by_vin" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Get Registration by Valid DOL Vehicle Id ++++++++++++++++++++++++     " >> $tr_file
curl -X GET -H "Content-Type: application/json" -u $api_user:$api_pass -d  '{"dol_veh_id": 933575393}'  $get_api_host"/get_regs_by_dol_veh_id" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Get Registration by Invalid VIN Number ++++++++++++++++++++++++     " >> $tr_file
curl -X GET -H "Content-Type: application/json" -u $api_user:$api_pass -d '{"dol_veh_id": 233575398}'  $get_api_host"/get_regs_by_dol_veh_id" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Get 5 registrations ++++++++++++++++++++++++     " >> $tr_file
curl -X GET -H "Content-Type: application/json" -u $api_user:$api_pass -d '{"max_count": 15}' $get_api_host"/get_all_regs" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Get All States ++++++++++++++++++++++++     " >> $tr_file
curl -X GET -H "Content-Type: application/json" -u $api_user:$api_pass $get_api_host"/get_all_states" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Get All Counties ++++++++++++++++++++++++     " >> $tr_file
curl -X GET -H "Content-Type: application/json" -u $api_user:$api_pass $get_api_host"/get_all_counties" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Get All CAVF ++++++++++++++++++++++++     " >> $tr_file
curl -X GET -H "Content-Type: application/json" -u $api_user:$api_pass $get_api_host"/get_all_cavf" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Get All EV Types ++++++++++++++++++++++++     " >> $tr_file
curl -X GET -H "Content-Type: application/json" -u $api_user:$api_pass $get_api_host"/get_all_ev_types" >> $tr_file

echo "##############################  END: Testing EV read API services ##############################" >> $tr_file
