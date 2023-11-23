--
-- PostgreSQL database dump
--

-- Dumped from database version 16.1
-- Dumped by pg_dump version 16.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: insert_position(integer, real, real, real, bigint); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.insert_position(IN boat_id integer, IN latitude real, IN longitude real, IN heading real, IN route_id bigint DEFAULT 0)
    LANGUAGE plpgsql
    AS $$DECLARE	
	new_pos_id	BIGINT;	
BEGIN 
	INSERT INTO positions (boat_id, latitude, longitude, heading) 
	VALUES (boat_id, latitude, longitude, heading)
	RETURNING "id" INTO new_pos_id;
	
	IF @route_id != 0 THEN
		INSERT INTO route_positions (route_id, position_id) 
		VALUES (route_id, new_pos_id);
	END IF;
END
$$;


ALTER PROCEDURE public.insert_position(IN boat_id integer, IN latitude real, IN longitude real, IN heading real, IN route_id bigint) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: boats; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.boats (
    id integer NOT NULL,
    name character varying(40) NOT NULL
);


ALTER TABLE public.boats OWNER TO postgres;

--
-- Name: boats_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.boats ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.boats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: positions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.positions (
    id bigint NOT NULL,
    boat_id integer NOT NULL,
    "time" timestamp(3) without time zone DEFAULT now() NOT NULL,
    latitude real NOT NULL,
    longitude real NOT NULL,
    heading real NOT NULL
);


ALTER TABLE public.positions OWNER TO postgres;

--
-- Name: positions_seq_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.positions ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.positions_seq_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: route_positions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.route_positions (
    route_id bigint NOT NULL,
    position_id bigint NOT NULL
);


ALTER TABLE public.route_positions OWNER TO postgres;

--
-- Name: routes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.routes (
    id bigint NOT NULL,
    boat_id integer NOT NULL
);


ALTER TABLE public.routes OWNER TO postgres;

--
-- Name: route_info; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.route_info AS
 SELECT routes.id AS route_id,
    positions."time",
    positions.latitude,
    positions.longitude,
    positions.heading
   FROM ((public.route_positions
     LEFT JOIN public.routes ON ((route_positions.route_id = routes.id)))
     LEFT JOIN public.positions ON ((route_positions.position_id = positions.id)))
  ORDER BY positions."time";


ALTER VIEW public.route_info OWNER TO postgres;

--
-- Name: route_list; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.route_list AS
 SELECT routes.id,
    routes.boat_id,
    route_times.start_time,
    route_times.end_time
   FROM (public.routes
     JOIN ( SELECT route_positions.route_id,
            min(positions."time") AS start_time,
            max(positions."time") AS end_time
           FROM (public.route_positions
             LEFT JOIN public.positions ON ((route_positions.position_id = positions.id)))
          GROUP BY route_positions.route_id) route_times ON ((routes.id = route_times.route_id)))
  ORDER BY route_times.start_time DESC;


ALTER VIEW public.route_list OWNER TO postgres;

--
-- Name: routes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.routes ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.routes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: boats boats_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.boats
    ADD CONSTRAINT boats_pkey PRIMARY KEY (id);


--
-- Name: positions positions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.positions
    ADD CONSTRAINT positions_pkey PRIMARY KEY (boat_id, "time");


--
-- Name: route_positions route_positions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.route_positions
    ADD CONSTRAINT route_positions_pkey PRIMARY KEY (route_id, position_id);


--
-- Name: routes routes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_pkey PRIMARY KEY (id);


--
-- Name: positions unique_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.positions
    ADD CONSTRAINT unique_id UNIQUE (id);


--
-- Name: fki_boat_fk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_boat_fk ON public.routes USING btree (boat_id);


--
-- Name: fki_pos_fk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_pos_fk ON public.route_positions USING btree (position_id);


--
-- Name: fki_position_fk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_position_fk ON public.route_positions USING btree (position_id);


--
-- Name: positions boat_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.positions
    ADD CONSTRAINT boat_fk FOREIGN KEY (boat_id) REFERENCES public.boats(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: routes boat_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT boat_fk FOREIGN KEY (boat_id) REFERENCES public.boats(id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;


--
-- Name: route_positions pos_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.route_positions
    ADD CONSTRAINT pos_fk FOREIGN KEY (position_id) REFERENCES public.positions(id) NOT VALID;


--
-- Name: route_positions route_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.route_positions
    ADD CONSTRAINT route_fk FOREIGN KEY (route_id) REFERENCES public.routes(id);


--
-- PostgreSQL database dump complete
--

