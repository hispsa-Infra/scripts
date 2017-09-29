-- Database generated with pgModeler (PostgreSQL Database Modeler).
-- pgModeler  version: 0.9.0
-- PostgreSQL version: 9.5
-- Project Site: pgmodeler.com.br
-- Model Author: ---


-- Database creation must be done outside an multicommand file.
-- These commands were put in this file only for convenience.
-- -- object: new_database | type: DATABASE --
-- -- DROP DATABASE IF EXISTS new_database;
-- CREATE DATABASE new_database
-- ;
-- -- ddl-end --
-- 

-- object: public.hosts | type: TABLE --
-- DROP TABLE IF EXISTS public.hosts CASCADE;
CREATE TABLE public.hosts(
	hosts_pk serial NOT NULL,
	host_name varchar(255) NOT NULL,
	ip_external varchar(15),
	ip_internal varchar(15),
	CONSTRAINT hosts_pk PRIMARY KEY (hosts_pk)

);
-- ddl-end --
ALTER TABLE public.hosts OWNER TO postgres;
-- ddl-end --

-- object: public.db_server | type: TABLE --
-- DROP TABLE IF EXISTS public.db_server CASCADE;
CREATE TABLE public.db_server(
	db_server_pk serial NOT NULL,
	fk_hosts_pk smallint NOT NULL,
	port integer,
	CONSTRAINT db_server_pk PRIMARY KEY (db_server_pk)

);
-- ddl-end --
ALTER TABLE public.db_server OWNER TO postgres;
-- ddl-end --

-- object: public.db | type: TABLE --
-- DROP TABLE IF EXISTS public.db CASCADE;
CREATE TABLE public.db(
	db_pk serial NOT NULL,
	db_server_fk smallint NOT NULL,
	db_name varchar(255),
	CONSTRAINT db_pk PRIMARY KEY (db_pk)

);
-- ddl-end --
ALTER TABLE public.db OWNER TO postgres;
-- ddl-end --

-- object: public.db_connection | type: TABLE --
-- DROP TABLE IF EXISTS public.db_connection CASCADE;
CREATE TABLE public.db_connection(
	db_connection_pk serial NOT NULL,
	db_fk smallint,
	db_connection_username varchar(255),
	db_connection_password varchar(255),
	CONSTRAINT db_connection_pk PRIMARY KEY (db_connection_pk)

);
-- ddl-end --
ALTER TABLE public.db_connection OWNER TO postgres;
-- ddl-end --

-- object: public.database_connections | type: VIEW --
-- DROP VIEW IF EXISTS public.database_connections CASCADE;
CREATE VIEW public.database_connections
AS 

SELECT
   public.hosts.host_name AS "Server Name",
   public.hosts.ip_internal AS "IP Address",
   public.db.db_name AS "Database Name",
   public.db_connection.db_connection_username AS "Username",
   public.db_connection.db_connection_password AS "Password";
-- ddl-end --
ALTER VIEW public.database_connections OWNER TO postgres;
-- ddl-end --

-- object: fk_db_server_hosts_pk | type: CONSTRAINT --
-- ALTER TABLE public.db_server DROP CONSTRAINT IF EXISTS fk_db_server_hosts_pk CASCADE;
ALTER TABLE public.db_server ADD CONSTRAINT fk_db_server_hosts_pk FOREIGN KEY (fk_hosts_pk)
REFERENCES public.hosts (hosts_pk) MATCH FULL
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: fk_db_db_server_pk | type: CONSTRAINT --
-- ALTER TABLE public.db DROP CONSTRAINT IF EXISTS fk_db_db_server_pk CASCADE;
ALTER TABLE public.db ADD CONSTRAINT fk_db_db_server_pk FOREIGN KEY (db_server_fk)
REFERENCES public.db_server (db_server_pk) MATCH FULL
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: fk_db_connection_db_pk | type: CONSTRAINT --
-- ALTER TABLE public.db_connection DROP CONSTRAINT IF EXISTS fk_db_connection_db_pk CASCADE;
ALTER TABLE public.db_connection ADD CONSTRAINT fk_db_connection_db_pk FOREIGN KEY (db_fk)
REFERENCES public.db (db_pk) MATCH FULL
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --


