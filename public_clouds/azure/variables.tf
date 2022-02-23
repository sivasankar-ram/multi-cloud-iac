variable "location" {
	type = string
	default = "southindia"
}

variable "ssh_source_ip" {
	type = string
	default = "*"
}

variable "address_spaces" {
	type = list
	default = ["192.168.0.0/16"]
}

variable "address_prefix" {
	type = list
	default = ["192.168.1.0/24"]
}

variable "vm_name_prefix1" {
	default = "jenkins-master"
}

variable "vm_name_prefix2" {
	default = "jenkins-slave"
}

variable "number_of_nodes" {
	default = 1
}
