#!/bin/bash
set -euo pipefail

REGION="$1"
PROFILE="$2"
OUTPUT="json"
SSO_START_URL="https://d-906633025e.awsapps.com/start"

echo "[SETUP-PROFILE] Configuring AWS SSO profile: $PROFILE"
aws configure set profile."$PROFILE".sso_start_url "$SSO_START_URL"
aws configure set profile."$PROFILE".sso_region "$REGION"
aws configure set profile."$PROFILE".region "$REGION"
aws configure set profile."$PROFILE".output "$OUTPUT"

echo "[LOGIN] Checking AWS SSO credentials expiration..."
expiration=$(aws configure export-credentials --profile "$PROFILE" | jq -r .Expiration 2>/dev/null || true)

if [[ -z "$expiration" ]]; then
  echo "[LOGIN] No credentials found. Initiating AWS SSO login..."
  aws sso login --profile "$PROFILE"
else
  now_epoch=$(date -u +%s)
  exp_epoch=$(date -d "$expiration" +%s)

  if (( exp_epoch <= now_epoch )); then
    echo "[LOGIN] Credentials expired. Initiating AWS SSO login..."
    aws sso login --profile "$PROFILE"
  else
    echo "[LOGIN] Credentials are still valid until $expiration"
  fi
fi

INSTANCE_ARN=$(aws sso-admin list-instances \
  --region "$REGION" \
  --output text \
  --query 'Instances[0].InstanceArn')

echo "Fetching AWS accounts..."
accounts=$(aws organizations list-accounts \
  --region "$REGION" \
  --query 'Accounts[].Id' \
  --output text)

echo "Available accounts:"
select account_id in $accounts; do
  if [[ -n "$account_id" ]]; then
    break
  fi
done

echo "Fetching available permission sets..."
permission_sets=$(aws sso-admin list-permission-sets \
  --instance-arn "$INSTANCE_ARN" \
  --region "$REGION" \
  --query 'PermissionSets[]' \
  --output text)

declare -A role_map=()
roles=()

for ps_arn in $permission_sets; do
  assignment=$(aws sso-admin list-account-assignments \
    --instance-arn "$INSTANCE_ARN" \
    --account-id "$account_id" \
    --permission-set-arn "$ps_arn" \
    --region "$REGION" \
    --query 'AccountAssignments[].PermissionSetArn' \
    --output text)

  if [[ -n "$assignment" ]]; then
    ROLE_NAME=$(aws sso-admin describe-permission-set \
      --instance-arn "$INSTANCE_ARN" \
      --permission-set-arn "$ps_arn" \
      --region "$REGION" \
      --query 'PermissionSet.Name' \
      --output text)
    roles+=("$ROLE_NAME")
    role_map["$ROLE_NAME"]="$ps_arn"
  fi
done

echo "Available roles:"
select ROLE_NAME in "${roles[@]}"; do
  if [[ -n "$ROLE_NAME" ]]; then
    break
  fi
done

aws configure set profile."$PROFILE".sso_account_id "$account_id"
aws configure set profile."$PROFILE".sso_role_name "$ROLE_NAME"

echo "[SETUP-PROFILE] Profile '$PROFILE' configured with account $account_id and role $ROLE_NAME."