# KINESIS AGENT
resource "aws_iam_role" "producer" {
  assume_role_policy = jsonencode(
    {
      Version : "2012-10-17",
      Statement : [
        {
          Effect : "Allow",
          Principal : {
            Service : "ec2.amazonaws.com"
          },
          Action : "sts:AssumeRole"
        }
      ]
    })
}

resource "aws_iam_role_policy" "producer_firehose" {
  for_each = var.record_types
  role     = aws_iam_role.producer.id
  policy   = jsonencode(
    {
      Version : "2012-10-17",
      Statement : [
        {
          Effect : "Allow",
          Action : "firehose:PutRecordBatch",
          Resource : aws_kinesis_firehose_delivery_stream.datastore[each.key].arn
        }
      ]
    })
}

# FIREHOSE
resource "aws_iam_role" "firehose" {
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "firehose.amazonaws.com"
        },
        "Effect" : "Allow",
      }
    ]
  })
}


resource "aws_iam_role_policy" "firehose_elasticsearch_write" {
  role   = aws_iam_role.firehose.name
  policy = <<-EOF
  {
      "Version": "2012-10-17",
      "Statement": [
          {
            "Effect": "Allow",
            "Action": [
              "ec2:DescribeVpcs",
              "ec2:DescribeVpcAttribute",
              "ec2:DescribeSubnets",
              "ec2:DescribeSecurityGroups",
              "ec2:DescribeNetworkInterfaces",
              "ec2:CreateNetworkInterface",
              "ec2:CreateNetworkInterfacePermission",
              "ec2:DeleteNetworkInterface"
            ],
            "Resource": [
              "*"
            ]
          },
          {
             "Effect": "Allow",
             "Action": [
                 "es:DescribeElasticsearchDomain",
                 "es:DescribeElasticsearchDomains",
                 "es:DescribeElasticsearchDomainConfig",
                 "es:ESHttpPost",
                 "es:ESHttpPut"
             ],
            "Resource": [
                "${var.datastore_endpoint}",
                "${var.datastore_endpoint}/*"
            ]
         }
      ]
  }
  EOF
}

resource "aws_iam_role_policy" "firehose_elasticsearch_api" {
  for_each = var.record_types
  role     = aws_iam_role.firehose.name
  policy   = jsonencode(
    {
      Version : "2012-10-17",
      Statement : [
        {
          Effect : "Allow",
          Action : [
            "es:ESHttpGet"
          ],
          Resource : [
            "${var.datastore_endpoint}/_all/_settings",
            "${var.datastore_endpoint}/_cluster/stats",
            "${var.datastore_endpoint}/${each.key}/_mapping/*",
            "${var.datastore_endpoint}/_nodes",
            "${var.datastore_endpoint}/_nodes/stats",
            "${var.datastore_endpoint}/_nodes/*/stats",
            "${var.datastore_endpoint}/_stats",
            "${var.datastore_endpoint}/${each.key}/_stats"
          ]
        }
      ]
    })
}

resource "aws_iam_role_policy" "firehose_s3" {
  role   = aws_iam_role.firehose.name
  policy = jsonencode(
    {
      Version : "2012-10-17",
      Statement : [
        {
          Effect : "Allow",
          Action : [
            "s3:AbortMultipartUpload",
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:ListBucketMultipartUploads",
            "s3:PutObject"
          ],
          Resource : [
            var.s3_bucket_backup_arn,
            "${var.s3_bucket_backup_arn}/*"
          ]
        }
      ]
    })
}
