<?php

namespace DoctrineMigrations;

use Doctrine\DBAL\Migrations\AbstractMigration,
    Doctrine\DBAL\Schema\Schema;

class Version20131104141927 extends AbstractMigration
{
    public function up(Schema $schema)
    {
        $this->_addSql("
            CREATE TABLE visitor_detail (
                id serial NOT NULL,
                created_at timestamp without time zone NOT NULL,
                updated_at timestamp without time zone NOT NULL,
                status smallint NOT NULL DEFAULT 0,
                ip_address character varying(96),
                request_method character varying(96),
                user_agent character varying(1024),
                CONSTRAINT visitor_detail_pkey PRIMARY KEY (id)
            ) WITH (OIDS=FALSE)
        ");

        $this->_addSql("CREATE INDEX visitor_detail_status_idx ON visitor_detail (status)");
        $this->_addSql("CREATE INDEX visitor_detail_ip_address_idx ON visitor_detail (ip_address)");
    }

    public function down(Schema $schema)
    {
        $this->_addSql("DROP TABLE IF EXISTS visitor_detail CASCADE");
    }
}
