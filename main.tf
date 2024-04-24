locals {
  vpc_id           = "vpc-060fd3a04d9436dab"
  subnet_id        = "subnet-08434308a602c1a7b"
  ssh_user         = "ec2-user"
  key_name         = "devkey.pem"
}

resource "aws_security_group" "tomcat" {
  name   = "tomcat_acess"
  vpc_id = local.vpc_id
 ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "tomcat" {
  ami                         = "ami-04e5276ebb8451442"
  subnet_id                   = "subnet-08434308a602c1a7b"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.tomcat.id]
  key_name                    = local.key_name

  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.key_name)
      host        = aws_instance.tomcat.public_ip
    }
  }
  provisioner "local-exec" {
    command = "ansible-playbook  -i ${aws_instance.tomcat.public_ip}, --private-key ${local.key_name} tomcat.yml"
  }
}

output "tomcat_ip" {
  value = aws_instance.tomcat.public_ip
}
