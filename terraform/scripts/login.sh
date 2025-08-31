#!/bin/bash
set -euo pipefail

REGION="$1"
OUTPUT="json"
SSO_START_URL="https://d-906633025e.awsapps.com/start"
SSO_REGION="$REGION"

echo "[LOGIN] Initiating AWS SSO login..."
aws configure set sso_start_url "$SSO_START_URL" --profile sso-temp
aws configure set sso_region "$SSO_REGION" --profile sso-temp
aws configure set region "$REGION" --profile sso-temp
aws configure set output "$OUTPUT" --profile sso-temp

echo "[LOGIN] Checking AWS SSO credentials expiration..."
expiration=$(aws configure export-credentials --profile sso-temp | jq -r .Expiration || echo "")
now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

if [[ -z "$expiration" || "$expiration" < "$now" ]]; then
  echo "[LOGIN] Credentials expired or not found. Initiating AWS SSO login..."
  aws sso login --profile sso-temp
else
  echo "[LOGIN] Credentials are still valid until $expiration"
fi

INSTANCE_ARN=$(aws sso-admin list-instances --region "$SSO_REGION" --output text --query 'Instances[0].InstanceArn')

echo "Fetching AWS accounts..."
accounts=$(aws organizations list-accounts \
  --region "$SSO_REGION" \
  --query 'Accounts[].Id' \
  --output text)

echo "Available accounts:"
select account_id in $accounts; do
  if [ -n "$account_id" ]; then
    break
  fi
done

echo "Fetching available permission sets..."
permission_sets=$(aws sso-admin list-permission-sets \
  --instance-arn "$INSTANCE_ARN" \
  --region "$SSO_REGION" \
  --query 'PermissionSets[]' \
  --output text)

echo "Available roles:"
for ps_arn in $permission_sets; do
  assignment=$(aws sso-admin list-account-assignments \
    --instance-arn "$INSTANCE_ARN" \
    --account-id "$account_id" \
    --permission-set-arn "$ps_arn" \
    --region "$SSO_REGION" \
    --query 'AccountAssignments[].PermissionSetArn' \
    --output text)
  if [ -n "$assignment" ]; then
    ROLE_NAME=$(aws sso-admin describe-permission-set \
      --instance-arn "$INSTANCE_ARN" \
      --permission-set-arn "$ps_arn" \
      --region "$SSO_REGION" \
      --query 'PermissionSet.Name' \
      --output text)
    echo "$ROLE_NAME ($ps_arn)"
  fi
done

PROFILE="sso-$account_id-$ROLE_NAME"
echo "[SETUP-PROFILE] Configuring AWS SSO profile: $PROFILE"
aws configure set region "$REGION" --profile "$PROFILE"
aws configure set output "$OUTPUT" --profile "$PROFILE"
aws configure set sso_start_url "$SSO_START_URL" --profile "$PROFILE"
aws configure set sso_region "$SSO_REGION" --profile "$PROFILE"
aws configure set sso_account_id "$account_id" --profile "$PROFILE"
aws configure set sso_role_name "$ROLE_NAME" --profile "$PROFILE"
echo "[SETUP-PROFILE] Profile '$PROFILE' configured."