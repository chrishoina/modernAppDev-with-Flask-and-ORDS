# Load Balancer

resource "oci_load_balancer_load_balancer" "webapp_load_balancer" {

    compartment_id = var.compartment_ocid
    display_name = "webApp_LB1"
    shape = "flexible"
    subnet_ids = [oci_core_subnet.public_subnet.id]
    shape_details {
        minimum_bandwidth_in_mbps = 10
        maximum_bandwidth_in_mbps = 10
    }

}


resource "oci_load_balancer_backend_set" "webapp_backend_set" {
    #Required
    health_checker {
        #Required
        protocol = "HTTP"

        #Optional
        interval_ms = "10000"
        port = "5000"
        retries = "3"
        return_code = "200"
        timeout_in_millis = "3000"
        url_path = "/"

    }
    load_balancer_id = oci_load_balancer_load_balancer.webapp_load_balancer.id
    name = "webapp_backendset"
    policy = "ROUND_ROBIN"

}

resource "oci_load_balancer_listener" "webapp_listener" {
    #Required
    default_backend_set_name = oci_load_balancer_backend_set.webapp_backend_set.name
    load_balancer_id = oci_load_balancer_load_balancer.webapp_load_balancer.id
    name = "webapp_backend_listener"
    port = "80"
    # protocol is set to HTTP as HTTPS option is not available
    # the LB will figure out the protocol should be HTTPS
    protocol = "HTTP"

    #Optional
    connection_configuration {
        #Required
        idle_timeout_in_seconds = 900
    }

}

resource "oci_load_balancer_backend" "webapp_backend" {
    #Required
    backendset_name = oci_load_balancer_backend_set.webapp_backend_set.name
    ip_address = oci_core_instance.compute_instance1.private_ip
    load_balancer_id = oci_load_balancer_load_balancer.webapp_load_balancer.id
    port = "5000"

}