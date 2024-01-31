# S3 STATIC WEBSITE WITH CLOUDFRONT DISTRIBUTION

Test deployment of static website in S3, using Origin Access Control to route traffic through a Cloudfront distribution.

- For a static website, the Certificate must be issued in "us-east-1" region;
- The infrastructure code in this code will be updated to remove hardcoded values, such as ACM certificate ARN;
- The Certificate used by this code was issued using the AWS console, and not generated through HCL.