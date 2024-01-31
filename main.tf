resource "aws_route53_zone" "primary_zone" {
  name = var.primary_zone
  lifecycle {
    prevent_destroy = true
  }
}

module "networking" {
  source           = "./networking"
  vpc_cidr         = local.vpc_cidr
  public_cidrs     = local.public_cidrs
  private_cidrs    = local.private_cidrs
  azs              = local.azs
  public_sn_count  = 2
  private_sn_count = 2
  max_subnets      = 4
  db_subnet_group  = false
  access_ip        = var.access_ip
}

# module "s3Primary" {
#   source       = "./s3-website"
#   bucket       = "bucket-primary"
#   local_source = "E:\\Portifolio\\index.html"
#   name_tag     = "primary"
#   env_tag      = "test"
# }

# module "s3Failover" {
#   source       = "./s3-website"
#   bucket       = "bucket-failover"
#   local_source = "E:\\Portifolio\\index-failover.html"
#   name_tag     = "primary"
#   env_tag      = "test"
# }

# module "cloudfront" {
#   depends_on  = [module.s3Primary, module.s3Failover]
#   source      = "./cloudfront"
#   s3_primary  = module.s3Primary.s3_bucket_id
#   s3_failover = module.s3Failover.s3_bucket_id
# }

# module "cdn-oac-bucket-policy-primary" {
#   source         = "./cloudfront-oac"
#   bucket_id      = module.s3Primary.s3_bucket_id
#   bucket_arn     = module.s3Primary.s3_bucket_arn
#   cloudfront_arn = module.cloudfront.cloudfront_arn
# }

# module "cdn-oac-bucket-policy-failover" {
#   source         = "./cloudfront-oac"
#   bucket_id      = module.s3Failover.s3_bucket_id
#   bucket_arn     = module.s3Failover.s3_bucket_arn
#   cloudfront_arn = module.cloudfront.cloudfront_arn
# }
