SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: appointments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.appointments (
    id bigint NOT NULL,
    office_id bigint,
    prosecutor_id bigint NOT NULL,
    genpro_gov_sk_prosecutors_list_id bigint,
    started_at timestamp without time zone NOT NULL,
    ended_at timestamp without time zone,
    type integer NOT NULL,
    place character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: appointments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.appointments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: appointments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.appointments_id_seq OWNED BY public.appointments.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: crimes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.crimes (
    id bigint NOT NULL,
    year integer NOT NULL,
    metric character varying NOT NULL,
    paragraph character varying,
    count integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: crimes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.crimes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: crimes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.crimes_id_seq OWNED BY public.crimes.id;


--
-- Name: decrees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.decrees (
    id bigint NOT NULL,
    genpro_gov_sk_decree_id bigint NOT NULL,
    office_id bigint,
    prosecutor_id bigint,
    url character varying NOT NULL,
    number character varying NOT NULL,
    file_info character varying NOT NULL,
    file_type integer NOT NULL,
    effective_on date NOT NULL,
    published_on date NOT NULL,
    file_number character varying NOT NULL,
    resolution character varying NOT NULL,
    means_of_resolution character varying,
    text text NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    paragraph_id bigint,
    paragraph_section character varying
);


--
-- Name: decrees_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.decrees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: decrees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.decrees_id_seq OWNED BY public.decrees.id;


--
-- Name: employees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.employees (
    id bigint NOT NULL,
    office_id bigint NOT NULL,
    prosecutor_id bigint,
    name character varying NOT NULL,
    name_parts jsonb NOT NULL,
    "position" character varying(1024) NOT NULL,
    rank integer NOT NULL,
    phone character varying,
    disabled_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: employees_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.employees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: employees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.employees_id_seq OWNED BY public.employees.id;


--
-- Name: genpro_gov_sk_declarations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.genpro_gov_sk_declarations (
    id bigint NOT NULL,
    data jsonb NOT NULL,
    file bytea NOT NULL,
    digest character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: genpro_gov_sk_declarations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.genpro_gov_sk_declarations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: genpro_gov_sk_declarations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.genpro_gov_sk_declarations_id_seq OWNED BY public.genpro_gov_sk_declarations.id;


--
-- Name: genpro_gov_sk_decrees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.genpro_gov_sk_decrees (
    id bigint NOT NULL,
    data jsonb NOT NULL,
    file bytea NOT NULL,
    digest character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: genpro_gov_sk_decrees_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.genpro_gov_sk_decrees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: genpro_gov_sk_decrees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.genpro_gov_sk_decrees_id_seq OWNED BY public.genpro_gov_sk_decrees.id;


--
-- Name: genpro_gov_sk_offices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.genpro_gov_sk_offices (
    id bigint NOT NULL,
    data jsonb NOT NULL,
    file bytea NOT NULL,
    digest character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: genpro_gov_sk_offices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.genpro_gov_sk_offices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: genpro_gov_sk_offices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.genpro_gov_sk_offices_id_seq OWNED BY public.genpro_gov_sk_offices.id;


--
-- Name: genpro_gov_sk_prosecutors_lists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.genpro_gov_sk_prosecutors_lists (
    id bigint NOT NULL,
    data jsonb NOT NULL,
    file bytea NOT NULL,
    digest character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: genpro_gov_sk_prosecutors_lists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.genpro_gov_sk_prosecutors_lists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: genpro_gov_sk_prosecutors_lists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.genpro_gov_sk_prosecutors_lists_id_seq OWNED BY public.genpro_gov_sk_prosecutors_lists.id;


--
-- Name: offices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.offices (
    id bigint NOT NULL,
    genpro_gov_sk_office_id bigint,
    name character varying NOT NULL,
    type integer,
    address character varying(1024) NOT NULL,
    additional_address character varying(1024),
    zipcode character varying NOT NULL,
    city character varying NOT NULL,
    phone character varying NOT NULL,
    fax character varying,
    email character varying,
    electronic_registry character varying,
    registry jsonb NOT NULL,
    latitude double precision NOT NULL,
    longitude double precision NOT NULL,
    destroyed_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    news jsonb,
    decrees_count bigint DEFAULT 0
);


--
-- Name: offices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.offices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: offices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.offices_id_seq OWNED BY public.offices.id;


--
-- Name: prosecutors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prosecutors (
    id bigint NOT NULL,
    genpro_gov_sk_prosecutors_list_id bigint,
    name character varying NOT NULL,
    name_parts jsonb NOT NULL,
    declarations jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    news jsonb,
    decrees_count bigint DEFAULT 0
);


--
-- Name: offices_search; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.offices_search AS
 SELECT offices.id,
    lower(public.unaccent((offices.name)::text)) AS name,
    lower(public.unaccent((offices.address)::text)) AS address,
    lower(public.unaccent((offices.city)::text)) AS city,
    lower(public.unaccent((employees.name)::text)) AS employee
   FROM (((public.offices
     LEFT JOIN public.employees ON ((employees.office_id = offices.id)))
     LEFT JOIN public.appointments ON (((appointments.office_id = offices.id) AND (appointments.ended_at IS NULL))))
     LEFT JOIN public.prosecutors ON ((appointments.prosecutor_id = prosecutors.id)))
  WITH NO DATA;


--
-- Name: paragraphs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.paragraphs (
    id bigint NOT NULL,
    type integer NOT NULL,
    name character varying NOT NULL,
    value character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: paragraphs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.paragraphs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: paragraphs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.paragraphs_id_seq OWNED BY public.paragraphs.id;


--
-- Name: paragraphs_search; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.paragraphs_search AS
 SELECT id,
    lower(public.unaccent((name)::text)) AS name
   FROM public.paragraphs
  WITH NO DATA;


--
-- Name: prosecutors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.prosecutors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: prosecutors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.prosecutors_id_seq OWNED BY public.prosecutors.id;


--
-- Name: prosecutors_search; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.prosecutors_search AS
 SELECT prosecutors.id,
    lower(public.unaccent((prosecutors.name)::text)) AS name,
    lower(public.unaccent((offices.name)::text)) AS office,
    lower(public.unaccent((prosecutors.declarations)::text)) AS declarations,
    lower(public.unaccent((offices.city)::text)) AS city
   FROM ((public.prosecutors
     LEFT JOIN public.appointments ON (((appointments.prosecutor_id = prosecutors.id) AND (appointments.ended_at IS NULL))))
     LEFT JOIN public.offices ON ((appointments.office_id = offices.id)))
  WITH NO DATA;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: statistics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.statistics (
    id bigint NOT NULL,
    office_id bigint NOT NULL,
    year integer NOT NULL,
    metric character varying NOT NULL,
    paragraph character varying,
    count integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: statistics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.statistics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: statistics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.statistics_id_seq OWNED BY public.statistics.id;


--
-- Name: appointments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointments ALTER COLUMN id SET DEFAULT nextval('public.appointments_id_seq'::regclass);


--
-- Name: crimes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crimes ALTER COLUMN id SET DEFAULT nextval('public.crimes_id_seq'::regclass);


--
-- Name: decrees id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decrees ALTER COLUMN id SET DEFAULT nextval('public.decrees_id_seq'::regclass);


--
-- Name: employees id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees ALTER COLUMN id SET DEFAULT nextval('public.employees_id_seq'::regclass);


--
-- Name: genpro_gov_sk_declarations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.genpro_gov_sk_declarations ALTER COLUMN id SET DEFAULT nextval('public.genpro_gov_sk_declarations_id_seq'::regclass);


--
-- Name: genpro_gov_sk_decrees id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.genpro_gov_sk_decrees ALTER COLUMN id SET DEFAULT nextval('public.genpro_gov_sk_decrees_id_seq'::regclass);


--
-- Name: genpro_gov_sk_offices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.genpro_gov_sk_offices ALTER COLUMN id SET DEFAULT nextval('public.genpro_gov_sk_offices_id_seq'::regclass);


--
-- Name: genpro_gov_sk_prosecutors_lists id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.genpro_gov_sk_prosecutors_lists ALTER COLUMN id SET DEFAULT nextval('public.genpro_gov_sk_prosecutors_lists_id_seq'::regclass);


--
-- Name: offices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.offices ALTER COLUMN id SET DEFAULT nextval('public.offices_id_seq'::regclass);


--
-- Name: paragraphs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paragraphs ALTER COLUMN id SET DEFAULT nextval('public.paragraphs_id_seq'::regclass);


--
-- Name: prosecutors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prosecutors ALTER COLUMN id SET DEFAULT nextval('public.prosecutors_id_seq'::regclass);


--
-- Name: statistics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.statistics ALTER COLUMN id SET DEFAULT nextval('public.statistics_id_seq'::regclass);


--
-- Name: appointments appointments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: crimes crimes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crimes
    ADD CONSTRAINT crimes_pkey PRIMARY KEY (id);


--
-- Name: decrees decrees_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decrees
    ADD CONSTRAINT decrees_pkey PRIMARY KEY (id);


--
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (id);


--
-- Name: genpro_gov_sk_declarations genpro_gov_sk_declarations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.genpro_gov_sk_declarations
    ADD CONSTRAINT genpro_gov_sk_declarations_pkey PRIMARY KEY (id);


--
-- Name: genpro_gov_sk_decrees genpro_gov_sk_decrees_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.genpro_gov_sk_decrees
    ADD CONSTRAINT genpro_gov_sk_decrees_pkey PRIMARY KEY (id);


--
-- Name: genpro_gov_sk_offices genpro_gov_sk_offices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.genpro_gov_sk_offices
    ADD CONSTRAINT genpro_gov_sk_offices_pkey PRIMARY KEY (id);


--
-- Name: genpro_gov_sk_prosecutors_lists genpro_gov_sk_prosecutors_lists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.genpro_gov_sk_prosecutors_lists
    ADD CONSTRAINT genpro_gov_sk_prosecutors_lists_pkey PRIMARY KEY (id);


--
-- Name: offices offices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.offices
    ADD CONSTRAINT offices_pkey PRIMARY KEY (id);


--
-- Name: paragraphs paragraphs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paragraphs
    ADD CONSTRAINT paragraphs_pkey PRIMARY KEY (id);


--
-- Name: prosecutors prosecutors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prosecutors
    ADD CONSTRAINT prosecutors_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: statistics statistics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.statistics
    ADD CONSTRAINT statistics_pkey PRIMARY KEY (id);


--
-- Name: index_appointments_on_genpro_gov_sk_prosecutors_list_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_appointments_on_genpro_gov_sk_prosecutors_list_id ON public.appointments USING btree (genpro_gov_sk_prosecutors_list_id);


--
-- Name: index_appointments_on_office_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_appointments_on_office_id ON public.appointments USING btree (office_id);


--
-- Name: index_appointments_on_prosecutor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_appointments_on_prosecutor_id ON public.appointments USING btree (prosecutor_id);


--
-- Name: index_crimes_on_year_and_metric_and_paragraph; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_crimes_on_year_and_metric_and_paragraph ON public.crimes USING btree (year, metric, paragraph);


--
-- Name: index_decrees_on_effective_on; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_decrees_on_effective_on ON public.decrees USING btree (effective_on);


--
-- Name: index_decrees_on_genpro_gov_sk_decree_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_decrees_on_genpro_gov_sk_decree_id ON public.decrees USING btree (genpro_gov_sk_decree_id);


--
-- Name: index_decrees_on_office_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_decrees_on_office_id ON public.decrees USING btree (office_id);


--
-- Name: index_decrees_on_prosecutor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_decrees_on_prosecutor_id ON public.decrees USING btree (prosecutor_id);


--
-- Name: index_decrees_on_published_on; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_decrees_on_published_on ON public.decrees USING btree (published_on);


--
-- Name: index_decrees_on_url; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_decrees_on_url ON public.decrees USING btree (url);


--
-- Name: index_employees_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_employees_on_name ON public.employees USING btree (name);


--
-- Name: index_employees_on_name_and_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_employees_on_name_and_position ON public.employees USING btree (name, "position");


--
-- Name: index_employees_on_name_parts; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_employees_on_name_parts ON public.employees USING btree (name_parts);


--
-- Name: index_employees_on_office_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_employees_on_office_id ON public.employees USING btree (office_id);


--
-- Name: index_employees_on_office_id_and_disabled_at_and_rank; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_employees_on_office_id_and_disabled_at_and_rank ON public.employees USING btree (office_id, disabled_at, rank) WHERE (disabled_at IS NULL);


--
-- Name: index_employees_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_employees_on_position ON public.employees USING btree ("position");


--
-- Name: index_employees_on_prosecutor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_employees_on_prosecutor_id ON public.employees USING btree (prosecutor_id);


--
-- Name: index_employees_on_rank; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_employees_on_rank ON public.employees USING btree (rank);


--
-- Name: index_genpro_gov_sk_declarations_on_digest; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_genpro_gov_sk_declarations_on_digest ON public.genpro_gov_sk_declarations USING btree (digest);


--
-- Name: index_genpro_gov_sk_decrees_on_digest; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_genpro_gov_sk_decrees_on_digest ON public.genpro_gov_sk_decrees USING btree (digest);


--
-- Name: index_genpro_gov_sk_offices_on_digest; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_genpro_gov_sk_offices_on_digest ON public.genpro_gov_sk_offices USING btree (digest);


--
-- Name: index_genpro_gov_sk_prosecutors_lists_on_digest; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_genpro_gov_sk_prosecutors_lists_on_digest ON public.genpro_gov_sk_prosecutors_lists USING btree (digest);


--
-- Name: index_offices_on_city; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_offices_on_city ON public.offices USING btree (city);


--
-- Name: index_offices_on_destroyed_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_offices_on_destroyed_at ON public.offices USING btree (destroyed_at);


--
-- Name: index_offices_on_genpro_gov_sk_office_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_offices_on_genpro_gov_sk_office_id ON public.offices USING btree (genpro_gov_sk_office_id);


--
-- Name: index_offices_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_offices_on_name ON public.offices USING btree (name);


--
-- Name: index_offices_on_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_offices_on_type ON public.offices USING btree (type);


--
-- Name: index_offices_on_unique_general_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_offices_on_unique_general_type ON public.offices USING btree (type) WHERE (type = 0);


--
-- Name: index_offices_on_unique_specialized_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_offices_on_unique_specialized_type ON public.offices USING btree (type) WHERE (type = 1);


--
-- Name: index_offices_search_on_address; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_offices_search_on_address ON public.offices_search USING gin (address public.gin_trgm_ops);


--
-- Name: index_offices_search_on_city; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_offices_search_on_city ON public.offices_search USING gin (city public.gin_trgm_ops);


--
-- Name: index_offices_search_on_employee; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_offices_search_on_employee ON public.offices_search USING gin (employee public.gin_trgm_ops);


--
-- Name: index_offices_search_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_offices_search_on_name ON public.offices_search USING gin (name public.gin_trgm_ops);


--
-- Name: index_paragraphs_on_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_paragraphs_on_type ON public.paragraphs USING btree (type);


--
-- Name: index_paragraphs_on_value; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_paragraphs_on_value ON public.paragraphs USING btree (value);


--
-- Name: index_paragraphs_search_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_paragraphs_search_on_name ON public.paragraphs_search USING gin (name public.gin_trgm_ops);


--
-- Name: index_prosecutors_on_genpro_gov_sk_prosecutors_list_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_prosecutors_on_genpro_gov_sk_prosecutors_list_id ON public.prosecutors USING btree (genpro_gov_sk_prosecutors_list_id);


--
-- Name: index_prosecutors_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_prosecutors_on_name ON public.prosecutors USING btree (name);


--
-- Name: index_prosecutors_on_name_parts; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_prosecutors_on_name_parts ON public.prosecutors USING btree (name_parts);


--
-- Name: index_prosecutors_search_on_city; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_prosecutors_search_on_city ON public.prosecutors_search USING gin (city public.gin_trgm_ops);


--
-- Name: index_prosecutors_search_on_declarations; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_prosecutors_search_on_declarations ON public.prosecutors_search USING gin (declarations public.gin_trgm_ops);


--
-- Name: index_prosecutors_search_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_prosecutors_search_on_name ON public.prosecutors_search USING gin (name public.gin_trgm_ops);


--
-- Name: index_prosecutors_search_on_office; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_prosecutors_search_on_office ON public.prosecutors_search USING gin (office public.gin_trgm_ops);


--
-- Name: index_statistics_on_metric; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_statistics_on_metric ON public.statistics USING btree (metric);


--
-- Name: index_statistics_on_office_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_statistics_on_office_id ON public.statistics USING btree (office_id);


--
-- Name: index_statistics_on_paragraph; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_statistics_on_paragraph ON public.statistics USING btree (paragraph);


--
-- Name: index_statistics_on_paragraph_and_metric; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_statistics_on_paragraph_and_metric ON public.statistics USING btree (paragraph, metric);


--
-- Name: index_statistics_on_present_paragraph; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_statistics_on_present_paragraph ON public.statistics USING btree (paragraph) WHERE (paragraph IS NOT NULL);


--
-- Name: index_statistics_on_year; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_statistics_on_year ON public.statistics USING btree (year);


--
-- Name: index_statistics_on_year_and_office_id_and_metric_and_paragraph; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_statistics_on_year_and_office_id_and_metric_and_paragraph ON public.statistics USING btree (year, office_id, metric, paragraph);


--
-- Name: appointments fk_rails_1c5c4ccd87; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT fk_rails_1c5c4ccd87 FOREIGN KEY (genpro_gov_sk_prosecutors_list_id) REFERENCES public.genpro_gov_sk_prosecutors_lists(id);


--
-- Name: offices fk_rails_1ebbc31836; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.offices
    ADD CONSTRAINT fk_rails_1ebbc31836 FOREIGN KEY (genpro_gov_sk_office_id) REFERENCES public.genpro_gov_sk_offices(id);


--
-- Name: decrees fk_rails_7dd470dccf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decrees
    ADD CONSTRAINT fk_rails_7dd470dccf FOREIGN KEY (office_id) REFERENCES public.offices(id);


--
-- Name: appointments fk_rails_c1f7b5cbe8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT fk_rails_c1f7b5cbe8 FOREIGN KEY (office_id) REFERENCES public.offices(id);


--
-- Name: employees fk_rails_c21e1b06dd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT fk_rails_c21e1b06dd FOREIGN KEY (prosecutor_id) REFERENCES public.prosecutors(id);


--
-- Name: appointments fk_rails_d26835c928; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT fk_rails_d26835c928 FOREIGN KEY (prosecutor_id) REFERENCES public.prosecutors(id);


--
-- Name: decrees fk_rails_d481c0e8b4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decrees
    ADD CONSTRAINT fk_rails_d481c0e8b4 FOREIGN KEY (genpro_gov_sk_decree_id) REFERENCES public.genpro_gov_sk_decrees(id);


--
-- Name: prosecutors fk_rails_d9de72e216; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prosecutors
    ADD CONSTRAINT fk_rails_d9de72e216 FOREIGN KEY (genpro_gov_sk_prosecutors_list_id) REFERENCES public.genpro_gov_sk_prosecutors_lists(id);


--
-- Name: employees fk_rails_e87ac712d3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT fk_rails_e87ac712d3 FOREIGN KEY (office_id) REFERENCES public.offices(id);


--
-- Name: decrees fk_rails_f2b636070c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decrees
    ADD CONSTRAINT fk_rails_f2b636070c FOREIGN KEY (prosecutor_id) REFERENCES public.prosecutors(id);


--
-- Name: statistics fk_rails_fe111e9b20; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.statistics
    ADD CONSTRAINT fk_rails_fe111e9b20 FOREIGN KEY (office_id) REFERENCES public.offices(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20231212171612'),
('20231118102752'),
('20231118093212'),
('20230511210024'),
('20230505075916'),
('20230505075812'),
('20230505061736'),
('20230504185426'),
('20230430185610'),
('20230430165610'),
('20230430152301'),
('20220416164722'),
('20201202222245'),
('20201111095839'),
('20201110205753'),
('20200922211054'),
('20200922205548'),
('20200914215818'),
('20200904115350'),
('20200831151843'),
('20200704140315'),
('20200622210209'),
('20200620081502'),
('20200531155004'),
('20200531151706'),
('20200531110908'),
('20200524091918'),
('20200504104808');

