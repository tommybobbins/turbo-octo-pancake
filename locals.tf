locals {

user_data = base64encode(templatefile("${path.module}/user_data/influx_client.sh", {
    hostname          = "${var.project}-influx-client"
    PREFIX            = var.prefix
    PROJECT           = var.project
    INFLUXDB_ENDPOINT     = "http://myinfluxserver:8086"
   }))
}
