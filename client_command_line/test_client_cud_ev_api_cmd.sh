get_api_host=$1
cud_api_host=$2
api_user="admin"
api_pass="secret"

tr_file=/tmp/ev_api_cud_test_out.txt

echo "" > $tr_file

echo "##############################  START: Testing EV create/update/delete API services ##############################" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Creating a new state: AI  ++++++++++++++++++++++++     " >> $tr_file
curl -X POST -H "Content-Type: application/json" -u $api_user:$api_pass -d '{"state": "AI"}' $cud_api_host"/create_state" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Get Newly Created State: AI ++++++++++++++++++++++++     " >> $tr_file
curl -X GET -H "Content-Type: application/json" -u $api_user:$api_pass -d '{"state": "AI"}' $get_api_host"/get_state_id" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Recreating a new state: AI  ++++++++++++++++++++++++     " >> $tr_file
curl -X POST -H "Content-Type: application/json" -u $api_user:$api_pass -d '{"state": "AI"}' $cud_api_host"/create_state" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Deleting the new state: AI  ++++++++++++++++++++++++     " >> $tr_file
curl -X DELETE -H "Content-Type: application/json" -u $api_user:$api_pass -d '{"state": "AI"}' $cud_api_host"/delete_state" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Just Deleted State: AI ++++++++++++++++++++++++     " >> $tr_file
curl -X GET -H "Content-Type: application/json" -u $api_user:$api_pass -d '{"state": "AI"}' $get_api_host"/get_state_id" >> $tr_file

echo "" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Creating a new cavf: CAVF10  ++++++++++++++++++++++++     " >> $tr_file
curl -X POST -H "Content-Type: application/json" -u $api_user:$api_pass -d '{"cavf": "CAVF10"}' $cud_api_host"/create_cavf" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Get Newly Created cavf: CAVF10 ++++++++++++++++++++++++     " >> $tr_file
curl -X GET -H "Content-Type: application/json" -u $api_user:$api_pass -d '{"cavf": "CAVF10"}' $get_api_host"/get_cavf_id" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Recreating a new cavf: CAVF10  ++++++++++++++++++++++++     " >> $tr_file
curl -X POST -H "Content-Type: application/json" -u $api_user:$api_pass -d '{"cavf": "CAVF10"}' $cud_api_host"/create_cavf" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Deleting the new cavf: CAVF10  ++++++++++++++++++++++++     " >> $tr_file
curl -X DELETE -H "Content-Type: application/json" -u $api_user:$api_pass -d '{"cavf": "CAVF10"}' $cud_api_host"/delete_cavf" >> $tr_file

echo "" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Creating a new ev_type: ev_type10  ++++++++++++++++++++++++     " >> $tr_file
curl -X POST -H "Content-Type: application/json" -u $api_user:$api_pass -d '{"ev_type": "ev_type10"}' $cud_api_host"/create_ev_type" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Get Newly Created ev_type: ev_type10 ++++++++++++++++++++++++     " >> $tr_file
curl -X GET -H "Content-Type: application/json" -u $api_user:$api_pass -d '{"ev_type": "ev_type10"}' $get_api_host"/get_ev_type_id" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Recreating a new ev_type: ev_type10  ++++++++++++++++++++++++     " >> $tr_file
curl -X POST -H "Content-Type: application/json" -u $api_user:$api_pass -d '{"ev_type": "ev_type10"}' $cud_api_host"/create_ev_type" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Deleting the new ev_type: ev_type10  ++++++++++++++++++++++++     " >> $tr_file
curl -X DELETE -H "Content-Type: application/json" -u $api_user:$api_pass -d '{"ev_type": "ev_type10"}' $cud_api_host"/delete_ev_type" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Creating a new model  ++++++++++++++++++++++++     " >> $tr_file
curl -X POST -H "Content-Type: application/json" -u $api_user:$api_pass -d '{"make": "ACURA", "model": "model1", "m_year": 2026}' $cud_api_host"/create_model" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Get Newly Created model ++++++++++++++++++++++++     " >> $tr_file
curl -X GET -H "Content-Type: application/json" -u $api_user:$api_pass -d '{"make": "ACURA", "model": "model1", "m_year": 2026}' $get_api_host"/get_model_id" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Recreating a new model  ++++++++++++++++++++++++     " >> $tr_file
curl -X POST -H "Content-Type: application/json" -u $api_user:$api_pass -d '{"make": "ACURA", "model": "model1", "m_year": 2026}' $cud_api_host"/create_model" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Deleting the new model  ++++++++++++++++++++++++     " >> $tr_file
curl -X DELETE -H "Content-Type: application/json" -u $api_user:$api_pass -d '{"make": "ACURA", "model": "model1", "m_year": 2026}' $cud_api_host"/delete_model" >> $tr_file

echo "" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Creating a new census_t  ++++++++++++++++++++++++     " >> $tr_file
curl -X POST -H "Content-Type: application/json" -u $api_user:$api_pass -d '{"state": "ca","county": "Placer", "census_t": 20251123}' $cud_api_host"/create_census_t" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Get Newly Created census_t ++++++++++++++++++++++++     " >> $tr_file
curl -X GET -H "Content-Type: application/json" -u $api_user:$api_pass -d '{"state": "ca","county": "Placer", "census_t": 20251123}' $get_api_host"/get_census_t_id" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Recreating a new census_t  ++++++++++++++++++++++++     " >> $tr_file
curl -X POST -H "Content-Type: application/json" -u $api_user:$api_pass -d '{"state": "ca","county": "Placer", "census_t": 20251123}' $cud_api_host"/create_census_t" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Deleting the new census_t  ++++++++++++++++++++++++     " >> $tr_file
curl -X DELETE -H "Content-Type: application/json" -u $api_user:$api_pass -d '{"state": "ca","county": "Placer", "census_t": 20251123}' $cud_api_host"/delete_census_t" >> $tr_file

echo "" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Creating a new reg_loc  ++++++++++++++++++++++++     " >> $tr_file
curl -X POST -H "Content-Type: application/json" -u $api_user:$api_pass -d  '{"state": "ca","county": "Placer", "city": "Lincoln10", "zip": 95648}'  $cud_api_host"/create_reg_loc" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Get Newly Created reg_loc ++++++++++++++++++++++++     " >> $tr_file
curl -X GET -H "Content-Type: application/json" -u $api_user:$api_pass -d  '{"state": "ca","county": "Placer", "city": "Lincoln10", "zip": 95648}'  $get_api_host"/get_reg_loc_id" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Recreating a new reg_loc  ++++++++++++++++++++++++     " >> $tr_file
curl -X POST -H "Content-Type: application/json" -u $api_user:$api_pass -d  '{"state": "ca","county": "Placer", "city": "Lincoln10", "zip": 95648}'  $cud_api_host"/create_reg_loc" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Deleting the new reg_loc  ++++++++++++++++++++++++     " >> $tr_file
curl -X DELETE -H "Content-Type: application/json" -u $api_user:$api_pass -d  '{"state": "ca","county": "Placer", "city": "Lincoln10", "zip": 95648}'  $cud_api_host"/delete_reg_loc" >> $tr_file

echo "" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Creating a new county  ++++++++++++++++++++++++     " >> $tr_file
curl -X POST -H "Content-Type: application/json" -u $api_user:$api_pass -d  '{"state": "ca","county": "PlacerDD"}'  $cud_api_host"/create_county" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Get Newly Created county ++++++++++++++++++++++++     " >> $tr_file
curl -X GET -H "Content-Type: application/json" -u $api_user:$api_pass -d  '{"state": "ca","county": "PlacerDD"}' $get_api_host"/get_county_id" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Recreating a new county  ++++++++++++++++++++++++     " >> $tr_file
curl -X POST -H "Content-Type: application/json" -u $api_user:$api_pass -d  '{"state": "ca","county": "PlacerDD"}'  $cud_api_host"/create_county" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Deleting the new county  ++++++++++++++++++++++++     " >> $tr_file
curl -X DELETE -H "Content-Type: application/json" -u $api_user:$api_pass -d  '{"state": "ca","county": "PlacerDD"}'  $cud_api_host"/delete_county" >> $tr_file

echo "" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Creating a new registration for DOL Vehicle Id: 111111112  ++++++++++++++++++++++++     " >> $tr_file
curl -X POST -H "Content-Type: application/json" -u $api_user:$api_pass -d '{"vin":"1C4RJYD67N","dol_veh_id":111111112,"city":"Othello","zip":99344,"st":"WA","county":"Grant","make":"JEEP","model":"GRAND CHEROKEE","m_year":2022,"ev_type":"Plug-in Hybrid Electric Vehicle (PHEV)","cavf":"Not eligible due to low battery range","ev_range":25,"msrp":100,"leg_dist":13,"veh_location_gps":"POINT (-119.1742 46.82616)","el_utility":"PUD NO 4 OF GRANT COUNTY","census_t":53025011401}' $cud_api_host"/create_update_registration/create" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Getting the newly create registration details for DOL Vehicle Id: 111111112  ++++++++++++++++++++++++     " >> $tr_file
curl -X GET -H "Content-Type: application/json"  -u $api_user:$api_pass -d '{"dol_veh_id": 111111112}' $get_api_host"/get_regs_by_dol_veh_id" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Recreating the registration for same DOL Vehicle Id: 111111112  ++++++++++++++++++++++++     " >> $tr_file
curl -X POST -H "Content-Type: application/json" -u $api_user:$api_pass -d '{"vin":"1C4RJYD67N","dol_veh_id":111111112,"city":"Othello","zip":99344,"st":"WA","county":"Grant","make":"JEEP","model":"GRAND CHEROKEE","m_year":2022,"ev_type":"Plug-in Hybrid Electric Vehicle (PHEV)","cavf":"Not eligible due to low battery range","ev_range":25,"msrp":100,"leg_dist":13,"veh_location_gps":"POINT (-119.1742 46.82616)","el_utility":"PUD NO 4 OF GRANT COUNTY","census_t":53025011401}' $cud_api_host"/create_update_registration/create" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Updating the registration for same DOL Vehicle Id: 111111112. Setting msrp to 10001 and ev_range to 30  ++++++++++++++++++++++++     " >> $tr_file     
curl -X PUT -H "Content-Type: application/json" -u $api_user:$api_pass -d '{"vin":"1C4RJYD67N","dol_veh_id":111111112,"city":"Othello","zip":99344,"st":"WA","county":"Grant","make":"JEEP","model":"GRAND CHEROKEE","m_year":2022,"ev_type":"Plug-in Hybrid Electric Vehicle (PHEV)","cavf":"Not eligible due to low battery range","ev_range":30,"msrp":10001,"leg_dist":13,"veh_location_gps":"POINT (-119.1742 46.82616)","el_utility":"PUD NO 4 OF GRANT COUNTY","census_t":53025011401}' $cud_api_host/"create_update_registration/update" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Getting the details for DOL Vehicle Id: 111111112 after the update  ++++++++++++++++++++++++     " >> $tr_file
curl -X GET -H "Content-Type: application/json"  -u $api_user:$api_pass -d '{"dol_veh_id": 111111112}' $get_api_host"/get_regs_by_dol_veh_id" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Deleting the details for DOL Vehicle Id: 111111112  ++++++++++++++++++++++++     " >> $tr_file
curl -X DELETE -H "Content-Type: application/json"  -u $api_user:$api_pass -d '{"dol_veh_id": 111111112}' $cud_api_host"/delete_registration_by_dol_veh_id" >> $tr_file

echo "     ++++++++++++++++++++++++  START: Testing Getting the details for DOL Vehicle Id: 111111112 after delete  ++++++++++++++++++++++++     " >> $tr_file
curl -X GET -H "Content-Type: application/json"  -u $api_user:$api_pass -d '{"dol_veh_id": 111111112}' $get_api_host"/get_regs_by_dol_veh_id" >> $tr_file

echo "##############################  END: Testing EV read API services ##############################" >> $tr_file
