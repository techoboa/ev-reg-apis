

/*
update m.t_ev set 
county = 'NA1',
city = 'NA1',
zip = '00001',
census_tract = '00000001'
where dol_veh_id = 179569743;


update m.t_ev set 
county = 'NA2',
city = 'NA2',
zip = '00002',
census_tract = '00000002'
where dol_veh_id = 159850029;


update m.t_ev set 
county = 'NA3',
city = 'NA3',
zip = '00003',
census_tract = '00000003'
where dol_veh_id = 244582593;
*/


CREATE TABLE IF NOT EXISTS m.t_ev
(vin varchar(10), 
 county varchar(30), 
 city varchar(30), 
 st varchar(2), 
 zip int, 
 m_year int,
 make varchar(30), 
 model varchar(30), 
 ev_type varchar(100),
 cavf varchar(100),
 ev_range int,
 msrp int,
 leg_dist int,
 dol_veh_id int,
 veh_location varchar(100),
 el_utility text,
 census_tract bigint
 );
 

CREATE SEQUENCE m.seq_t_models
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;

CREATE TABLE IF NOT EXISTS m.t_models
(
    id_model integer DEFAULT nextval('m.seq_t_models'::regclass) NOT NULL primary key,
	m_year int,
	make varchar(30), 
	model varchar(30),
    model_create_time timestamp without time zone,
    model_update_time timestamp without time zone,
    cmodel_created_by character(20),
    model_updated_by character(20)
);


CREATE SEQUENCE m.seq_t_states
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;

CREATE TABLE IF NOT EXISTS m.t_states
(
    id_state integer DEFAULT nextval('m.seq_t_states'::regclass) NOT NULL primary key,
	st varchar(2),
    st_create_time timestamp without time zone,
    st_update_time timestamp without time zone,
    st_created_by character(20),
    st_updated_by character(20)
);

CREATE SEQUENCE m.seq_t_counties
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;

CREATE TABLE IF NOT EXISTS m.t_counties
(
    id_county integer DEFAULT nextval('m.seq_t_counties'::regclass) NOT NULL primary key,
	county varchar(30),
	id_state integer,
    county_create_time timestamp without time zone,
    county_update_time timestamp without time zone,
    county_created_by character(20),
    county_updated_by character(20),
	CONSTRAINT fk_t_states_id_state FOREIGN KEY (id_state) REFERENCES m.t_states(id_state)
);

CREATE SEQUENCE m.seq_t_census_t
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;
	
CREATE TABLE IF NOT EXISTS m.t_census_t
(
    id_census_t integer DEFAULT nextval('m.seq_t_census_t'::regclass) NOT NULL primary key,
	census_t bigint,
	id_county integer,
    census_t_create_time timestamp without time zone,
    census_t_update_time timestamp without time zone,
    census_t_created_by character(20),
    census_t_updated_by character(20),
	CONSTRAINT fk_t_counties_id_county FOREIGN KEY (id_county) REFERENCES m.t_counties(id_county)
);	

CREATE SEQUENCE m.seq_t_reg_loc
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;
	
-- 6. One table for city/zip FK county + city + zip combination - gives location key
	
CREATE TABLE IF NOT EXISTS m.t_reg_loc
(
    id_reg_loc integer DEFAULT nextval('m.seq_t_reg_loc'::regclass) NOT NULL primary key,
	city varchar(30),
	zip integer,
	id_county integer,
    reg_loc_create_time timestamp without time zone,
    reg_loc_update_time timestamp without time zone,
    reg_loc_created_by character(20),
    reg_loc_updated_by character(20),
	CONSTRAINT fk_t_counties_reg_loc_id_county FOREIGN KEY (id_county) REFERENCES m.t_counties(id_county)
);	

CREATE SEQUENCE m.seq_t_ev_type
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;

CREATE TABLE IF NOT EXISTS m.t_ev_type
(
    id_ev_type integer DEFAULT nextval('m.seq_t_ev_type'::regclass) NOT NULL primary key,
	ev_type varchar(100),
    ev_type_create_time timestamp without time zone,
    ev_type_update_time timestamp without time zone,
    ev_type_created_by character(20),
    ev_type_updated_by character(20)
);	


CREATE SEQUENCE m.seq_t_cavf
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;

CREATE TABLE IF NOT EXISTS m.t_cavf
(
    id_cavf integer DEFAULT nextval('m.seq_t_cavf'::regclass) NOT NULL primary key,
	cavf varchar(100),
    cavf_create_time timestamp without time zone,
    cavf_update_time timestamp without time zone,
	cavf_created_by character(20),
	cavf_updated_by character(20)
);	

CREATE SEQUENCE m.seq_t_ev_regs
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;

--elect * from m.t_ev limit 10;
--drop table m.t_ev_regs

CREATE TABLE IF NOT EXISTS m.t_ev_regs
(
    id_ev_reg integer DEFAULT nextval('m.seq_t_regs'::regclass) NOT NULL,
	vin varchar(10), 
	dol_veh_id int,	
	id_reg_loc integer,
	id_model integer,
	id_ev_type integer,
	id_cavf integer,
	ev_range integer,
	msrp integer,
	leg_dist integer,
	veh_location_gps varchar(100),
	el_utility text,
	id_census_t integer,
    reg_create_time timestamp without time zone,
    reg_update_time timestamp without time zone,
    reg_created_by character(20),
    reg_updated_by character(20),
	CONSTRAINT fk_t_ev_regs_t_reg_loc_id_reg_loc FOREIGN KEY (id_reg_loc) REFERENCES m.t_reg_loc(id_reg_loc),
	CONSTRAINT fk_t_ev_regs_t_models_id_model FOREIGN KEY (id_model) REFERENCES m.t_models(id_model),
	CONSTRAINT fk_t_ev_regs_t_ev_type_id_ev_type FOREIGN KEY (id_ev_type) REFERENCES m.t_ev_type(id_ev_type),
	CONSTRAINT fk_t_ev_regs_t_cavf_id_cavf FOREIGN KEY (id_cavf) REFERENCES m.t_cavf(id_cavf),
	CONSTRAINT fk_t_ev_regs_t_census_t_id_census_t FOREIGN KEY (id_census_t) REFERENCES m.t_census_t(id_census_t)
);	

-- select * from m.t_reg_loc where id_reg_loc = 3357

CREATE SEQUENCE m.seq_t_sql_proc_fn_logs
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;

-- PROCS START HERE


CREATE or replace PROCEDURE m.p_prep_bulk_models()
    LANGUAGE plpgsql
    AS $$
 DECLARE
 BEGIN
	insert into m.t_models (
		id_model,
		m_year,
		make, 
		model,
	    model_create_time,
	    model_update_time,
	    cmodel_created_by,
	    model_updated_by
	) 
	select nextval('m.seq_t_models'), m_year, make, model, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_USER, CURRENT_USER from (select distinct m_year, make, model from m.t_ev order by make, model, m_year) mt;
 END;
 $$;
 
 
CREATE or replace PROCEDURE m.p_prep_bulk_states()
    LANGUAGE plpgsql
    AS $$
 DECLARE
 BEGIN
	insert into m.t_states (
		id_state,
		st,
	    st_create_time,
	    st_update_time,
	    st_created_by,
	    st_updated_by
	) 
	select nextval('m.seq_t_states'), st, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_USER, CURRENT_USER from (select distinct st from m.t_ev order by st) stt;
 END;
 $$;

CREATE or replace PROCEDURE m.p_prep_bulk_counties()
    LANGUAGE plpgsql
    AS $$
 DECLARE
 BEGIN
	insert into m.t_counties (
		id_county,
		county,
		id_state,
		county_create_time,
		county_update_time,
		county_created_by,
		county_updated_by
	) 
	select 
		nextval('m.seq_t_counties'), 
		county,
		id_state, 
		CURRENT_TIMESTAMP, 
		CURRENT_TIMESTAMP, 
		CURRENT_USER, 
		CURRENT_USER 
	from 
	(
		select distinct county, s.id_state from m.t_ev e, m.t_states s where e.st = s.st order by county
	) cnty;
 END;
 $$;

 CREATE or replace PROCEDURE m.p_prep_bulk_census_t()
    LANGUAGE plpgsql
    AS $$
 DECLARE
 BEGIN
        insert into m.t_census_t (
                id_census_t,
                census_t,
                id_county,
                census_t_create_time,
                census_t_update_time,
                census_t_created_by,
                census_t_updated_by
        )
        select
                nextval('m.seq_t_census_t'),
                census_tract,
                id_county,
                CURRENT_TIMESTAMP,
                CURRENT_TIMESTAMP,
                CURRENT_USER,
                CURRENT_USER
        from
        (
                select distinct
                        e.census_tract,
                        --c.county,
                        --e.st,
                        c.id_county,
                        count(*) cnt
                from
                        m.t_ev e,
                        m.t_counties c,
                        m.t_states s
                where
                        e.county = c.county and
                        e.st = s.st and
                        s.id_state = c.id_state
                group by
                        e.census_tract,
                        --c.county,
                        --e.st,
                        c.id_county
                order by
                        --county,
                        --st,
                        id_county,
                        census_tract
        ) ct;
 END;
 $$;
 
 CREATE or replace PROCEDURE m.p_prep_bulk_reg_loc()
    LANGUAGE plpgsql
    AS $$
 DECLARE
 BEGIN
	insert into m.t_reg_loc (
		id_reg_loc,
		city,
		zip,
		id_county,
		reg_loc_create_time,
		reg_loc_update_time,
		reg_loc_created_by,
		reg_loc_updated_by
	)
	select 
		nextval('m.seq_t_reg_loc'), 
		city,
		zip,
		id_county, 
		CURRENT_TIMESTAMP, 
		CURRENT_TIMESTAMP, 
		CURRENT_USER, 
		CURRENT_USER 
	from 
	(
		select distinct 
			e.city, 
			e.zip, 
			c.id_county, 
			count(*) cnt
		from 
			m.t_ev e,
			m.t_counties c,
			m.t_states s
		where
			e.county = c.county and
			e.st = s.st and
			s.id_state = c.id_state
		group by 
--			c.county, 
			e.city, 
			e.zip, 
--			e.st, 
			c.id_county
		order by 
--			c.county, 
			e.city, 
			e.zip, 
--			e.st, 
			c.id_county
	) regloc;
 END;
 $$;
 
 
 CREATE or replace PROCEDURE m.p_prep_bulk_ev_type()
    LANGUAGE plpgsql
    AS $$
 DECLARE
 BEGIN
	insert into m.t_ev_type (
		id_ev_type,
		ev_type,
		ev_type_create_time,
		ev_type_update_time,
		ev_type_created_by,
		ev_type_updated_by
	)
	select 
		nextval('m.seq_t_ev_type'), 
		ev_type,
		CURRENT_TIMESTAMP, 
		CURRENT_TIMESTAMP, 
		CURRENT_USER, 
		CURRENT_USER 
	from 
	(
		select distinct ev_type from m.t_ev
	) evt;
 END;
 $$;


 CREATE or replace PROCEDURE m.p_prep_bulk_cavf()
    LANGUAGE plpgsql
    AS $$
 DECLARE
 BEGIN
	insert into m.t_cavf (
		id_cavf,
		cavf,
		cavf_create_time,		
		cavf_update_time,
		cavf_created_by,
		cavf_updated_by
	)
	select 
		nextval('m.seq_t_cavf'), 
		cavf,
		CURRENT_TIMESTAMP, 
		CURRENT_TIMESTAMP, 
		CURRENT_USER, 
		CURRENT_USER 
	from 
	(
		select distinct cavf from m.t_ev
	) ca;
 END;
 $$;

 CREATE or replace PROCEDURE m.p_prep_ev_regs()
    LANGUAGE plpgsql
    AS $$
 DECLARE
 BEGIN
	insert into m.t_ev_regs (
		id_ev_reg,
		vin, 
		dol_veh_id,	
		id_reg_loc,
		id_model,
		id_ev_type,
		id_cavf,
		ev_range,
		msrp,
		leg_dist,
		veh_location_gps,
		el_utility,
		id_census_t,
		reg_create_time,
		reg_update_time,
		reg_created_by,
		reg_updated_by
	)
	select 
		nextval('m.seq_t_ev_regs'), 
		vin, 
		dol_veh_id,	
		id_reg_loc,
		id_model,
		id_ev_type,
		id_cavf,
		ev_range,
		msrp,
		leg_dist,
		veh_location,
		el_utility,
		id_census_t,
		CURRENT_TIMESTAMP, 
		CURRENT_TIMESTAMP, 
		CURRENT_USER, 
		CURRENT_USER 
	from 
	(
		select			
			ev.vin, 
			ev.dol_veh_id,	
			r.id_reg_loc,
			st.st,
			ev.st evst,
			cn.county,
			ev.county evcounty, 
			r.city,
			ev.city evcity,
			r.zip,
			ev.zip evzip,		
			m.id_model,
			et.id_ev_type,
			ca.id_cavf,
			ev.ev_range,
			ev.msrp,
			ev.leg_dist,
			ev.veh_location,
			ev.el_utility,
			ct.id_census_t
		from 
			m.t_ev ev,
			m.t_models m,
			m.t_reg_loc r,
			m.t_counties cn,	
			m.t_states st,		
			m.t_ev_type et,
			m.t_cavf ca,
			m.t_census_t ct
		where
			ev.m_year = m.m_year and
			ev.make = m.make and
			ev.model = m.model and
			ev.ev_type = et.ev_type and
			ev.cavf = ca.cavf and
			ev.census_tract = ct.census_t and
			ev.city = r.city and		
			ev.zip = r.zip and
			ev.county = cn.county and
			ev.st = st.st and		
			cn.id_state = st.id_state and
			cn.id_county = r.id_county
		--order by 
		--	ev.vin, 
		--	ev.dol_veh_id			
	) regloc;
 END;
 $$;
 
 
CREATE TABLE IF NOT EXISTS m.t_sql_proc_fn_logs
(
    id_sql_proc_fn_log integer DEFAULT nextval('m.seq_t_sql_proc_fn_logs'::regclass) NOT NULL primary key,
	run_id varchar(150),
	sql_caller varchar(50), 
	msg_called text,
	msg_finished text,
	run_comments text,
    called_at timestamp without time zone,
    finished_at timestamp without time zone,
    run_duration interval,
    called_by character(20),
    finished_by character(20)
); 

/*
CREATE OR REPLACE drop FUNCTION m.get_curr_fx_name()
RETURNS text AS  $$
DECLARE
  stack text; fcesig text;
BEGIN
  GET DIAGNOSTICS stack = PG_CONTEXT;
  fcesig := substring(stack from 'function (.*?) line');
  RETURN fcesig::regprocedure::text;
END;
$$ LANGUAGE plpgsql;
*/

CREATE OR REPLACE FUNCTION m.fn_create_logs(in_sql_caller varchar(50), in_msg_called text, in_msg_finished text, in_run_comments text, in_action varchar(10), in_id_log integer, in_run_id varchar(150))
	returns integer
    LANGUAGE plpgsql
    AS $$ 
Declare  
	ret_id_log integer;
	split_fn_name varchar(50);
Begin	
	IF upper(in_action) = 'UPDATE' THEN	
		update m.t_sql_proc_fn_logs set 
			msg_finished = in_msg_finished,
			run_comments = in_run_comments,
			finished_at = clock_timestamp(),
			finished_by = current_user,
			run_duration = 	clock_timestamp() - called_at		
		where
			id_sql_proc_fn_log = in_id_log;
		ret_id_log = in_id_log;
	ELSE
		begin
		SELECT SPLIT_PART(in_sql_caller, '(', 1) into split_fn_name;
		raise notice ' nnn%', split_fn_name;
		insert into m.t_sql_proc_fn_logs 
		values (default, in_run_id, split_fn_name, in_msg_called, null, in_run_comments, clock_timestamp(), null, null, current_user, null)
		RETURNING id_sql_proc_fn_log into ret_id_log;
		
		raise notice ' 000%', split_fn_name;
		-- insert into m.t_sql_proc_fn_logs 
--		values (default, split_fn_name, in_msg_called, null, in_run_comments, clock_timestamp(), null, null, current_user, null)
--		RETURNING id_sql_proc_fn_log
		end;
	END IF;
	return ret_id_log;
END;
$$;

CREATE OR REPLACE FUNCTION m.fn_get_regs_by_dol_veh_id(in_dol_veh_id integer, in_run_id varchar(150))
	returns text
    LANGUAGE plpgsql
    AS $$ 
Declare  
 	fn_name text;
	id_log integer;
	stack text; 
	ret_val text;
Begin
	GET DIAGNOSTICS stack = PG_CONTEXT; fn_name := substring(stack from 'function (.*?) line');
	select * from m.fn_create_logs(fn_name, 'Called for details for dol_veh_id: ' || in_dol_veh_id, null, null, 'create', null, in_run_id) into id_log;		
	select json_agg(v) into ret_val from m.v_get_all_registrations v where v.dol_veh_id in (in_dol_veh_id);
	select * from m.fn_create_logs(fn_name, null, 'finished with no issues', 'nothing to report', 'update', id_log, in_run_id) into id_log;	
	return ret_val;	
END;
$$;


CREATE OR REPLACE FUNCTION m.fn_get_regs_by_vin(in_vin varchar(10), in_run_id varchar(150))
	returns text
    LANGUAGE plpgsql
    AS $$ 
Declare  
 	fn_name text;
	id_log integer;
	stack text; 
	ret_val text;
Begin
	GET DIAGNOSTICS stack = PG_CONTEXT; fn_name := substring(stack from 'function (.*?) line');
	select * from m.fn_create_logs(fn_name, 'Called for details for vin: ' || in_vin, null, null, 'create', null, in_run_id) into id_log;
	select json_agg(v) into ret_val from m.v_get_all_registrations v where v.vin = in_vin;
	select * from m.fn_create_logs(fn_name, null, 'finished with no issues', 'nothing to report', 'update', id_log, in_run_id) into id_log;		
	return ret_val;		
END;
$$;


CREATE OR REPLACE FUNCTION m.fn_get_all_models(in_run_id varchar(150))
	returns text
    LANGUAGE plpgsql
    AS $$ 
Declare  
 	fn_name text;
	id_log integer;
	stack text; 
	ret_val text;
Begin
	GET DIAGNOSTICS stack = PG_CONTEXT; fn_name := substring(stack from 'function (.*?) line');
	select * from m.fn_create_logs(fn_name, 'Called to get all models', null, null, 'create', null, in_run_id) into id_log;		

	select json_agg(t) into ret_val from
	(
		select 
			m_year,
			make,
			model,
			model_create_time,
			model_update_time
		from 
			m.t_models
	)t;

	select * from m.fn_create_logs(fn_name, null, 'finished with no issues', 'nothing to report', 'update', id_log, in_run_id) into id_log;	
	return ret_val;	
END;
$$;

CREATE OR REPLACE FUNCTION m.fn_get_all_cavf(in_run_id varchar(150))
	returns text
    LANGUAGE plpgsql
    AS $$ 
Declare  
 	fn_name text;
	id_log integer;
	stack text; 
	ret_val text;
Begin
	GET DIAGNOSTICS stack = PG_CONTEXT; fn_name := substring(stack from 'function (.*?) line');
	select * from m.fn_create_logs(fn_name, 'Called to get all CAVFs', null, null, 'create', null, in_run_id) into id_log;		

	select json_agg(t) into ret_val from
	(
		select 
			cavf,
			cavf_create_time,
			cavf_update_time
		from 
			m.t_cavf
	)t;

	select * from m.fn_create_logs(fn_name, null, 'finished with no issues', 'nothing to report', 'update', id_log, in_run_id) into id_log;	
	return ret_val;	
END;
$$;


CREATE OR REPLACE FUNCTION m.fn_get_all_ev_types(in_run_id varchar(150))
	returns text
    LANGUAGE plpgsql
    AS $$ 
Declare  
 	fn_name text;
	id_log integer;
	stack text; 
	ret_val text;
Begin
	GET DIAGNOSTICS stack = PG_CONTEXT; fn_name := substring(stack from 'function (.*?) line');
	select * from m.fn_create_logs(fn_name, 'Called to get all EV types', null, null, 'create', null, in_run_id) into id_log;		

	select json_agg(t) into ret_val from
	(
		select 
			ev_type,
			ev_type_create_time,
			ev_type_update_time
		from 
			m.t_ev_type
	)t;

	select * from m.fn_create_logs(fn_name, null, 'finished with no issues', 'nothing to report', 'update', id_log, in_run_id) into id_log;	
	return ret_val;	
END;
$$;

CREATE OR REPLACE FUNCTION m.fn_get_all_states(in_run_id varchar(150))
	returns text
    LANGUAGE plpgsql
    AS $$ 
Declare  
 	fn_name text;
	id_log integer;
	stack text; 
	ret_val text;
Begin
	GET DIAGNOSTICS stack = PG_CONTEXT; fn_name := substring(stack from 'function (.*?) line');
	select * from m.fn_create_logs(fn_name, 'Called to get all States', null, null, 'create', null, in_run_id) into id_log;		

	select json_agg(t) into ret_val from
	(
		select 
			st,
			st_create_time,
			st_update_time
		from 
			m.t_states
	)t;

	select * from m.fn_create_logs(fn_name, null, 'finished with no issues', 'nothing to report', 'update', id_log, in_run_id) into id_log;	
	return ret_val;	
END;
$$;

CREATE OR REPLACE FUNCTION m.fn_get_all_regs(max_count integer, in_run_id varchar(150))
	returns text
    LANGUAGE plpgsql
    AS $$ 
Declare  
 	fn_name text;
	id_log integer;
	stack text; 
	ret_val text;
Begin
	GET DIAGNOSTICS stack = PG_CONTEXT; fn_name := substring(stack from 'function (.*?) line');
	select * from m.fn_create_logs(fn_name, 'Called to get all registrations', null, null, 'create', null, in_run_id) into id_log;		

	select json_agg(t) into ret_val from
	(
		select 
			vin, 
			dol_veh_id,	
			city,
			zip,	
			st,
			county,
			make,
			model,	
			m_year,	
			ev_type,
			cavf,
			ev_range,
			msrp,
			leg_dist,
			veh_location_gps,
			el_utility,
			census_t
		from 
			m.v_get_all_registrations
		limit max_count
	)t;

	select * from m.fn_create_logs(fn_name, null, 'finished with no issues', 'nothing to report', 'update', id_log, in_run_id) into id_log;	
	return ret_val;	
END;
$$;


CREATE OR REPLACE FUNCTION m.fn_get_state(in_st varchar(10), in_run_id varchar(150))
	returns text
    LANGUAGE plpgsql
    AS $$ 
Declare  
 	fn_name text;
	run_id varchar(150);
	id_log integer;
	stack text; 
	ret_val text;
Begin
	GET DIAGNOSTICS stack = PG_CONTEXT; fn_name := substring(stack from 'function (.*?) line');
	select * from m.fn_create_logs(fn_name, 'Called for details for state: ' || in_st, null, null, 'create', null, in_run_id) into id_log;
	select json_agg(t) into ret_val from m.t_states t where t.st = in_st;
	-- Querying selective fields - No significant performance impact recorded.
	-- select json_agg(x) into val from (select t.id_state, t.st from m.t_states t where t.st in (in_st)) x;	
	select * from m.fn_create_logs(fn_name, null, 'finished with no issues', 'nothing to report', 'update', id_log, in_run_id) into id_log;		
	return ret_val;		
END;
$$;

CREATE OR REPLACE FUNCTION m.fn_get_state_id(in_st varchar(10), in_run_id varchar(150))
	returns integer
    LANGUAGE plpgsql
    AS $$ 
Declare  
	out_state_id integer;
 	fn_name text;
	id_log integer;
	stack text; 
Begin
	GET DIAGNOSTICS stack = PG_CONTEXT; fn_name := substring(stack from 'function (.*?) line');
	select * from m.fn_create_logs(fn_name, 'Called for id for state: ' || in_st, null, null, 'create', null, in_run_id) into id_log;
	select t.id_state into out_state_id from m.t_states t where t.st = in_st;
	-- Querying selective fields - No significant performance impact recorded.
	-- select json_agg(x) into val from (select t.id_state, t.st from m.t_states t where t.st in (in_st)) x;	
	select * from m.fn_create_logs(fn_name, null, 'finished with no issues', 'nothing to report', 'update', id_log, in_run_id) into id_log;		
	return out_state_id;		
END;
$$;

CREATE OR REPLACE FUNCTION m.fn_does_state_exist(in_st varchar(10))
	returns boolean
    LANGUAGE plpgsql
    AS $$ 
Declare  
 	state_id integer;
	run_id varchar(150);
 	fn_name text;
	id_log integer;
	stack text; 
	ret_val boolean;
Begin
	GET DIAGNOSTICS stack = PG_CONTEXT; fn_name := substring(stack from 'function (.*?) line');
	select m.fn_util_create_run_id(fn_name) into run_id;		
	select * from m.fn_create_logs(fn_name, 'Called for details for state: ' || in_st, null, null, 'create', null, run_id) into id_log;
	select m.fn_get_state_id(in_st) into state_id;
--	raise notice '%', state_id;
	if state_id is NULL then
		ret_val = FALSE;
	else
		ret_val = TRUE;
	end if;
	select * from m.fn_create_logs(fn_name, 'Called for details for state: ' || in_st, 'finished with no issues', 'nothing to report', 'update', id_log, run_id) into id_log;		
	return ret_val;		
END;
$$;

CREATE OR REPLACE FUNCTION m.fn_get_county_id_for_state(in_st varchar(10), in_county varchar(30), in_run_id varchar(150))
	returns integer
    LANGUAGE plpgsql
    AS $$ 
Declare  
	out_county_id integer;
	state_id integer;
	msg text;
 	fn_name text;
	id_log integer;
	stack text; 
Begin
	GET DIAGNOSTICS stack = PG_CONTEXT; fn_name := substring(stack from 'function (.*?) line');
	select * from m.fn_create_logs(fn_name, 'Called for id for county: ' || in_county || ', state: ' || in_st, null, null, 'create', null, in_run_id) into id_log;
	select t.id_state into state_id from m.t_states t where UPPER(t.st) = UPPER(in_st);
	
	if state_id is NULL then
		msg = 'State ' || in_st || ' does not exist. Returning and closing the program.';
		select * from m.fn_create_logs(fn_name, 'Called for id for county: ' || in_county || ', state: ' || in_st, msg, 'FAIL', 'update', id_log, in_run_id) into id_log;		
		return 0;
	end if;	
	
	select t.id_county into out_county_id from m.t_counties t where t.id_state = state_id and UPPER(county) = UPPER(in_county);
	
	if out_county_id is NULL then
		msg = 'The combination of State ' || in_st || ' and county ' || ' does not exist. Please create the combination entry in the required tables. Returning and closing the program.';
		select * from m.fn_create_logs(fn_name, null, msg, 'FAIL', 'update', id_log, in_run_id) into id_log;
		raise notice '%', msg;
		return 0;
	end if;
	
	select * from m.fn_create_logs(fn_name, null, 'finished with no issues', 'PASS', 'update', id_log, in_run_id) into id_log;	
	return out_county_id;		
END;
$$;


CREATE OR REPLACE FUNCTION m.fn_get_reg_loc_id(in_st varchar(10), in_county varchar(30), in_city varchar(30), in_zip integer, in_run_id varchar(150))
	returns integer
    LANGUAGE plpgsql
    AS $$ 
Declare  
	out_reg_loc_id integer;
	state_id integer;
	county_id integer;	
	msg text;
 	fn_name text;
	id_log integer;
	stack text; 
Begin
	GET DIAGNOSTICS stack = PG_CONTEXT; fn_name := substring(stack from 'function (.*?) line');	
	select * from m.fn_create_logs(fn_name, 'Called for id for county: ' || in_county || ', state: ' || in_st || ', city: ' || in_city || ', zip: ' || in_zip, null, null, 'create', null, in_run_id) into id_log;
	select t.id_state into state_id from m.t_states t where UPPER(t.st) = UPPER(in_st);
	-- raise notice '%', state_id;	
	
	if state_id is NULL then
		msg = 'State ' || in_st || ' does not exist. Returning and closing the program.';
		select * from m.fn_create_logs(fn_name, null, msg, 'FAIL', 'update', id_log, in_run_id) into id_log;		
		raise notice '%', msg;
		return 0;
	end if;	
	
	select t.id_county into county_id from m.t_counties t where t.id_state = state_id and UPPER(county) = UPPER(in_county);
	-- raise notice '%', county_id;	
	
	if county_id is NULL then
		msg = 'The combination of State ' || in_st || ' and county ' || ' does not exist. Please create the combination entry in the required tables. Returning and closing the program.';
		select * from m.fn_create_logs(fn_name, null, msg, 'FAIL', 'update', id_log, in_run_id) into id_log;
		raise notice '%', msg;
		return 0;
	end if;
	
	select t.id_reg_loc into out_reg_loc_id from m.t_reg_loc t where t.id_county = county_id and UPPER(t.city) = UPPER(in_city) and t.zip = in_zip;
	-- raise notice '%', out_reg_loc_id;
	
	if out_reg_loc_id is NULL then
		msg = 'The combination of State ' || in_st || ', county ' || ', city: ' || in_city || ', zip: ' || in_zip || ' does not exist. Please create the combination entry in the required tables. Returning and closing the program.';
		select * from m.fn_create_logs(fn_name, null, msg, 'FAIL', 'update', id_log, in_run_id) into id_log;
		raise notice '%', msg;
		return 0;
	end if;	
	
	select * from m.fn_create_logs(fn_name, null, 'finished with no issues', 'PASS', 'update', id_log, in_run_id) into id_log;	
	return out_reg_loc_id;		
END;
$$;

CREATE OR REPLACE FUNCTION m.fn_get_model_id(in_m_year integer, in_make varchar(30), in_model varchar(30), in_run_id varchar(150))
	returns integer
    LANGUAGE plpgsql
    AS $$ 
Declare  
	out_model_id integer;
	msg text;
 	fn_name text;
	id_log integer;
	stack text; 
Begin
	GET DIAGNOSTICS stack = PG_CONTEXT; fn_name := substring(stack from 'function (.*?) line');	
	in_make = UPPER(in_make);
	in_model = UPPER(in_model);	
	select * from m.fn_create_logs(fn_name, 'Called for id for Make: ' || in_make || ', model: ' || in_model || ', year: ' || in_m_year, null, null, 'create', null, in_run_id) into id_log;
	select t.id_model into out_model_id from m.t_models t where t.m_year = in_m_year and UPPER(t.make) = UPPER(in_make) and UPPER(t.model) = UPPER(in_model);
	--raise notice '%', out_model_id;
	
	if out_model_id is NULL then
		msg = 'The combination of Model: ' || in_model || ', Make: ' || in_make || ', Year: ' || in_m_year || ' does not exist. Please create the combination entry in the required tables. Returning and closing the program.';
		select * from m.fn_create_logs(fn_name, null, msg, 'FAIL', 'update', id_log, in_run_id) into id_log;		
		raise notice '%', msg;
		return 0;
	end if;	
		
	select * from m.fn_create_logs(fn_name, null, 'finished with no issues', 'PASS', 'update', id_log, in_run_id) into id_log;	
	return out_model_id;		
END;
$$;


CREATE OR REPLACE FUNCTION m.fn_get_cavf_id(in_cavf varchar(100), in_run_id varchar(150))
	returns integer
    LANGUAGE plpgsql
    AS $$ 
Declare  
	out_cavf_id integer;
	msg text;
 	fn_name text;
	id_log integer;
	stack text; 
Begin
	GET DIAGNOSTICS stack = PG_CONTEXT; fn_name := substring(stack from 'function (.*?) line');	
	select * from m.fn_create_logs(fn_name, 'Called for CAVF : "' || in_cavf || '"', null, null, 'create', null, in_run_id) into id_log;
	select t.id_cavf into out_cavf_id from m.t_cavf t where UPPER(t.cavf) = UPPER(in_cavf);
	--raise notice '%', id_cavf;	
	
	if out_cavf_id is NULL then
		msg = 'The CAVF entry: "' || in_cavf || '" does not exist. Please create the entry in the required table(s). Returning and closing the program.';
		select * from m.fn_create_logs(fn_name, null, msg, 'FAIL', 'update', id_log, in_run_id) into id_log;		
		raise notice '%', msg;
		return 0;
	end if;	
		
	select * from m.fn_create_logs(fn_name, null, 'finished with no issues', 'PASS', 'update', id_log, in_run_id) into id_log;	
	return out_cavf_id;		
END;
$$;

CREATE OR REPLACE FUNCTION m.fn_get_ev_type_id(in_ev_type varchar(100), in_run_id varchar(150))
	returns integer
    LANGUAGE plpgsql
    AS $$ 
Declare  
	out_ev_type_id integer;
	msg text;
 	fn_name text;
	id_log integer;
	stack text; 
Begin
	GET DIAGNOSTICS stack = PG_CONTEXT; fn_name := substring(stack from 'function (.*?) line');	
	select * from m.fn_create_logs(fn_name, 'Called for Ev Type : "' || in_ev_type || '"', null, null, 'create', null, in_run_id) into id_log;
	select t.id_ev_type into out_ev_type_id from m.t_ev_type t where UPPER(t.ev_type) = UPPER(in_ev_type);
	--raise notice '%', out_ev_type_id;	
	
	if out_ev_type_id is NULL then
		msg = 'The Ev Type entry: "' || in_ev_type || '"' || ' does not exist. Please create the entry in the required table(s). Returning and closing the program.';
		select * from m.fn_create_logs(fn_name, null, msg, 'FAIL', 'update', id_log, in_run_id) into id_log;		
		raise notice '%', msg;
		return 0;
	end if;	
		
	select * from m.fn_create_logs(fn_name, null, 'finished with no issues', 'PASS', 'update', id_log, in_run_id) into id_log;	
	return out_ev_type_id;		
END;
$$;


CREATE OR REPLACE FUNCTION m.fn_get_census_t_id(in_st varchar(10), in_county varchar(30), in_census_t bigint, in_run_id varchar(150))
	returns integer
    LANGUAGE plpgsql
    AS $$ 
Declare  
	out_census_t_id integer;
	state_id integer;
	county_id integer;	
	msg text;
 	fn_name text;
	id_log integer;
	stack text; 
Begin
	GET DIAGNOSTICS stack = PG_CONTEXT; fn_name := substring(stack from 'function (.*?) line');	
	select * from m.fn_create_logs(fn_name, 'Called for cencus tract id for county: ' || in_county || ', state: ' || in_st || ', census tract: ' || in_census_t, null, null, 'create', null, in_run_id) into id_log;
	select t.id_state into state_id from m.t_states t where UPPER(t.st) = UPPER(in_st);
	-- raise notice '%', state_id;	
	
	if state_id is NULL then
		msg = 'State ' || in_st || ' does not exist. Returning and closing the program.';
		select * from m.fn_create_logs(fn_name, null, msg, 'FAIL', 'update', id_log, in_run_id) into id_log;		
		raise notice '%', msg;
		return 0;
	end if;	
	
	select t.id_county into county_id from m.t_counties t where t.id_state = state_id and UPPER(county) = UPPER(in_county);
	-- raise notice '%', county_id;	
	
	if county_id is NULL then
		msg = 'The combination of State ' || in_st || ' and county ' || in_county || ' does not exist. Please create the combination entry in the required tables. Returning and closing the program.';
		select * from m.fn_create_logs(fn_name, null, msg, 'FAIL', 'update', id_log, in_run_id) into id_log;
		raise notice '%', msg;
		return 0;
	end if;
	
	select t.id_census_t into out_census_t_id from m.t_census_t t where t.id_county = county_id and t.census_t = in_census_t;
	-- raise notice '%', out_census_t_id;
	
	if out_census_t_id is NULL then
		msg = 'The combination of State ' || in_st || ', county ' || in_county || ', census tract: ' || in_census_t || ' does not exist. Please create the combination entry in the required tables. Returning and closing the program.';
		select * from m.fn_create_logs(fn_name, null, msg, 'FAIL', 'update', id_log, in_run_id) into id_log;
		raise notice '%', msg;
		return 0;
	end if;	
	
	select * from m.fn_create_logs(fn_name, null, 'finished with no issues', 'PASS', 'update', id_log, in_run_id) into id_log;	
	return out_census_t_id;		
END;
$$;

CREATE OR REPLACE VIEW m.v_get_all_registrations as 
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

CREATE OR REPLACE FUNCTION m.fn_util_create_run_id(fn_name text)
	returns text
    LANGUAGE plpgsql
    AS $$  
Declare  
	out_run_id varchar(150);
	split_fn_name varchar(50);		
Begin
	SELECT SPLIT_PART(fn_name, '(', 1) into split_fn_name;
	out_run_id = split_fn_name || '-' || replace(current_timestamp::text,' ','-');
	return out_run_id;			
END;
$$;

CREATE OR REPLACE FUNCTION m.fn_create_state(in_st varchar(10), in_run_id varchar(150))
	returns text
    LANGUAGE plpgsql
    AS $$ 
Declare  
	out_state_id integer;
	msg text;
	fn_name text;
	id_log integer;
	stack text; 
	err_msg_text text;
	err_ex_detail text;
	err_ex_hint text; 
	err_sql_state text;
	err_ex_context text;
	err_ex_constraint text;
	err_ex_data_type text;
	err_ex_schema text;
	err_ex_table text;
	err_ex_col text;  	
Begin
	GET DIAGNOSTICS stack = PG_CONTEXT; fn_name := substring(stack from 'function (.*?) line');
	in_st = upper(in_st);
	select * from m.fn_create_logs(fn_name, 'Called to create state: ' || in_st, null, null, 'create', null, in_run_id) into id_log;
	select m.fn_get_state_id(in_st, in_run_id) into out_state_id;	
	raise notice '%', out_state_id;

	IF out_state_id IS NOT NULL THEN
		msg = 'The State ' || in_st || ' already exists. Cannot have duplicate states in the system.';
		select * from m.fn_create_logs(fn_name, null, msg, 'FAIL', 'update', id_log, in_run_id) into id_log;
		raise notice '%', msg;
		return '{"state_id": 0, "return_msg": "' || msg || '"}';
	END IF;
	BEGIN
		insert into m.t_states (
			id_state,
			st,
			st_create_time,
			st_update_time,
			st_created_by,
			st_updated_by
		) 
		values
		(
			default,
			in_st, 
			CURRENT_TIMESTAMP, 
			CURRENT_TIMESTAMP, 
			CURRENT_USER, 
			CURRENT_USER
		) returning id_state into out_state_id;
		
	EXCEPTION
		WHEN OTHERS THEN
			GET STACKED DIAGNOSTICS 
								err_msg_text = MESSAGE_TEXT,
								  err_ex_detail = PG_EXCEPTION_DETAIL,
								  err_ex_hint = PG_EXCEPTION_HINT,
								  err_sql_state = RETURNED_SQLSTATE,
								  err_ex_context = pg_exception_context,
								  err_ex_constraint = CONSTRAINT_NAME,
								  err_ex_data_type = PG_DATATYPE_NAME,
								  err_ex_schema = SCHEMA_NAME,
								  err_ex_table = TABLE_NAME,
								  err_ex_col = COLUMN_NAME; 
			raise notice '%,%,%,%,%', err_msg_text, err_ex_detail, err_ex_hint, err_sql_state, err_ex_context;
			-- HANDLE EXCEPTION BY INSERTING INTO 
			return '{"state_id": 0, "return_msg": ' || msg || '}';	
	END;
	
	select * from m.fn_create_logs(fn_name, null, 'finished with no issues', 'nothing to report', 'update', id_log, in_run_id) into id_log;		
	return '{"state_id": ' || out_state_id || ', "return_msg": "New state registered"}';			
END;
$$;

CREATE OR REPLACE FUNCTION m.fn_create_model(in_m_year integer, in_make varchar(30), in_model varchar(30), in_run_id varchar(150))
	returns text
    LANGUAGE plpgsql
    AS $$ 
Declare  
	out_model_id integer;
	msg text;
	fn_name text;
	id_log integer;
	stack text; 
	err_msg_text text;
	err_ex_detail text;
	err_ex_hint text; 
	err_sql_state text;
	err_ex_context text;
	err_ex_constraint text;
	err_ex_data_type text;
	err_ex_schema text;
	err_ex_table text;
	err_ex_col text;  	
Begin
	GET DIAGNOSTICS stack = PG_CONTEXT; fn_name := substring(stack from 'function (.*?) line');
	in_make = upper(in_make);
	in_model = upper(in_model);
	select * from m.fn_create_logs(fn_name, 'Called to create model: ' || in_model || ', make: ' || in_make || ', year: ' || in_m_year, null, null, 'create', null, in_run_id) into id_log;
	select m.fn_get_model_id(in_m_year, in_make, in_model, in_run_id) into out_model_id;	
	raise notice 'model_id: %', out_model_id;

	IF out_model_id != 0 THEN
		msg = 'The combination of model: ' || in_model || ', make: ' || in_make || ', year: ' || in_m_year || ' already exists. Cannot have duplicate states in the system.';
		select * from m.fn_create_logs(fn_name, null, msg, 'FAIL', 'update', id_log, in_run_id) into id_log;
		raise notice '%', msg;
		return '{"model_id": 0, "return_msg": "' || msg || '"}';
	END IF;
	BEGIN
		insert into m.t_models (
			id_model,
			m_year,
			make,
			model,
			model_create_time,
			model_update_time,
			cmodel_created_by,
			model_updated_by
		) 
		values
		(
			default,
			in_m_year, 
			in_make,
			in_model, 
			CURRENT_TIMESTAMP,
			CURRENT_TIMESTAMP,
			CURRENT_USER,
			CURRENT_USER
		) returning id_model into out_model_id;
		
	EXCEPTION
		WHEN OTHERS THEN
			GET STACKED DIAGNOSTICS 
								err_msg_text = MESSAGE_TEXT,
								  err_ex_detail = PG_EXCEPTION_DETAIL,
								  err_ex_hint = PG_EXCEPTION_HINT,
								  err_sql_state = RETURNED_SQLSTATE,
								  err_ex_context = pg_exception_context,
								  err_ex_constraint = CONSTRAINT_NAME,
								  err_ex_data_type = PG_DATATYPE_NAME,
								  err_ex_schema = SCHEMA_NAME,
								  err_ex_table = TABLE_NAME,
								  err_ex_col = COLUMN_NAME; 
			raise notice '%,%,%,%,%', err_msg_text, err_ex_detail, err_ex_hint, err_sql_state, err_ex_context;
			-- HANDLE EXCEPTION BY INSERTING INTO 
			return '{"state_id": 0, "return_msg": ' || msg || '}';	
	END;
	
	select * from m.fn_create_logs(fn_name, null, 'finished with no issues', 'nothing to report', 'update', id_log, in_run_id) into id_log;		
	return '{"model_id": ' || out_model_id || ', "return_msg" : "New model id registered"}';			
END;
$$;


CREATE OR REPLACE FUNCTION m.fn_create_ev_type(in_ev_type varchar(100), in_run_id varchar(150))
	returns text
    LANGUAGE plpgsql
    AS $$ 
Declare  
	out_ev_type_id integer;
	msg text;
	fn_name text;
	id_log integer;
	stack text; 
	err_msg_text text;
	err_ex_detail text;
	err_ex_hint text; 
	err_sql_state text;
	err_ex_context text;
	err_ex_constraint text;
	err_ex_data_type text;
	err_ex_schema text;
	err_ex_table text;
	err_ex_col text;  	
Begin
	GET DIAGNOSTICS stack = PG_CONTEXT; fn_name := substring(stack from 'function (.*?) line');
	in_ev_type = upper(in_ev_type);
	select * from m.fn_create_logs(fn_name, 'Called to create ev type: ' || in_ev_type, null, null, 'create', null, in_run_id) into id_log;
	select m.fn_get_ev_type_id(in_ev_type, in_run_id) into out_ev_type_id;	
	raise notice 'out_ev_type_id: %', out_ev_type_id;

	IF out_ev_type_id != 0 THEN
		msg = 'The EV Type: ' || in_ev_type || ' already exists. Cannot have duplicate states in the system.';
		select * from m.fn_create_logs(fn_name, null, msg, 'FAIL', 'update', id_log, in_run_id) into id_log;
		raise notice '%', msg;
		return '{"ev_type_id": 0, "return_msg": "' || msg || '"}';
	END IF;
	
	BEGIN
        insert into m.t_ev_type (
			id_ev_type,
			ev_type,
			ev_type_create_time,
			ev_type_update_time,
			ev_type_created_by,
			ev_type_updated_by
        ) 
        values
		(
			default,
			in_ev_type,
			CURRENT_TIMESTAMP,
			CURRENT_TIMESTAMP,
			CURRENT_USER,
			CURRENT_USER
		) returning id_ev_type into out_ev_type_id;
		
	raise notice '%', out_ev_type_id;		
	EXCEPTION
		WHEN OTHERS THEN
			GET STACKED DIAGNOSTICS 
								err_msg_text = MESSAGE_TEXT,
								  err_ex_detail = PG_EXCEPTION_DETAIL,
								  err_ex_hint = PG_EXCEPTION_HINT,
								  err_sql_state = RETURNED_SQLSTATE,
								  err_ex_context = pg_exception_context,
								  err_ex_constraint = CONSTRAINT_NAME,
								  err_ex_data_type = PG_DATATYPE_NAME,
								  err_ex_schema = SCHEMA_NAME,
								  err_ex_table = TABLE_NAME,
								  err_ex_col = COLUMN_NAME; 
			raise notice '%,%,%,%,%', err_msg_text, err_ex_detail, err_ex_hint, err_sql_state, err_ex_context;
			-- HANDLE EXCEPTION BY INSERTING INTO 
			return '{"ev_type_id": 0, "return_msg": ' || msg || '}';	
	END;
	select * from m.fn_create_logs(fn_name, null, 'finished with no issues', 'nothing to report', 'update', id_log, in_run_id) into id_log;
	return '{"ev_type_id": ' || out_ev_type_id || ', "return_msg": "New EV Type Registered"}';
END;
$$;

CREATE OR REPLACE FUNCTION m.fn_create_cavf(in_cavf varchar(100), in_run_id varchar(150))
	returns text
    LANGUAGE plpgsql
    AS $$ 
Declare  
	out_cavf_id integer;
	msg text;
	fn_name text;
	id_log integer;
	stack text; 
	err_msg_text text;
	err_ex_detail text;
	err_ex_hint text; 
	err_sql_state text;
	err_ex_context text;
	err_ex_constraint text;
	err_ex_data_type text;
	err_ex_schema text;
	err_ex_table text;
	err_ex_col text;  	
Begin
	GET DIAGNOSTICS stack = PG_CONTEXT; fn_name := substring(stack from 'function (.*?) line');
	in_cavf = upper(in_cavf);
	select * from m.fn_create_logs(fn_name, 'Called to create cavf: ' || in_cavf, null, null, 'create', null, in_run_id) into id_log;
	select m.fn_get_cavf_id(in_cavf, in_run_id) into out_cavf_id;	
	raise notice 'out_cavf_id: %', out_cavf_id;

	IF out_cavf_id != 0 THEN
		msg = 'The CAVF: ' || in_cavf || ' already exists. Cannot have duplicate states in the system.';
		select * from m.fn_create_logs(fn_name, null, msg, 'FAIL', 'update', id_log, in_run_id) into id_log;
		raise notice '%', msg;
		return '{"cavf_id": 0, "return_msg": "' || msg || '"}';
	END IF;
	
	BEGIN
      insert into m.t_cavf (
			id_cavf,
			cavf,
			cavf_create_time,
			cavf_update_time,
			cavf_created_by,
			cavf_updated_by
        )
		values
		(
			default,
			in_cavf,
			CURRENT_TIMESTAMP,
			CURRENT_TIMESTAMP,
			CURRENT_USER,
			CURRENT_USER
		) returning id_cavf into out_cavf_id;
		
	raise notice '%', out_cavf_id;
	EXCEPTION
		WHEN OTHERS THEN
			GET STACKED DIAGNOSTICS 
								err_msg_text = MESSAGE_TEXT,
								  err_ex_detail = PG_EXCEPTION_DETAIL,
								  err_ex_hint = PG_EXCEPTION_HINT,
								  err_sql_state = RETURNED_SQLSTATE,
								  err_ex_context = pg_exception_context,
								  err_ex_constraint = CONSTRAINT_NAME,
								  err_ex_data_type = PG_DATATYPE_NAME,
								  err_ex_schema = SCHEMA_NAME,
								  err_ex_table = TABLE_NAME,
								  err_ex_col = COLUMN_NAME; 
			raise notice '%,%,%,%,%', err_msg_text, err_ex_detail, err_ex_hint, err_sql_state, err_ex_context;
			-- HANDLE EXCEPTION BY INSERTING INTO 
			return '{"ev_cavf_id": 0, "return_msg": ' || msg || '}';
	END;
	select * from m.fn_create_logs(fn_name, null, 'finished with no issues', 'nothing to report', 'update', id_log, in_run_id) into id_log;
	return '{"cavf_id": ' || out_cavf_id || ', "return_msg": "New CAVF Registered"}';
END;
$$;

CREATE OR REPLACE FUNCTION m.fn_create_county_state(in_st varchar(10), in_county varchar(30), in_run_id varchar(150))
	returns text
    LANGUAGE plpgsql
    AS $$ 
Declare  
	out_county_id integer;
	state_id integer;
	msg text;
	fn_name text;
	id_log integer;
	stack text; 
	err_msg_text text;
	err_ex_detail text;
	err_ex_hint text; 
	err_sql_state text;
	err_ex_context text;
	err_ex_constraint text;
	err_ex_data_type text;
	err_ex_schema text;
	err_ex_table text;
	err_ex_col text;  	
Begin
	GET DIAGNOSTICS stack = PG_CONTEXT; fn_name := substring(stack from 'function (.*?) line');
	in_st = upper(in_st);
	in_county = upper(in_county);
	select * from m.fn_create_logs(fn_name, 'Called to create county: ' || in_county || ' for state: ' || in_st, null, null, 'create', null, in_run_id) into id_log;
	select m.fn_get_state_id(in_st, in_run_id) into state_id;	
	raise notice '%', state_id;

	IF state_id IS NULL THEN
		msg = 'The State ' || in_st || ' does not exists. Please register the state first.';
		select * from m.fn_create_logs(fn_name, null, msg, 'FAIL', 'update', id_log, in_run_id) into id_log;
		raise notice '%', msg;
		return '{"county_id": 0, "return_msg": "' || msg || '"}';
	END IF;
	
	select t.id_county into out_county_id from m.t_counties t where t.id_state = state_id and UPPER(county) = UPPER(in_county);
	
	if out_county_id is NOT NULL then
		msg = 'The combination of State ' || in_st || ' and county ' || in_county || ' already exists. Returning and closing the program.';
		select * from m.fn_create_logs(fn_name, null, msg, 'FAIL', 'update', id_log, in_run_id) into id_log;
		raise notice '%', msg;
		return '{"county_id": 0, "return_msg": "' || msg || '"}';
	end if;		
	
	BEGIN
        insert into m.t_counties (
			id_county,
			county,
			id_state,
			county_create_time,
			county_update_time,
			county_created_by,
			county_updated_by
        ) 
        values
		(
			default,
			in_county,
			state_id, 
			CURRENT_TIMESTAMP,
			CURRENT_TIMESTAMP,
			CURRENT_USER,
			CURRENT_USER
		) returning id_county into out_county_id;
		
	EXCEPTION
		WHEN OTHERS THEN
			GET STACKED DIAGNOSTICS 
								err_msg_text = MESSAGE_TEXT,
								  err_ex_detail = PG_EXCEPTION_DETAIL,
								  err_ex_hint = PG_EXCEPTION_HINT,
								  err_sql_state = RETURNED_SQLSTATE,
								  err_ex_context = pg_exception_context,
								  err_ex_constraint = CONSTRAINT_NAME,
								  err_ex_data_type = PG_DATATYPE_NAME,
								  err_ex_schema = SCHEMA_NAME,
								  err_ex_table = TABLE_NAME,
								  err_ex_col = COLUMN_NAME; 
			raise notice '%,%,%,%,%', err_msg_text, err_ex_detail, err_ex_hint, err_sql_state, err_ex_context;
			-- HANDLE EXCEPTION BY INSERTING INTO 
			return '{"county_id": 0, "return_msg": ' || msg || '}';	
	END;
	
	select * from m.fn_create_logs(fn_name, null, 'finished with no issues', 'nothing to report', 'update', id_log, in_run_id) into id_log;		
	return '{"county_id": ' || out_county_id || ', "return_msg": "New county registered"}';

END;
$$;

CREATE OR REPLACE FUNCTION m.fn_create_census_t(in_st varchar(10), in_county varchar(30), in_census_t bigint, in_run_id varchar(150))
	returns text
    LANGUAGE plpgsql
    AS $$ 
Declare  
	out_census_t_id integer;
	state_id integer;
	county_id integer;
	msg text;
	fn_name text;
	id_log integer;
	stack text; 
	err_msg_text text;
	err_ex_detail text;
	err_ex_hint text; 
	err_sql_state text;
	err_ex_context text;
	err_ex_constraint text;
	err_ex_data_type text;
	err_ex_schema text;
	err_ex_table text;
	err_ex_col text;  	
Begin
	GET DIAGNOSTICS stack = PG_CONTEXT; fn_name := substring(stack from 'function (.*?) line');
	in_st = upper(in_st);	
	in_county = upper(in_county);
	select * from m.fn_create_logs(fn_name, 'Called to create census tract: ' || in_census_t || ' for county: ' || in_county, null, null, 'create', null, in_run_id) into id_log;
	select m.fn_get_state_id(in_st, in_run_id) into state_id;		

	IF state_id IS NULL THEN
		msg = 'The State ' || in_st || ' does not exists. Please register the state first.';
		select * from m.fn_create_logs(fn_name, null, msg, 'FAIL', 'update', id_log, in_run_id) into id_log;
		return '{"census_t_id": 0, "return_msg": "' || msg || '"}';
	END IF;
	
	select t.id_county into county_id from m.t_counties t where t.id_state = state_id and UPPER(county) = UPPER(in_county);
	
	if county_id is NULL then
		msg = 'The combination of State ' || in_st || ' and county ' || in_county || ' does not exists. Please register first.';
		select * from m.fn_create_logs(fn_name, null, msg, 'FAIL', 'update', id_log, in_run_id) into id_log;
		return '{"census_t_id": 0, "return_msg": "' || msg || '"}';
	end if;
	
	select t.id_census_t into out_census_t_id from m.t_census_t t where t.id_county = county_id and census_t = in_census_t;
	
	if out_census_t_id is not NULL then
		msg = 'The combination of State ' || in_st || ', census_t ' || in_census_t || ' and county ' || in_county || ' already exists. Cannot have duplicate in the system.';
		select * from m.fn_create_logs(fn_name, null, msg, 'FAIL', 'update', id_log, in_run_id) into id_log;
		raise notice '%', msg;
		return '{"census_t_id": 0, "return_msg": "' || msg || '"}';
	end if;	
	
	BEGIN
        insert into m.t_census_t (
			id_census_t,
			census_t,
			id_county,
			census_t_create_time,
			census_t_update_time,
			census_t_created_by,
			census_t_updated_by
        )
        values
		(
			default,
			in_census_t,
			county_id,
			CURRENT_TIMESTAMP,
			CURRENT_TIMESTAMP,
			CURRENT_USER,
			CURRENT_USER
		) returning id_census_t into out_census_t_id;
		
	EXCEPTION
		WHEN OTHERS THEN
			GET STACKED DIAGNOSTICS 
								err_msg_text = MESSAGE_TEXT,
								  err_ex_detail = PG_EXCEPTION_DETAIL,
								  err_ex_hint = PG_EXCEPTION_HINT,
								  err_sql_state = RETURNED_SQLSTATE,
								  err_ex_context = pg_exception_context,
								  err_ex_constraint = CONSTRAINT_NAME,
								  err_ex_data_type = PG_DATATYPE_NAME,
								  err_ex_schema = SCHEMA_NAME,
								  err_ex_table = TABLE_NAME,
								  err_ex_col = COLUMN_NAME; 
			raise notice '%,%,%,%,%', err_msg_text, err_ex_detail, err_ex_hint, err_sql_state, err_ex_context;
			-- HANDLE EXCEPTION BY INSERTING INTO 
			return '{"census_t_id": 0, "return_msg": ' || msg || '}';	
	END;
	
	select * from m.fn_create_logs(fn_name, null, 'finished with no issues', 'nothing to report', 'update', id_log, in_run_id) into id_log;		
	return '{"census_t_id": ' || out_census_t_id || ', "return_msg": "New census tract registered"}';

END;
$$;



CREATE OR REPLACE FUNCTION m.fn_create_reg_loc_t(in_st varchar(10), in_county varchar(30), in_city varchar(30), in_zip integer, in_run_id varchar(150))
	returns text
    LANGUAGE plpgsql
    AS $$ 
Declare  
	out_reg_loc_id integer;
	state_id integer;
	county_id integer;
	msg text;
	fn_name text;
	id_log integer;
	stack text; 
	err_msg_text text;
	err_ex_detail text;
	err_ex_hint text; 
	err_sql_state text;
	err_ex_context text;
	err_ex_constraint text;
	err_ex_data_type text;
	err_ex_schema text;
	err_ex_table text;
	err_ex_col text;  	
Begin
	GET DIAGNOSTICS stack = PG_CONTEXT; fn_name := substring(stack from 'function (.*?) line');
	in_st = upper(in_st);	
	select * from m.fn_create_logs(fn_name, 'Called to create registraction location for state: ' || in_st || ', county: ' || in_county || ', city: ' || in_city || ' and zip: ' || in_zip, null, null, 'create', null, in_run_id) into id_log;
	select m.fn_get_state_id(in_st, in_run_id) into state_id;		

	IF state_id IS NULL THEN
		msg = 'The State ' || in_st || ' does not exists. Please register the state first.';
		select * from m.fn_create_logs(fn_name, null, msg, 'FAIL', 'update', id_log, in_run_id) into id_log;
		return '{"reg_loc_id": 0, "return_msg": "' || msg || '"}';
	END IF;
	
	select t.id_county into county_id from m.t_counties t where t.id_state = state_id and UPPER(county) = UPPER(in_county);
	raise notice 'county_id: %', county_id;
	if county_id is NULL then
		msg = 'The combination of State ' || in_st || ' and county ' || in_county || ' does not exists. Please register first.';
		select * from m.fn_create_logs(fn_name, null, msg, 'FAIL', 'update', id_log, in_run_id) into id_log;
		return '{"reg_loc_id": 0, "return_msg": "' || msg || '"}';
	end if;
	
	select t.id_reg_loc into out_reg_loc_id from m.t_reg_loc t where t.id_county = id_county and t.city = in_city and t.zip = zip;
	
	if out_reg_loc_id is not NULL then
		msg = 'The combination of state: ' || in_st || ', county: ' || in_county || ', city: ' || in_city || ' and zip: ' || in_zip || ' already exists. Cannot have duplicate in the system.';
		select * from m.fn_create_logs(fn_name, null, msg, 'FAIL', 'update', id_log, in_run_id) into id_log;
		raise notice '%', msg;
		return '{"reg_loc_id": 0, "return_msg": "' || msg || '"}';
	end if;	
	
	BEGIN
        insert into m.t_reg_loc (
			id_reg_loc,
			city,
			zip,
			id_county,
			reg_loc_create_time,
			reg_loc_update_time,
			reg_loc_created_by,
			reg_loc_updated_by
        )
        values
		(
			default,
			in_city,
			in_zip,
			county_id,			
			CURRENT_TIMESTAMP,
			CURRENT_TIMESTAMP,
			CURRENT_USER,
			CURRENT_USER
		) returning id_reg_loc into out_reg_loc_id;
		
	EXCEPTION
		WHEN OTHERS THEN
			GET STACKED DIAGNOSTICS 
								err_msg_text = MESSAGE_TEXT,
								  err_ex_detail = PG_EXCEPTION_DETAIL,
								  err_ex_hint = PG_EXCEPTION_HINT,
								  err_sql_state = RETURNED_SQLSTATE,
								  err_ex_context = pg_exception_context,
								  err_ex_constraint = CONSTRAINT_NAME,
								  err_ex_data_type = PG_DATATYPE_NAME,
								  err_ex_schema = SCHEMA_NAME,
								  err_ex_table = TABLE_NAME,
								  err_ex_col = COLUMN_NAME; 
			raise notice '%,%,%,%,%', err_msg_text, err_ex_detail, err_ex_hint, err_sql_state, err_ex_context;
			-- HANDLE EXCEPTION BY INSERTING INTO 
			return '{"out_reg_loc_id": 0, "return_msg": ' || msg || '}';	
	END;
	
	select * from m.fn_create_logs(fn_name, null, 'finished with no issues', 'nothing to report', 'update', id_log, in_run_id) into id_log;		
	return '{"reg_loc_id": ' || out_reg_loc_id || ', "return_msg": "New registration location created"}';

END;
$$;
