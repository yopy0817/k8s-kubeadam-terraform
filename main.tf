# VPC설정
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}
# 서브넷설정
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}

# 인터넷게이트웨이 설정
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# 라우터테이블 설정
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
# 라우팅 테이블 연결
resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.rt.id
}

# 보안그룹 설정
resource "aws_security_group" "k8s_sg" {
  name        = "k8s-sg"
  description = "Allow SSH and Kubernetes traffic"
  vpc_id      = aws_vpc.main.id
  
  # 22번 포트 개방
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # 쿠버 노드간 통신포트 개방
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # 노드 간 모든 포트 (TCP)
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 노드 간 모든 포트 (UDP)
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # 아웃바운드
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 마스터 노드 생성
resource "aws_instance" "master" {
  ami           = var.ami_id
  instance_type = var.master_instance_type
  subnet_id     = aws_subnet.main.id
  key_name      = var.key_name
  security_groups = [aws_security_group.k8s_sg.id]
  associate_public_ip_address = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }

  tags = {
    Name = "k8s-master"
  }
}
# 워커 노드 생성
resource "aws_instance" "worker" {
  count         = var.worker_count
  ami           = var.ami_id
  instance_type = var.worker_instance_type
  subnet_id     = aws_subnet.main.id
  key_name      = var.key_name
  security_groups = [aws_security_group.k8s_sg.id]
  associate_public_ip_address = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }
 
  tags = {
    Name = "k8s-worker-${count.index + 1}"
  }
}
