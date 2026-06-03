# Static Website Hosted on AWS S3 with CloudFront CDN

## Overview
Hosted a static website on AWS S3 and distributed it globally using
CloudFront CDN — demonstrating scalable, serverless, low-cost web
hosting on AWS.

## Architecture
User → CloudFront Edge Location → S3 Bucket (Origin) → HTML Content Served

## What I Built
* Created and configured S3 bucket for static website hosting
* Set bucket policy to allow public read access
* Uploaded HTML content to S3
* Created CloudFront distribution pointing to S3 origin
* Configured edge locations for global content delivery
* Verified website loads via both S3 URL and CloudFront URL

## Services Used
* Amazon S3
* AWS CloudFront
* S3 Bucket Policies
* AWS Management Console

## Key Learnings
* Static website hosting on S3
* CDN setup and edge location delivery
* S3 bucket policies and public access configuration
* Cost-effective serverless hosting
* Global content distribution with low latency

## Screenshots

### S3 Static Website Live
<img width="1919" height="1021" alt="Screenshot 2026-05-23 195550" src="https://github.com/user-attachments/assets/cf959fdd-ec77-4af3-bc9a-0eb59c6d42f1" />


### S3 Static Website Live
<img width="1915" height="979" alt="Screenshot 2026-05-23 201821" src="https://github.com/user-attachments/assets/5f6f9e95-5550-4b7f-8c41-e22636eee7be" />
