
function dw_aws_get_role_with_web_identity_credentials()
{
local session duration str

if [ -z "$AWS_ROLE_ARN" ] ; then
  echo "ERROR: AWS_ROLE_ARN: Environment variable should be set"
  exit 1
fi

if [ -z "$AWS_WEB_IDENTITY_TOKEN_FILE" ] ; then
  echo "ERROR: AWS_WEB_IDENTITY_TOKEN_FILE: Environment variable should be set"
  exit 1
fi

if [ $# = 0 ] ; then
  echo "ERROR: Usage: dw_aws_get_role_with_web_identity_credentials <session name> {duration (sec, default=3600)]"
  exit 1
fi

session="$1"
duration=3600
[ $# -ge 2 ] && duration="$2"

str=$(aws sts assume-role-with-web-identity \
 --role-arn $AWS_ROLE_ARN \
 --role-session-name "$session"  \
 --web-identity-token file://$AWS_WEB_IDENTITY_TOKEN_FILE \
 --duration-seconds 3600)
export AWS_ACCESS_KEY_ID="$(echo "$str" | jq -r ".Credentials.AccessKeyId")"
export AWS_SECRET_ACCESS_KEY="$(echo "$str" | jq -r ".Credentials.SecretAccessKey")"
export AWS_SESSION_TOKEN="$(echo "$str" | jq -r ".Credentials.SessionToken")"
}
