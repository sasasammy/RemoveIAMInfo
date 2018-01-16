# Set a user to delete
targetUser = UserToDelete

# Set the name of our awscli profile
aws_profile = prod

# Get all the keys that the user has on its account
userKeys=$(aws iam list-access-keys --user-name $targetUser --profile $aws_profile | jq -r '.AccessKeyMetadata[].AccessKeyId')
 
# Delete the keys
for i in $userKeys; do
  echo "Deleting access key $i from $targetUser"
  aws iam delete-access-key --access-key-id $i --user-name $targetUser --profile $aws_profile
done

# Delete login profile if it exists (Error is okay here)
aws iam delete-login-profile --user-name $targetUser --profile $aws_profile
 
# list user's inline policies
userPolicies=$(aws iam list-user-policies --user-name $targetUser --profile $aws_profile | jq -r ".PolicyNames[]")
 
# Delete those policies
for i in $userPolicies; do
  echo "Deleting user policy $i from $targetUser"
  aws iam delete-user-policy --user-name $targetUser --policy-name $i --profile $aws_profile
done
 
# Find the user's AWS group memberships
userGroups=$(aws iam list-groups-for-user --user-name $targetUser --profile $aws_profile | jq -r '.Groups[].GroupName')
 
# Remove user from those groups
for i in $userGroups; do
  echo "Removing $targetUser from group $i"
  aws iam remove-user-from-group --user-name $targetUser --group-name $i --profile $aws_profile
done
 
# Delete the AWS user account (This step should NOT throw an error)
aws iam delete-user --user-name $targetUser --profile $aws_profile