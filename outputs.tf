# Output values
output "instance_public_ip" {
  value = aws_instance.test_instance.public_ip
}

output "bucket_name" {
  value = aws_s3_bucket.test_bucket.id
}