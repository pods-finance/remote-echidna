resource "aws_iam_user" "iam_user" {
  name = "${var.namespace}-${var.project}-${var.project_git_checkout}-iam-user"
}

resource "aws_iam_user_policy" "iam_user_policy" {
  name = "${var.namespace}-${var.project}-${var.project_git_checkout}-policy"
  user = aws_iam_user.iam_user.name
  policy = templatefile("iam_user_policy.tftpl", {
    s3_bucket_arn = data.aws_s3_bucket.s3_bucket.arn
  })
}

resource "aws_iam_access_key" "iam_user_access_key" {
  user = aws_iam_user.iam_user.name
}

