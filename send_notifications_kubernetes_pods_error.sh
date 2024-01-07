#!/bin/bash
# Set variables
email="your email address"
subject="pod error in your Kubernetes Cluster"
#TWILIO_ACCOUNT_SID="your-SID-token"
#TWILIO_AUTH_TOKEN="Your-Auth-Token"
#TWILIO_PHONE_NUMBER="Your-twilio-phone-no"
RECIPIENT_PHONE_NUMBER="recevier's-number"

kubectl get pods --all-namespaces -o json > latest.json

# Check for CrashLoopBackOff errors
jq '.items[] | select(.status.containerStatuses[].state.waiting.reason == "CrashLoopBackOff") | .metadata.name, .metadata.namespace, .status.containerStatuses[].state.waiting.reason' latest.json | while read pod_name pod_namespace pod_status pod_reason; do
  body=$(echo "Pod: $pod_name in namespace $pod_namespace is in CrashLoopBackOff state with reason $pod_reason")
  echo -e "Subject: $subject\n$body" | sendmail "$email"
 # curl -X POST "https://api.twilio.com/2010-04-01/Accounts/$TWILIO_ACCOUNT_SID/Messages.json" --data-urlencode "To=+$RECIPIENT_PHONE_NUMBER" --data-urlencode "From=+$TWILIO_PHONE_NUMBER" --data-urlencode "Body=$body" -u "$TWILIO_ACCOUNT_SID:$TWILIO_AUTH_TOKEN"
  echo "Sending alert to $email and $RECIPIENT_PHONE_NUMBER"
done

# Check for ImagePullBackError errors
jq '.items[] | select(.status.containerStatuses[].state.waiting.reason == "ImagePullBackOff") | .metadata.name, .metadata.namespace, .status.containerStatuses[].state.waiting.reason' latest.json | while read pod_name pod_namespace pod_status pod_reason; do
  body=$(echo "Pod: $pod_name in namespace $pod_namespace is in ImagePullBackError state with reason $pod_reason")
  echo -e "Subject: $subject\n$body" | sendmail "$email"
  #curl -X POST "https://api.twilio.com/2010-04-01/Accounts/$TWILIO_ACCOUNT_SID/Messages.json" --data-urlencode "To=+$RECIPIENT_PHONE_NUMBER" --data-urlencode "From=+$TWILIO_PHONE_NUMBER" --data-urlencode "Body=$body" -u "$TWILIO_ACCOUNT_SID:$TWILIO_AUTH_TOKEN"
  echo "Sending alert to $email and $RECIPIENT_PHONE_NUMBER"
done
# check for the OOMKilled errors
jq '.items[] | select(.status.containerStatuses[].state.waiting.reason == "OOMKilled") | .metadata.name, .metadata.namespace, .status.containerStatuses[].state.waiting.reason' latest.json | while read pod_name pod_namespace pod_status pod_reason; do
  body=$(echo "Pod: $pod_name in namespace $pod_namespace is in OOMkilled state with reason $pod_reason")
  echo -e "Subject: $subject\n$body" | sendmail "$email"
  #curl -X POST "https://api.twilio.com/2010-04-01/Accounts/$TWILIO_ACCOUNT_SID/Messages.json" --data-urlencode "To=+$RECIPIENT_PHONE_NUMBER" --data-urlencode "From=+$TWILIO_PHONE_NUMBER" --data-urlencode "Body=$body" -u "$TWILIO_ACCOUNT_SID:$TWILIO_AUTH_TOKEN"
  echo "Sending alert to $email and $RECIPIENT_PHONE_NUMBER"
done

# Check for other errors
jq '.items[] | select(.status.phase == "Failed") | .metadata.name, .metadata.namespace, .status.phase' latest.json | while read pod_name pod_namespace pod_status pod_reason; do
  body=$(echo "Pod: $pod_name in namespace $pod_namespace is in Other error state with reason $pod_reason")
  echo -e "Subject: $subject\n$body" | sendmail "$email"
  #curl -X POST "https://api.twilio.com/2010-04-01/Accounts/$TWILIO_ACCOUNT_SID/Messages.json" --data-urlencode "To=+$RECIPIENT_PHONE_NUMBER" --data-urlencode "From=+$TWILIO_PHONE_NUMBER" --data-urlencode "Body=$body" -u "$TWILIO_ACCOUNT_SID:$TWILIO_AUTH_TOKEN"
  echo "Sending alert to $email and $RECIPIENT_PHONE_NUMBER"
done

#if the pods are in running state then
jq '.items[] | select(.status.phase == "Running")' latest.json | while read pod_name pod_namespace pod_status; do
  echo "Pod: $pod_name in namespace $pod_namespace is running"
done
