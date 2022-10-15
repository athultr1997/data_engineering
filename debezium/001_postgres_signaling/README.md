<h1>
    Postgres Signaling
</h1>

<h2>
Running
</h2>

1. Clone the repository:
    ``` bash
    git clone https://github.com/athultr1997/data_engineering
    cd data_engineering
    ```
1. Run docker compose:
    ```
    docker compose up
    ```
1. Wait for some time till all the containers are up and running. Observe the logs to see if everything is up and running properly. Make sure kakfa connector is up and accepting requests.
1. Check to see the data in postgres:
    ```bash
    docker exec -it dp-postgres psql -U postgres
    # Inside psql
    >> \l (To list the databases)
    >> \c test;
    >> select * from mock1;
    ```
1. Open a new terminal and run the following command to register the Debezium Postgres connector with signaling enabled:
    ```bash
    curl --location --request POST 'localhost:8083/connectors/' \
    --header 'Content-Type: application/json' \
    --data-raw '{
        "name": "orders-connector",
        "config": {
            "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
            "plugin.name": "pgoutput",
            "slot.name": "debezium",
            "publication.name": "debezium",
            "database.hostname": "postgres",
            "database.user": "postgres",
            "database.password": "password",
            "database.dbname": "test",
            "database.server.name": "test",
            "tombstones.on.delete": "false",
            "table.include.list": "public.mock1,public.debezium_signal",
            "key.converter": "io.confluent.connect.avro.AvroConverter",
            "value.converter": "io.confluent.connect.avro.AvroConverter",
            "key.converter.schema.registry.url": "http://schema-registry:8081",
            "value.converter.schema.registry.url": "http://schema-registry:8081",
            "value.subject.name.strategy": "io.confluent.kafka.serializers.subject.TopicRecordNameStrategy",
            "signal.data.collection": "public.debezium_signal"
        }
    }'
    ```
1. Check if the connector has been properly launched by going to <a>http://localhost:8084/ui/clusters/dataplatform/connects/debezium/connectors/orders-connector</a> of the Kafka UI. You should see the connector listed at <a>localhost:8084/connectors</a> too. Wait for a couple of seconds for the table mock1 to be snapshotted and the topic to be created. It will have 3 messages currently. The topic can be observed at <a>http://localhost:8084/ui/clusters/dataplatform/topics/test.public.mock1</a>.
1. Send a signal for ad-hoc snapshot:
    ```bash
    docker exec -it dp-postgres psql -U postgres
    # Inside psql
    >> \c test;
    >>  INSERT INTO debezium_signal
        (id, type, data)
        VALUES (
            'ad110',
            'execute-snapshot',
            '{"data-collections": ["public.mock1"]}'
        );
    ```
1. You can check if the snapshotting is happening by looking at logs of docker compose running in the terminal. You can also check by looking at entries in the debezium_signal table.
1. After few seconds check the Kafka UI at <a>http://localhost:8084/ui/clusters/dataplatform/topics/test.public.mock1</a>. It should have 6 messages now currently since we snapshotted the same table again using signaling.
1. Tear down the docker compose:
    ```bash
    docker-compose down --remove-orphans
    ```
