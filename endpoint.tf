resource "aws_vpc_endpoint" "sqs" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-northeast-1.sqs"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.private.id
  ]

  security_group_ids = [
    aws_security_group.vpce_sg.id
  ]

  # 關鍵設定：啟用後，VPC 內的資源存取 sqs.ap-northeast-1.amazonaws.com 
  # 會自動解析到此 Endpoint 的私有 IP (ENI)
  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-sqs-endpoint"
  }
}
