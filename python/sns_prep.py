## create a function to process incoming json data for SNS function
## connected to s3 put object --> records from firehose will come to s3 and this lambda will add messageattributes for sns

import json
import urllib.parse
import boto3
import time
import pandas as pd
#import awswrangler as wr

print('Loading function')

s3 = boto3.client('s3')
sns = boto3.client('sns')
message = {"foo": "bar"}

def lambda_handler(event,context):
    #print("Received event: " + json.dumps(event, indent=2))
    print("Event orig:",event)
    # Get the object, Key and eventName from the event and show its content type
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']
    eventname = event['Records'][0]['eventName']
    try:
        print("Eventname:",eventname)
        # Verify that event is created from preprocessed-sns-bucket.
        if eventname == 'ObjectCreated:Put'  and bucket == 'preprocessed-sns-bucket':
            obj = s3.get_object(Bucket=bucket, Key = key)
            print("finding obj body:",obj["Body"])
            df = pd.read_csv(obj["Body"], header = None)
            print(df)
            
            for i in df.index:
                print("Dataframe row at ",i,"value:",df.iloc[i])
                data =  str(df.iloc[i,0])
                print("type data",type(data))
                try:
                    if "Passenger" in data:
                        vehicletype = "Two wheeler"
                        sub = "Data from Two wheeler telematic sensor"
                    else:
                        vehicletype = "Four wheeler"
                        sub = "Data from Four wheeler telematic sensor"
                
                    print("Type of vehicle :",vehicletype)
                    try:
                        sns_response = sns.publish(TargetArn='arn:aws:sns:eu-central-1:330064558504:Vehicle_sns_terraform', Message=json.dumps({'default': json.dumps(data)}),
                        Subject=sub,
                        MessageStructure='json', MessageAttributes = {"VehicleType": {"DataType":"String","StringValue": vehicletype}} )
                    except Exception as e:
                        print(e.message, e.args)
                        
                    print("response while adding:",sns_response['ResponseMetadata']['HTTPStatusCode'])
                    print(time.ctime())
                except:
                    print("Error while processing df in sns_prep lambda code...")
                    pass
            #return response['ContentType']
    except Exception as e:
        print(e)
        print('Error getting object {} from bucket {}. Make sure they exist and your bucket is in the same region as this function.'.format(key, bucket))
        raise e