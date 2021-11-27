resource "aws_key_pair" "my_key" {
  key_name   = "yaser"
  public_key = file(var.ssh_pubkey_path)
}

resource "aws_security_group" "redis_ssh" {
  name   = "redis"
  vpc_id = var.vpc_id
  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["192.168.0.0/16"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.168.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
  }
}

resource "aws_security_group" "http_ssh" {
  name   = "http for webapp"
  vpc_id = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.local_pub_ip}/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
  }
}

resource "aws_instance" "webapp" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.my_key.key_name
  vpc_security_group_ids = [
    aws_security_group.http_ssh.id,
  ]
  subnet_id = var.pub_subnet_id
  provisioner "remote-exec" {
    inline = [
      "sudo apt install -y python3",
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_privkey_path)
      host        = self.public_ip
    }
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i ${self.public_ip}, ${path.root}/ansible/main.yaml --private-key ${var.ssh_privkey_path} -e 'redis_host_ip=${aws_instance.redis.private_ip}'"
  }
}

resource "aws_instance" "redis" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.my_key.key_name
  user_data = file("${path.root}/modules/app/redis.sh")
  vpc_security_group_ids = [
    aws_security_group.redis_ssh.id,
  ]
  subnet_id = var.prv_subnet_id
}
