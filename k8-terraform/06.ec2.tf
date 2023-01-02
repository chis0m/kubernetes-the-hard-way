resource "aws_instance" "master" {
  count                       = 3
  ami                         = var.ubuntu_ami
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.subnet.id
  vpc_security_group_ids      = [aws_security_group.sg.id]
  private_ip                  = "10.0.0.1${count.index}"
  user_data                   = "name=${local.base_name}-Cluster-Master-${count.index}|cluster-cidr=${var.cluster_cidr}"
  source_dest_check           = false

  key_name = var.key_name

  provisioner "remote-exec" {
    inline = [
      "sudo sh -c \"echo 'ClientAliveInterval 50' >> /etc/ssh/sshd_config\"",
      "sudo service sshd restart"
    ]
  }
  connection {
    host        = self.public_ip
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/masterclass.cer")
  }

  tags = merge({ "Name" : "${local.base_name}-Cluster-Master-${count.index}" }, local.tags)
}


resource "aws_instance" "worker" {
  count                       = 3
  ami                         = var.ubuntu_ami
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.subnet.id
  vpc_security_group_ids      = [aws_security_group.sg.id]
  private_ip                  = "10.0.0.2${count.index}"
  user_data                   = "name=Cluster-Worker-${count.index}|pod-cidr=10.200.${count.index}.0/24|cluster-cidr=${var.cluster_cidr}"
  source_dest_check           = false

  key_name = var.key_name

  provisioner "remote-exec" {
    inline = [
      "sudo sh -c \"echo 'ClientAliveInterval 50' >> /etc/ssh/sshd_config\"",
      "sudo service sshd restart"
    ]
  }
  connection {
    host        = self.public_ip
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/masterclass.cer")
  }


  tags = merge({ "Name" : "${local.base_name}-Cluster-Worker-${count.index}" }, local.tags)
}
