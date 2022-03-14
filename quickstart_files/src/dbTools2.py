import oci
import sys
import base64
from oci.config import from_file 
from oci.database_tools import DatabaseToolsClient
from oci.database_tools.models import CreateDatabaseToolsConnectionOracleDatabaseDetails
import cx_Oracle

INSTANCE_PRINCIPAL_AUTHENTICATION_TYPE_VALUE_NAME = 'instance_principal'
DELEGATION_TOKEN_WITH_INSTANCE_PRINCIPAL_AUTHENTICATION_TYPE = 'delegation_token_with_instance_principal'
RESOURCE_PRINCIPAL_AUTHENTICATION_TYPE = 'resource_principal'
DELEGATION_TOKEN_FILE_FIELD_NAME = 'delegation_token_file'
AUTHENTICATION_TYPE_FIELD_NAME = 'authentication_type'


# By default this will hit the auth service in the region the instance is running.
signer = oci.auth.signers.InstancePrincipalsSecurityTokenSigner()

# In the base case, configuration does not need to be provided as the region and tenancy are obtained from the InstancePrincipalsSecurityTokenSigner
##identity_client = oci.identity.IdentityClient(config={}, signer=signer)

# Get instance principal context
#secret_client = oci.secrets.SecretsClient(config={}, signer=signer)


# Step 2: Get secret id and retrieve the password for PDB.


# Get the secret id and username
database_tools_client = oci.database_tools.DatabaseToolsClient(config={}, signer=signer)
get_database_tools_connection_response = database_tools_client.get_database_tools_connection(
    database_tools_connection_id="ocid1.databasetoolsconnection.oc1.eu-frankfurt-1.amaaaaaau3i6vkyags63dx2rnq3s6xf42q6ixqlynu66n6wj5sjqzghzvrqa")
user_name = get_database_tools_connection_response.data.user_name
secret_id = get_database_tools_connection_response.data.user_password.secret_id

# Intepret the secret id to password

def read_secret_value(signer, secret_id):
    print("Reading vaule of secret_id {}.".format(secret_id))      
    secret_client = oci.secrets.SecretsClient(config={}, signer=signer)
    
    response = secret_client.get_secret_bundle(secret_id)

    base64_Secret_content = response.data.secret_bundle_content.content
    base64_secret_bytes = base64_Secret_content.encode('ascii')
    base64_message_bytes = base64.b64decode(base64_secret_bytes)
    secret_content = base64_message_bytes.decode('ascii')

    return secret_content
    
#secret_client = oci.secrets.SecretsClient(signer)
secret_content = read_secret_value(signer, secret_id)
#print("Decoded content of the secret is: {}.".format(secret_content))


#Step 3:  Pass the database user credential to Python Driver

cx_Oracle.init_oracle_client("/usr/lib/oracle/21/client64/lib")

dsn = """152.70.186.226:1521/test19.publicsubnet.demos.oraclevcn.com"""

# Connect to autonomous database by using the user_name and password from the response
connection = cx_Oracle.connect(user=user_name, password=secret_content, dsn=dsn)

print("Successfully connected to Oracle Database")

cursor = connection.cursor()

# Create a table

cursor.execute("""
    begin
        execute immediate 'drop table todoitem';
        exception when others then if sqlcode <> -942 then raise; end if;
    end;""")

cursor.execute("""
    create table todoitem (
        id number generated always as identity,
        description varchar2(4000),
        creation_ts timestamp with time zone default current_timestamp,
        done number(1,0),
        primary key (id))""")

# Insert some data

rows = [ ("Task 1", 0 ),
         ("Task 2", 0 ),
         ("Task 3", 1 ),
         ("Task 4", 0 ),
         ("Task 5", 1 ) ]

cursor.executemany("insert into todoitem (description, done) values(:1, :2)", rows)
print(cursor.rowcount, "Rows Inserted")

connection.commit()

# Now query the rows back
for row in cursor.execute('select description, done from todoitem'):
    if (row[1]):
        print(row[0], "is done")
    else:
        print(row[0], "is NOT done")



