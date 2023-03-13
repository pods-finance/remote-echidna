resource "aws_iam_user" "iam_user" {
  name = "${local.prefix}-user"
}

resource "aws_iam_user_policy" "iam_user_policy" {
  name = "${local.prefix}-policy"
  user = aws_iam_user.iam_user.name
  policy = templatefile("iam_user_policy.tftpl", {
    s3_bucket_arn = data.aws_s3_bucket.s3_bucket.arn
  })
}

resource "aws_iam_access_key" "iam_user_access_key" {
  user = aws_iam_user.iam_user.name
}

