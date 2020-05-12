CREATE TABLE public.users(
    id serial not null,
    email character varying,
    password character varying,
    time_created timestamp,
    time_modified timestamp,
    PRIMARY KEY (id)
);


CREATE TABLE public.roles
(
    id serial NOT NULL,
    name character varying,
    PRIMARY KEY (id)
);

CREATE TABLE public.users_roles
(
    id serial NOT NULL,
    user_id integer,
    role_id integer,
    PRIMARY KEY (id)
);

ALTER TABLE public.users_roles
    ADD CONSTRAINT users_roles_users_fk FOREIGN KEY (user_id)
    REFERENCES public.users (id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE;

ALTER TABLE public.users_roles
    ADD CONSTRAINT users_roles_roles_fk FOREIGN KEY (role_id)
        REFERENCES public.roles (id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE;

INSERT INTO roles (name) VALUES ('ROLE_USER'), ('ROLE_ADMIN');


CREATE TABLE public.user_dictionaries
(
    id serial not null,
    name character varying,
    pin character varying,
    language character varying,
    time_created timestamp,
    time_modified timestamp,
    owner_id integer,
    PRIMARY KEY (id)
);

ALTER TABLE public.user_dictionaries
    ADD constraint users_fkey FOREIGN KEY (owner_id)
    REFERENCES public.users (id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE;

CREATE TABLE public.user_cards
(
    id serial not null,
    translated_word character varying,
    pin character varying,
    time_created timestamp,
    time_modified timestamp,
    source_dictionary_id integer,
    PRIMARY KEY (id)
);

ALTER TABLE public.user_cards
    ADD CONSTRAINT source_dictionary_fkey FOREIGN KEY (source_dictionary_id)
    REFERENCES public.user_dictionaries (id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE;

CREATE TABLE public.translations
(
    id serial not null,
    pin character varying,
    translation character varying,
    comment character varying,
    transcription character varying,
    usage_sample character varying,
    time_created timestamp,
    time_modified timestamp,
    source_card_id integer,
    PRIMARY KEY (id)
);

ALTER TABLE public.translations
    ADD CONSTRAINT source_card_fkey FOREIGN KEY (source_card_id)
    REFERENCES public.user_cards (id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE;

CREATE TABLE public.dict_shares
(
    id serial not null,
    share_uuid uuid not null,
    time_created timestamp,
    time_modified timestamp,
    activation_time timestamp,
    owner_id integer,
    dict_id integer,
    PRIMARY KEY (id)
);

ALTER TABLE public.dict_shares
    ADD CONSTRAINT dict_share_owner_fkey FOREIGN KEY (owner_id)
    REFERENCES public.users (id) MATCH SIMPLE;

ALTER TABLE public.dict_shares
    ADD CONSTRAINT dict_share_dict_fkey FOREIGN KEY (dict_id)
    REFERENCES public.user_dictionaries (id) MATCH SIMPLE;
