#!/bin/bash
# ============================================================
# Deploy Static Website to S3 + CloudFront
# Run: bash deploy.sh
# ============================================================

# ── CONFIG — update these values ────────────────────────────
BUCKET_NAME="my-static-website-$(date +%s)"   # Unique bucket name
REGION="us-east-1"
CLOUDFRONT_COMMENT="S3 Static Website Distribution"

echo "=== Step 1: Create S3 Bucket ==="
aws s3api create-bucket \
    --bucket $BUCKET_NAME \
    --region $REGION
echo "[✓] Bucket created: $BUCKET_NAME"

echo ""
echo "=== Step 2: Enable Static Website Hosting ==="
aws s3 website s3://$BUCKET_NAME/ \
    --index-document index.html \
    --error-document error.html
echo "[✓] Static website hosting enabled"

echo ""
echo "=== Step 3: Set Bucket Policy (Public Read) ==="
POLICY=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::$BUCKET_NAME/*"
    }
  ]
}
EOF
)

aws s3api put-bucket-policy \
    --bucket $BUCKET_NAME \
    --policy "$POLICY"
echo "[✓] Bucket policy set"

echo ""
echo "=== Step 4: Upload Website Files ==="
aws s3 cp index.html s3://$BUCKET_NAME/
aws s3 cp error.html s3://$BUCKET_NAME/
echo "[✓] Files uploaded"

echo ""
echo "=== Step 5: Create CloudFront Distribution ==="
DISTRIBUTION_ID=$(aws cloudfront create-distribution \
    --origin-domain-name "$BUCKET_NAME.s3-website-$REGION.amazonaws.com" \
    --default-root-object index.html \
    --query 'Distribution.Id' \
    --output text)
echo "[✓] CloudFront distribution created: $DISTRIBUTION_ID"

echo ""
echo "=== Deployment Complete! ==="
echo "S3 Website URL    : http://$BUCKET_NAME.s3-website-$REGION.amazonaws.com"
echo "CloudFront ID     : $DISTRIBUTION_ID"
echo "(CloudFront domain takes ~15 min to deploy globally)"
