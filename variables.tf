# AWS 리전 설정
variable "aws_region" {
  description = "AWS 리전 - 서울 리전(ap-northeast-2) 고정"
  type        = string
  default     = "ap-northeast-2"
}

# AWS 콘솔에서 미리 생성한 키페어 이름
# 예: AWS 콘솔에서 생성한 'demo-kubeadm.pem' 키페어의 이름은 'demo-kubeadm'
variable "key_name" {
  description = "EC2 인스턴스에 사용할 기존 키페어 이름"
  type        = string
  default     = "demo-kubeadam"
}

# Ubuntu 22.04 LTS AMI ID (서울 리전, 2024년 기준)
# 최신 AMI는 aws cli 또는 콘솔에서 조회 가능
variable "ami_id" {
  description = "EC2 인스턴스에 사용할 AMI ID (Ubuntu 22.04 LTS for x86_64, HVM, SSD)"
  type        = string
  default     = "ami-0c9c942bd7bf113a2"
}

# 마스터 노드 인스턴스 타입
# Kubernetes 컨트롤 플레인을 실행할 노드이므로 최소 t3.medium 이상 권장 (vCPU 2, RAM 4GB)
variable "master_instance_type" {
  description = "Kubernetes 마스터 노드 인스턴스 타입"
  type        = string
  default     = "t3.medium"
}

# 워커 노드 인스턴스 타입
# 테스트용 클러스터면 t3.small(2vCPU, 2GB RAM)도 무방
variable "worker_instance_type" {
  description = "Kubernetes 워커 노드 인스턴스 타입"
  type        = string
  default     = "t3.small"
}

# 워커 노드 개수 설정
# 최소 1개 이상, 실습 기준으로는 2개가 적당함
variable "worker_count" {
  description = "생성할 워커 노드 개수"
  type        = number
  default     = 2
}
