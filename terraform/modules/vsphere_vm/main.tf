data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_host" "host" {
  name          = var.vsphere_host
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.template
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = var.disk.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.network.name
  datacenter_id = data.vsphere_datacenter.dc.id
}


resource "vsphere_virtual_machine" "vm" {
  name             = var.vm_name
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  host_system_id   = data.vsphere_host.host.id

  guest_id = data.vsphere_virtual_machine.template.guest_id
  
  num_cpus = var.hardware.num_cpus
  memory   = var.hardware.memory

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label = "disk0"
    size  = var.disk.size
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = var.vm_name
        domain    = var.domain
      }

      network_interface {
        ipv4_address = var.vm_ip
        ipv4_netmask = var.network.netmask
        ipv6_address = var.vm_ip6
        ipv6_netmask = var.network.netmask6
      }

      dns_server_list = var.dns.server_list
      dns_suffix_list = var.dns.suffix_list
      ipv4_gateway    = var.network.gateway
      ipv6_gateway    = var.network.gateway6
    }
  }
}

resource "powerdns_record" "dns_A" {
  zone    = "${var.domain}."
  name    = "${var.vm_name}.${var.domain}."
  type    = "A"
  ttl     = 3600
  records = [var.vm_ip]
}

resource "powerdns_record" "dns_AAAA" {
  zone    = "${var.domain}."
  name    = "${var.vm_name}.${var.domain}."
  type    = "AAAA"
  ttl     = 3600
  records = [var.vm_ip6]
}

resource "powerdns_record" "dns_PTR_ipv4" {
  zone    = "${var.reverse_zone}."
  name    = "${join(".", reverse(split(".", var.vm_ip)))}.in-addr.arpa."
  type    = "PTR"
  ttl     = 3600
  records = ["${var.vm_name}.${var.domain}."]
}

data "external" "reverse_ptr_ipv6" {
  program = ["/bin/bash", "${path.module}/reverse_ptr_ipv6.sh", "${var.vm_ip6}"]
}

resource "powerdns_record" "dns_PTR_ipv6" {
  zone    = "${var.reverse_zone6}."
  name    = data.external.reverse_ptr_ipv6.result.reversed
  type    = "PTR"
  ttl     = 3600
  records = ["${var.vm_name}.${var.domain}."]
}