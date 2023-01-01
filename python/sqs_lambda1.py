## SNS have two braches for microservices  SNS--> SQS --> this lambda function 

import json
import time

def lambda_handler(event, context):
    # TODO implement
    print("output from sqs/sns lambda")
    print("Appending output at",time.ctime())
    print(event)
    print("body:",event.get("Records")[0].get("body"))
    return None