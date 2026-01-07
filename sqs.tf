resource "aws_sqs_queue" "main" {
  name                      = "${var.project_name}-queue"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-queue"
  })
}
