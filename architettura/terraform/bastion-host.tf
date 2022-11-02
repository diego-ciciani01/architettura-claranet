//deploy bastion host 
resource "aws_instance" "bastionHost" {
  count                  = length(var.subnets_cidr_Pubblic)
  ami                    = data.aws_ami.app_ami.id
  instance_type          = var.instance_type_bastianHost
  vpc_security_group_ids = [aws_security_group.sg-bastion-host.id]
  subnet_id              = element(aws_subnet.subnets_Pubblic.*.id, count.index)
  availability_zone      = element(var.availability_zones, count.index)
  key_name               = aws_key_pair.generated_key.key_name

  tags = {
    Name = "my-bastionHost-${count.index + 1}-az"
  }
  depends_on = [tls_private_key.private_key_lanchconfig]
  connection {
    type = "ssh"
    host = self.public_ip
    user = var.user_ssh

    private_key = tls_private_key.private_key.private_key_pem
    timeout     = "4m"
    agent       = false
  }
  # prenda la chiave creata da Auto_Scaling_group.tf e la salva nella istanza bastion host  
  provisioner "remote-exec" {
    inline = [
      "echo ${tls_private_key.private_key_lanchconfig.private_key_pem} > aws_keys_pairs_lunchconfig.pem",
      "chmod 600 aws_keys_pairs_lunchconfig.pem"
    ]
  }

}


// per generare la chiave SSH con algoritmo RSA
resource "tls_private_key" "private_key" {

  algorithm = "RSA"
  rsa_bits  = 4096
}

// per collegare la chiave create e per salvarla nella cartella principale 
resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.private_key.public_key_openssh

  # salva la chiave ssh del bastion host in locale 
  provisioner "local-exec" {
    command = <<-EOT
      echo '${tls_private_key.private_key.private_key_pem}' > aws_keys_pairs_bastianhost.pem
      chmod 600 aws_keys_pairs_bastianhost.pem
    EOT
  }
}

// prende l'ami del sito di aws linux
data "aws_ami" "app_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}


output "private_key" {
  value     = tls_private_key.private_key.private_key_pem
  sensitive = true
}

output "ip_private_bastion" {
  value = [for bastion in aws_instance.bastionHost : bastion.private_ip]
}