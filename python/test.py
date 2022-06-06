'''
#import awswrangler as wr
import boto3
#session = boto3.Session(aws_access_key_id = AWS_KEY,
#aws_secret_access_key = AWS_SECRET, region_name="us-east-1")


def lambda_handler(event, context):
    # Read all records in the speeders folder
    speeders_total = wr.s3.read_csv("s3://speeders", delimiter=" ")
    print(speeders_total.shape)
    
    # Write aggregated speeders file
    wr.s3.to_csv(df = speeders_total, 
             path="s3://speeders/speeders-full/full.csv")
    
    
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }


event = {'invocationId': '1cecbf06-6f70-4530-b525-3e9f91807963', 
    'deliveryStreamArn': 'arn:aws:firehose:eu-central-1:522273657618:deliverystream/terraform-kinesis_firehose_delivery_stream', 'region': 'eu-central-1',
     'records': [{'recordId': '49621741945605965587567431939927808176587776296952528898000000',
      'approximateArrivalTimestamp': 1630798434333, 
      'data': 'MjAyMS0wOS0wNVQwMTozMzo1My45NjI0NTQgVlcgNTkgZWI0NjQ0MjItMmY5ZS00YjdmLTk3ODMtMjEwNjU3MDhkMWM0IDU2Ljg5OTY0MiAyOS45ODk0MDggS05RaVhhZElIekFCV0U2dGEK'},
       {'recordId': '49621741945605965587567431939929017102407390926127235074000000',
        'approximateArrivalTimestamp': 1630798434617, 
        'data': 'MjAyMS0wOS0wNVQwMTozMzo1NC40MjI5NzkgQVVESSAxMDUgYTZiNzFlZmEtZmMwMC00ZTE4LWI2OWYtOTRhNzVlMDFiODhlIC0xMC40NzkwNjMgLTEzMS4yMDk3MTkgR1VNTHFBdlBIdWJvV1JabkcK'},
         {'recordId': '49621741945605965587567431939930226028227005624021417986000000',
          'approximateArrivalTimestamp': 1630798434657, 
          'data': 'MjAyMS0wOS0wNVQwMTozMzo1NC40NjQ1NTIgQVVESSAxNjEgNzNkMzNlODctYjQ2MS00YjlmLTg4MjUtYjg4YjVjMjlhZDVlIDY5Ljk4NDI2MyAtNDEuNDAyMTE0IHFMVzl1ZDhIeU1sdnp5U25jCg=='}, {'recordId': '49621741945605965587567431939931434954046620184476647426000000', 'approximateArrivalTimestamp': 1630798434699, 'data': 'MjAyMS0wOS0wNVQwMTozMzo1NC41MDU1NjcgQVVESSAzMSBhNDgxNjNmNS0zN2QzLTQ0N2UtYjU4NC03ZDBkMzliZmE0NTUgLTE2Ljc5NDk3ODUgMTU1LjY3MDI2MiBXVmMwU2dUR21SYm9JQkJ0UQo='}, {'recordId': '49621741945605965587567431939932643879866234882370830338000000', 'approximateArrivalTimestamp': 1630798434741, 'data': 'MjAyMS0wOS0wNVQwMTozMzo1NC41NDgxNTkgQk1XIDEyMCA5MDNkNTQwOS03NDQxLTRjNTEtOTE1OC00YTU5ZmVmMDk2OTEgLTE3LjQxODA5NzUgLTk4Ljg1MjIxNCBpcnJzOFI1UDlSNDd2cDZ0dQo='}]}

  

## Testing bytes to json
import json
import base64

output = []
for record in event["records"]:
    data=base64.b64decode(record['data'])
    payload = base64.b64decode(record['data']).decode('utf-8')
    print('Data:',data)
    print('payload:',payload)
    newpayload = transform_data(payload)  # manipulate/validate record
    x = base64.b64encode(json.dumps(newpayload).encode('utf-8') + b'\n').decode('utf-8')
    print(x)
   
    output_record = {
           'recordId': record['recordId'],
           'result': 'Ok',
           'data': x
        }

    output.append(output_record)
print('Successfully processed {} records.'.format(len(event['records'])))
    
    
 
    
    #json_data = json.loads(payload.read())

#s = b'2021-09-05T01:33:53.962454 VW 59 eb464422-2f9e-4b7f-9783-21065708d1c4 56.899642 29.989408 KNQiXadIHzABWE6ta\n'
#t = b"73d33e87-b461-4b9f-8825-b88b5c29ad5e 69.984263 -41.402114 qLW9ud8HyMlvzySnc"
#print(type(s))
#json.load(s)
'''


#import boto3
#s3 = boto3.resource('s3',aws_access_key_id = "AKIAXTGPPSMJF5LSONEF",
#aws_secret_access_key = "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", region_name="eu-central-1")
#bucket = s3.Bucket('bucket-firehose-ver111')
# Iterates through all the objects, doing the pagination for you. Each obj
# is an ObjectSummary, so it doesn't contain the body. You'll need to call
# get to get the whole body.
#for obj in bucket.objects.all():
#    key = obj.key
#    body = obj.get()['Body'].read()
#    print( body )


import pandas as pd
payload =  {
	"Type" : "Notification",
	"MessageId" : "b3582c96-cc8a-5437-913b-752b92081d9f",
	"TopicArn" : "arn:aws:sns:eu-central-1:522273657618:Vehicle_sns_terraform",
	"Subject" : "Data from Car telematic sensor",
	"Message" : "\"2021-09-16T16:59:39.072752 VW 137 1ae29419-6ec5-4f9e-87a7-b51be7480e10 18.161759 142.138218 dbM1rIA7p123FxzCb Passenger\"",
	"Timestamp" : "2021-09-16T15:01:22.228Z",
	"SignatureVersion" : "1",
	"Signature" : "whCiE0ZAyPy/yf8P239MvgwKcdstBTtN2FaXKwo6Syw8cUeqGC6CrxH1IGWzqgyZCtP3Q/eH3eOAWKVfjo5zHrFCcos2QdGhFnROJN6R7vL2Jw56mFa+hbNkA5sGbMoOgjkL6hfAWelM6kiIlPkVWytsLefuKiXihL19pBCcuk/4SpWI02JGAKlHSSrx6oQjgFylRTVIVKaOhw4dPvB2vuSipBDMkd/ZKHQryp9EkuVoAdcRG1AYnw18wy1HWvGCfqEEmQktDyWi6p2Kb5u2Q8PscKgEe+BhacP4kWoI947RGZhnZFecVxIwRvpZwFenluouoHUSmzDm8umrZxciag==",
	"SigningCertURL" : "https://sns.eu-central-1.amazonaws.com/SimpleNotificationService-010a507c1833636cd94bdb98bd93083a.pem",
	"UnsubscribeURL" : "https://sns.eu-central-1.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:eu-central-1:522273657618:Vehicle_sns_terraform:028256d7-4dfa-4418-bf11-5d60a220b6bd",
	"MessageAttributes" : {"VehicleType" : {"Type":"String","Value":"Car"}}
}
	
df = pd.read_csv("20H58M22S.csv",sep=";")
print(df)

top_speeds = df.groupby(['vin'])['speed'].max().reset_index()
print("top_speeds:",top_speeds)
print("top_speeds.speed",top_speeds.speed)
vehiclespeed = top_speeds.speed
print(type(vehiclespeed))
print(vehiclespeed)
print(vehiclespeed.values[0])


vehiclespeed_int = vehiclespeed.values[0]

top_speeds[True]
#too_fast = top_speeds[60 > 50]
#print("too_fast:",too_fast)

