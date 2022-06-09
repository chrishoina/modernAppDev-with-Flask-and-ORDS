
resource "null_resource" "file" {

  connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.compute_instance1.public_ip
      private_key = tls_private_key.compute_ssh_key.private_key_pem
      agent       = false
      timeout     = "10m"
  }

    provisioner "file" {
        source      = "flaskApp.zip"
        destination = "/home/opc/flaskApp.zip"
  }

  depends_on = [oci_core_instance.compute_instance1,
                oci_core_security_list.public-security-list,]

}

resource "null_resource" "compute-script1" {

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.compute_instance1.public_ip
      private_key = tls_private_key.compute_ssh_key.private_key_pem
      agent       = false
      timeout     = "10m"
    }
    inline = [
    "sudo pip3 install --upgrade pip",
    "pip3 install cx_Oracle oci",
    "pip3 install flask",
    "sudo dnf install oracle-instantclient-release-el8 -y",
    "sudo dnf install oracle-instantclient-basic -y",
    "sudo firewall-cmd --permanent --zone=public --add-port=5000/tcp",
    "sudo firewall-cmd --reload",
    "unzip /home/opc/flaskApp.zip",
    "ENDPOINT_URL=$(echo ${oci_database_autonomous_database.quickstart_autonomous_database.connection_urls.0.sql_dev_web_url} | cut -d / -f 3 )",
    "echo $ENDPOINT_URL",
    "cd flaskApp",
    "sed -i 's/ENDPOINT_URL/'$ENDPOINT_URL'/g' ./rest.py",
    "nohup python3 rest.py & disown"]
  }

  depends_on = [oci_core_instance.compute_instance1,
                oci_core_security_list.public-security-list,
                null_resource.file]

}