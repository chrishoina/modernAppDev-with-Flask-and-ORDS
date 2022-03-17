import oci
import sys
import base64
from oci.config import from_file 
from oci.database_tools import DatabaseToolsClient
from oci.database_tools.models import CreateDatabaseToolsConnectionOracleDatabaseDetails
import cx_Oracle

from flask import Flask, json, render_template, request
app = Flask(__name__)

@app.route("/")
def main():
    return render_template('index.html')

@app.route('/signup')
def signup():
    return render_template('signup.html')

@app.route('/api/signUp',methods=['POST'])
def signUp():
    # read the posted values from the UI
    _name = request.form['inputName']
    _email = request.form['inputEmail']
    _password = request.form['inputPassword']
 
    # validate the received values
    if _name and _email and _password:
        return json.dumps({'html':'<span>All fields good !!</span>'})
    else:
        return json.dumps({'html':'<span>Enter the required fields</span>'})

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)

INSTANCE_PRINCIPAL_AUTHENTICATION_TYPE_VALUE_NAME = 'instance_principal'
DELEGATION_TOKEN_WITH_INSTANCE_PRINCIPAL_AUTHENTICATION_TYPE = 'delegation_token_with_instance_principal'
RESOURCE_PRINCIPAL_AUTHENTICATION_TYPE = 'resource_principal'
DELEGATION_TOKEN_FILE_FIELD_NAME = 'delegation_token_file'
AUTHENTICATION_TYPE_FIELD_NAME = 'authentication_type'


signer = oci.auth.signers.InstancePrincipalsSecurityTokenSigner()

database_tools_client = oci.database_tools.DatabaseToolsClient(config={}, signer=signer)
get_database_tools_connection_response = database_tools_client.get_database_tools_connection(
    database_tools_connection_id="ocid1.databasetoolsconnection.oc1.eu-frankfurt-1.amaaaaaau3i6vkyags63dx2rnq3s6xf42q6ixqlynu66n6wj5sjqzghzvrqa")
user_name = get_database_tools_connection_response.data.user_name
secret_id = get_database_tools_connection_response.data.user_password.secret_id

def read_secret_value(signer, secret_id):
    print("Reading vaule of secret_id {}.".format(secret_id))      
    secret_client = oci.secrets.SecretsClient(config={}, signer=signer)
    
    response = secret_client.get_secret_bundle(secret_id)

    base64_Secret_content = response.data.secret_bundle_content.content
    base64_secret_bytes = base64_Secret_content.encode('ascii')
    base64_message_bytes = base64.b64decode(base64_secret_bytes)
    secret_content = base64_message_bytes.decode('ascii')

    return secret_content
    
secret_content = read_secret_value(signer, secret_id)

cx_Oracle.init_oracle_client("/usr/lib/oracle/21/client64/lib")

dsn = """152.70.186.226:1521/test19.publicsubnet.demos.oraclevcn.com"""