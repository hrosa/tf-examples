import json


def lambda_handler(event, context):
    print("Received event: " + json.dumps(event, indent=2))

    authorization = event.get("authorizationToken")
    print("Authorization: " + authorization)

    policy = generate_policy("user", "Allow", event["methodArn"])
    print("Policy: " + json.dumps(policy, indent=2))

    return policy


def generate_policy(principal_id, effect, resource):
    policy = {
        "principalId": principal_id,
        "policyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Action": "execute-api:Invoke",
                    "Effect": effect,
                    "Resource": resource
                }
            ]
        }
    }

    return policy
