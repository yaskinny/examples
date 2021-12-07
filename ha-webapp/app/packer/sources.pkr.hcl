source "amazon-ebs" "app" {
  region = "${var.region}"
  vpc_id = "${var.vpc_id}"
  subnet_id = "${var.subnet_id}"
  source_ami = "${var.source_ami}"
  instance_type = "${var.instance_type}"
  associate_public_ip_address = true
  ssh_username = "ubuntu"
  ami_name = "webapp-${var.version}"
}
