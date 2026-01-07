# -----------------------------------------------------------
# 1. 取得最新 Amazon Linux 2023 AMI
# -----------------------------------------------------------
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# -----------------------------------------------------------
# 2. 驗證用 IAM Role (SSM 連線 + SQS 存取)
# -----------------------------------------------------------
resource "aws_iam_role" "test_role" {
  name = "${var.project_name}-${var.environment}-test-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# 允許透過 SSM Session Manager 連線
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.test_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# 允許存取 SQS (為了驗證)
resource "aws_iam_role_policy_attachment" "sqs_full" {
  role       = aws_iam_role.test_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "${var.project_name}-${var.environment}-test-profile"
  role = aws_iam_role.test_role.name
}

# -----------------------------------------------------------
# 3. 為了在無 Internet 環境連線 EC2，需要 SSM Endpoints
# -----------------------------------------------------------
# moved to locals.tf


resource "aws_vpc_endpoint" "ssm" {
  for_each          = toset(local.ssm_endpoints)
  vpc_id            = aws_vpc.main.id
  service_name      = each.value
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.private.id]
  security_group_ids = [aws_security_group.vpce_sg.id] # 複用允許 443 的 SG
  private_dns_enabled = true
}

# -----------------------------------------------------------
# 4. 測試用 EC2 實例
# -----------------------------------------------------------
resource "aws_instance" "test_vm" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private.id
  
  iam_instance_profile = aws_iam_instance_profile.test_profile.name
  vpc_security_group_ids = [aws_security_group.vpce_sg.id] # 只要能出 443 即可

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-test-vm"
  })
  
  # 確保 Endpoint 建立好後再開機，確保能立刻註冊到 SSM
  depends_on = [aws_vpc_endpoint.ssm]
}

# -----------------------------------------------------------
# 5. 輸出 SQS URL 方便測試
# -----------------------------------------------------------
output "sqs_queue_url" {
  value = aws_sqs_queue.main.url
}
