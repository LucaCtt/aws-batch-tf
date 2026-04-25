resource "aws_sqs_queue" "messages" {
  name                       = "${var.name_prefix}-messages"
  visibility_timeout_seconds = var.sqs_visibility_timeout_seconds
  message_retention_seconds  = var.sqs_message_retention_seconds
  receive_wait_time_seconds  = 20 # long polling — reduces empty receives and API costs
}

# Allow Batch EC2 instances (via their instance role) to send messages.
# The launcher reads/deletes using its own caller credentials — no extra policy needed on that side.
data "aws_iam_policy_document" "sqs_send" {
  statement {
    actions   = ["sqs:SendMessage", "sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueUrl", "sqs:GetQueueAttributes"]
    resources = [aws_sqs_queue.messages.arn]
  }
}

resource "aws_iam_policy" "sqs_send" {
  name   = "${var.name_prefix}-sqs-send"
  policy = data.aws_iam_policy_document.sqs_send.json
}

resource "aws_iam_role_policy_attachment" "instance_sqs_send" {
  role       = module.batch.instance_iam_role_name
  policy_arn = aws_iam_policy.sqs_send.arn
}
