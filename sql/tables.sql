--GRANT USAGE ON SCHEMA timeseries TO lgv_intern_r_gruppe;

--Table timeseries.things
CREATE TABLE timeseries.things (
   t_id integer NOT NULL PRIMARY KEY,
   t_name varchar(50),
   t_description varchar(250),
   t_location_id varchar(50) NOT NULL,
   t_location_name varchar(50) NOT NULL,
   t_location_level varchar(100)
);
SELECT AddGeometryColumn('timeseries', 'things', 'geometry', 25832, 'Geometry', 2);
CREATE INDEX idx_geometry_things ON  timeseries.things USING gist (geometry);
ALTER TABLE timeseries.things ADD CONSTRAINT things_t_name_key UNIQUE (t_name);
GRANT SELECT, TRIGGER ON TABLE timeseries.things TO lgv_intern_r_gruppe;

--Tabelle timeseries.datastreams
CREATE TABLE timeseries.datastreams (
   d_id integer NOT NULL PRIMARY KEY,
   fk_t_id  integer NOT NULL CONSTRAINT constraint_fk_t_id REFERENCES timeseries.things(t_id),
   d_name  varchar(50),
   d_description  varchar(250)
);
ALTER TABLE timeseries.datastreams ADD CONSTRAINT datastreams_d_name_fk_t_id_key UNIQUE (d_name,fk_t_id);
GRANT SELECT, TRIGGER ON TABLE timeseries.datastreams TO lgv_intern_r_gruppe;

--Tabelle timeseries.observations
CREATE TABLE timeseries.observations (
   o_id serial PRIMARY KEY,
   fk_d_id  integer NOT NULL CONSTRAINT constraint_fk_d_id REFERENCES timeseries.datastreams(d_id),
   o_phenomenonTime timestamp WITH TIME ZONE NOT NULL,
   o_result numeric NOT NULL,
   o_insert_date timestamp WITH TIME ZONE,
   o_last_update_date timestamp WITH TIME ZONE
);
SELECT AddGeometryColumn('timeseries', 'observations', 'o_bounded_by', 25832, 'Geometry', 2);
CREATE INDEX idx_geometry_observations ON  timeseries.observations USING gist (o_bounded_by);
ALTER TABLE timeseries.observations ADD CONSTRAINT observations_o_phenomenonTime_fk_d_id_key UNIQUE (o_phenomenonTime,fk_d_id);
CREATE INDEX idx_fk_d_id ON timeseries.observations (fk_d_id);
CREATE INDEX idx_o_phenomenonTime ON timeseries.observations (o_phenomenonTime);
GRANT SELECT, TRIGGER ON TABLE timeseries.observations TO lgv_intern_r_gruppe;
--GRANT ALL ON SEQUENCE timeseries.observations_o_id_seq TO datenintegrator;

--pro Zeitreihe 1 View for 1 WFS Layer
CREATE OR REPLACE VIEW timeseries.wohnungslose_jep AS SELECT o_id as id, o_phenomenonTime::date as phenomenonTime, o_result as result, o_bounded_by as geom, d_name as parameter FROM timeseries.observations INNER JOIN timeseries.datastreams ON fk_d_id = d_id WHERE fk_d_id = 1 ORDER BY o_phenomenonTime;
GRANT SELECT, TRIGGER ON TABLE timeseries.wohnungslose_jep TO lgv_intern_r_gruppe;
CREATE OR REPLACE VIEW timeseries.wohnberechtigte_zuwanderer AS SELECT o_id as id, o_phenomenonTime::date as phenomenonTime, o_result as result, o_bounded_by as geom, d_name as parameter FROM timeseries.observations INNER JOIN timeseries.datastreams ON fk_d_id = d_id WHERE fk_d_id = 2 ORDER BY o_phenomenonTime;
GRANT SELECT, TRIGGER ON TABLE timeseries.wohnberechtigte_zuwanderer TO lgv_intern_r_gruppe;
CREATE OR REPLACE VIEW timeseries.nicht_wohnberechtigte_zuwanderer AS SELECT o_id as id, o_phenomenonTime::date as phenomenonTime, o_result as result, o_bounded_by as geom, d_name as parameter FROM timeseries.observations INNER JOIN timeseries.datastreams ON fk_d_id = d_id WHERE fk_d_id = 3 ORDER BY o_phenomenonTime;
GRANT SELECT, TRIGGER ON TABLE timeseries.nicht_wohnberechtigte_zuwanderer TO lgv_intern_r_gruppe;
CREATE OR REPLACE VIEW timeseries.summe_zuwanderer_wohnungslose AS SELECT o_id as id, o_phenomenonTime::date as phenomenonTime, o_result as result, o_bounded_by as geom, d_name as parameter FROM timeseries.observations INNER JOIN timeseries.datastreams ON fk_d_id = d_id WHERE fk_d_id = 4 ORDER BY o_phenomenonTime;
GRANT SELECT, TRIGGER ON TABLE timeseries.summe_zuwanderer_wohnungslose TO lgv_intern_r_gruppe;
CREATE OR REPLACE VIEW timeseries.zuzuege_oeru AS SELECT o_id as id, o_phenomenonTime::date as phenomenonTime, o_result as result, o_bounded_by as geom, d_name as parameter FROM timeseries.observations INNER JOIN timeseries.datastreams ON fk_d_id = d_id WHERE fk_d_id = 5 ORDER BY o_phenomenonTime;
GRANT SELECT, TRIGGER ON TABLE timeseries.zuzuege_oeru TO lgv_intern_r_gruppe;
CREATE OR REPLACE VIEW timeseries.davon_zuzuege_aus_zea_za_ea AS SELECT o_id as id, o_phenomenonTime::date as phenomenonTime, o_result as result, o_bounded_by as geom, d_name as parameter FROM timeseries.observations INNER JOIN timeseries.datastreams ON fk_d_id = d_id WHERE fk_d_id = 6 ORDER BY o_phenomenonTime;
GRANT SELECT, TRIGGER ON TABLE timeseries.davon_zuzuege_aus_zea_za_ea TO lgv_intern_r_gruppe;
CREATE OR REPLACE VIEW timeseries.auszuege_oeru AS SELECT o_id as id, o_phenomenonTime::date as phenomenonTime, o_result as result, o_bounded_by as geom, d_name as parameter FROM timeseries.observations INNER JOIN timeseries.datastreams ON fk_d_id = d_id WHERE fk_d_id = 7 ORDER BY o_phenomenonTime;
GRANT SELECT, TRIGGER ON TABLE timeseries.auszuege_oeru TO lgv_intern_r_gruppe;
CREATE OR REPLACE VIEW timeseries.differenz_zugzug_auszug_oeru AS SELECT o_id as id, o_phenomenonTime::date as phenomenonTime, o_result as result, o_bounded_by as geom, d_name as parameter FROM timeseries.observations INNER JOIN timeseries.datastreams ON fk_d_id = d_id WHERE fk_d_id = 8 ORDER BY o_phenomenonTime;
GRANT SELECT, TRIGGER ON TABLE timeseries.differenz_zugzug_auszug_oeru TO lgv_intern_r_gruppe;
CREATE OR REPLACE VIEW timeseries.zuzuege_ausserhalb_hh AS SELECT o_id as id, o_phenomenonTime::date as phenomenonTime, o_result as result, o_bounded_by as geom, d_name as parameter FROM timeseries.observations INNER JOIN timeseries.datastreams ON fk_d_id = d_id WHERE fk_d_id = 9 ORDER BY o_phenomenonTime;
GRANT SELECT, TRIGGER ON TABLE timeseries.zuzuege_ausserhalb_hh TO lgv_intern_r_gruppe;
CREATE OR REPLACE VIEW timeseries.davon_familiennachzuege AS SELECT o_id as id, o_phenomenonTime::date as phenomenonTime, o_result as result, o_bounded_by as geom, d_name as parameter FROM timeseries.observations INNER JOIN timeseries.datastreams ON fk_d_id = d_id WHERE fk_d_id = 10 ORDER BY o_phenomenonTime;
GRANT SELECT, TRIGGER ON TABLE timeseries.davon_familiennachzuege TO lgv_intern_r_gruppe;
CREATE OR REPLACE VIEW timeseries.belegung_zea_ea AS SELECT o_id as id, o_phenomenonTime::date as phenomenonTime, o_result as result, o_bounded_by as geom, d_name as parameter FROM timeseries.observations INNER JOIN timeseries.datastreams ON fk_d_id = d_id WHERE fk_d_id = 11 ORDER BY o_phenomenonTime;
GRANT SELECT, TRIGGER ON TABLE timeseries.belegung_zea_ea TO lgv_intern_r_gruppe;
CREATE OR REPLACE VIEW timeseries.belegung_oeru AS SELECT o_id as id, o_phenomenonTime::date as phenomenonTime, o_result as result, o_bounded_by as geom, d_name as parameter FROM timeseries.observations INNER JOIN timeseries.datastreams ON fk_d_id = d_id WHERE fk_d_id = 12 ORDER BY o_phenomenonTime;
GRANT SELECT, TRIGGER ON TABLE timeseries.belegung_oeru TO lgv_intern_r_gruppe;
