# Database Adapter Method Reference

This comprehensive reference delineates the indispensable methods necessary for implementing database adapters tailored
to various database engines.

## Key Points

Each adapter is required to implement the following methods, adhering to the specified parameters. Replace
<database_engine> with the precise name of the engine (e.g., mysql_vault_configure). Every method should encapsulate the
logic specific to the respective database engine to accomplish the intended functionality.

## Required Methods

### <database_engine>_vault_configure

This method configures the Vault database secrets engine for the designated database, facilitating dynamic generation of
database credentials based on configured roles.

| Parameter                 | Description                                                   |
|---------------------------|---------------------------------------------------------------|
| __database_name           | Name of the database to be configured                         |
| __database_hostname       | Hostname of the database server                               |
| __database_port           | Port number of the database server                            |
| __database_options        | (Optional): Additional configuration options for the database |
| __database_mode           | Mode of access for the database: `ro` or `rw`                 |
| __database_vault_username | Username of the vault database user                           |
| __database_vault_password | Password of the vault database user                           |
| __default_ttl             | Default lease Time-To-Live (TTL)                              |
| __max_ttl                 | Maximum lease Time-To-Live (TTL)                              |

### <database_engine>_create

This method creates a new database utilizing the provided name and root user credentials.

| Parameter                | Description                                                   |
|--------------------------|---------------------------------------------------------------|
| __database_name          | Name of the database to be created                            |
| __database_hostname      | Hostname of the database server                               |
| __database_port          | Port number of the database server                            |
| __database_options       | (Optional): Additional configuration options for the database |
| __database_root_username | Username of the root database user                            |
| __database_root_password | Password of the root database user                            |

### <database_engine>_create_user

This method creates a new user with the specified credentials within the designated database.

| Parameter                | Description                                                   |
|--------------------------|---------------------------------------------------------------|
| __database_name          | Name of the database                                          |
| __database_hostname      | Hostname of the database server                               |
| __database_port          | Port number of the database server                            |
| __database_options       | (Optional): Additional configuration options for the database |
| __database_root_username | Username of the root database user                            |
| __database_root_password | Password of the root database user                            |
| __database_new_username  | Username for the new user to be created                       |
| __database_new_password  | Password for the new user                                     |

### <database_engine>_create_super_user

This method creates a new superuser with the specified credentials, typically employed for the initial database setup.

| Parameter                | Description                                                   |
|--------------------------|---------------------------------------------------------------|
| __database_hostname      | Hostname of the database server                               |
| __database_port          | Port number of the database server                            |
| __database_options       | (Optional): Additional configuration options for the database |
| __database_root_username | Username of the root database user                            |
| __database_root_password | Password of the root database user                            |
| __database_new_username  | Username for the new user to be created                       |
| __database_new_password  | Password for the new user                                     |

### <database_engine>_get_default_port

This method returns the default port number for the specific database engine.
