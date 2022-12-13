resource "aws_instance" "master" {
  count                       = 3
  ami                         = var.ubuntu_ami
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.subnet.id
  vpc_security_group_ids      = [aws_security_group.sg.id]
  private_ip                  = "10.0.1.2${count.index}"
  user_data                   = "${local.base_name}-Cluster-Master-${count.index}"
  source_dest_check           = false

  key_name = var.key_name

  tags = merge({ "Name" : "${local.base_name}-Cluster-Master-${count.index}" }, local.tags)
}


resource "aws_instance" "worker" {
  count                       = 3
  ami                         = var.ubuntu_ami
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.subnet.id
  vpc_security_group_ids      = [aws_security_group.sg.id]
  private_ip                  = "10.0.1.3${count.index}"
  user_data                   = "worker-${count.index}|pod-cidr=172.20.${count.index}.0/24"
  source_dest_check           = false

  key_name = var.key_name

  tags = merge({ "Name" : "${local.base_name}-Cluster-Worker-${count.index}" }, local.tags)
}
