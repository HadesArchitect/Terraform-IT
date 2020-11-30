resource "aws_instance" "redis" {
  ami             = "ami-cfca25a0"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.ssh.name, aws_security_group.outgoing.name, aws_security_group.redis.name]
  key_name        = aws_key_pair.deployer.key_name
  connection {
    user = "core"
  }
  provisioner "remote-exec" {
    inline = [
      "docker run -dp 6379:6379 redis",
    ]
  }
}
resource "aws_instance" "db" {
  ami             = "ami-cfca25a0"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.ssh.name, aws_security_group.postgres.name, aws_security_group.outgoing.name]
  key_name        = aws_key_pair.deployer.key_name
  connection {
    user = "core"
  }
  provisioner "remote-exec" {
    inline = [
      "docker run -dp 5432:5432 postgres",
    ]
  }
}
resource "aws_instance" "voting" {
  ami             = "ami-cfca25a0"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.ssh.name, aws_security_group.http.name, aws_security_group.outgoing.name]
  key_name        = aws_key_pair.deployer.key_name
  connection {
    user = "core"
  }
  provisioner "remote-exec" {
    inline = [
      "docker run -dp 80:80 -e REDIS_HOST=${aws_instance.redis.private_ip} ditmc/voting",
    ]
  }
}
resource "aws_instance" "worker" {
  ami             = "ami-cfca25a0"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.ssh.name, aws_security_group.outgoing.name]
  key_name        = aws_key_pair.deployer.key_name
  connection {
    user = "core"
  }
  provisioner "remote-exec" {
    inline = [
      "docker run -d -e REDIS_HOST=${aws_instance.redis.private_ip} -e DB_HOST=${aws_instance.db.private_ip} ditmc/worker"
    ]
  }
}
resource "aws_instance" "result" {
  ami             = "ami-cfca25a0"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.ssh.name, aws_security_group.http.name, aws_security_group.outgoing.name]
  key_name        = aws_key_pair.deployer.key_name
  connection {
    user = "core"
  }
  provisioner "remote-exec" {
    inline = [
      "docker run -dp 80:80 -e DB_HOST=${aws_instance.db.private_ip} ditmc/result"
    ]
  }
}
resource "aws_eip" "voting_ip" {
  instance = aws_instance.voting.id
}
resource "aws_eip" "db_ip" {
  instance = aws_instance.db.id
}
resource "aws_eip" "result_ip" {
  instance = aws_instance.result.id
}
