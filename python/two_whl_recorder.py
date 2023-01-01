''' This module finds the overspeeding two wheelers and save in s3 bucket.'''
import json, pandas as pd
import numpy, boto3
import os
import pytz
from datetime import datetime
tz = pytz.timezone('Europe/Berlin')
import time
import pandas as pd


s3_client = boto3.client('s3')
SPEED_ALERT_THRESHOLD = os.environ.get("SPEED_ALERT_THRESHOLD", 50)
ALERT_PHONE_NUMBER = os.environ.get("ALERT_PHONE_NUMBER", None)

def get_new_data(event):
    '''Function to extract all vehicle related infromation from sqs records.'''
    # TODO implement
    # Create a list to store new object keys.
    written_objects = []
    print("output from sqs/sns lambda")
    print("Appending output at",time.ctime())
    
    i = 1
    for record in event['Records']:
        df = pd.DataFrame()
        print("Record number:",i)
        payload = record["body"]
        #print("payload:",payload)
        ss = json.loads(payload)
        
        new_dict = {}
        new_dict["Subject"] = ss["Subject"]
        new_dict["Message"] = ss["Message"]
        

        df = pd.DataFrame([new_dict])
        print("shape of df",df.shape)
        df[["EVENT_TIME", "Model", "speed", "record_id", "lat", "lon","vin","Type"]] = df['Message'].str.split(' ', expand=True)
        print("dataframe:",df)
        written_objects.append(df)
        i+=1
    # Concatenate new records into a single dataframe.
    return pd.concat(written_objects)


def lambda_handler(event, context):
    '''Function to filter two wheelers having speed greater than the threshold set in environment variable.'''
    # Call the helper method
    data = get_new_data(event)
    print("Data:",data)
    print("Length of dataframe before saving to s3 bucket",len(data))
    
    try:
        ## Get the top speeds vehicle could appear multiple time so take max speed per vehicle
        top_speeds = data.groupby(['vin'])['speed'].max().reset_index()
      
        print("type speed alert threshold:",type(SPEED_ALERT_THRESHOLD))
        print("SPEED_ALERT_THRESHOLD",SPEED_ALERT_THRESHOLD)
        top_speeds["speed"] = top_speeds["speed"].astype(int)
        
        ## Get top speeds that exceed the limit of 45
        too_fast = top_speeds[top_speeds["speed"] > int(SPEED_ALERT_THRESHOLD)]
        print(type(too_fast))
        print("too_fast:",too_fast)
    
        totals = data.groupby(['vin'])['speed'].max().reset_index()
        
        ## Generate object key
        fdate = datetime.now(tz).strftime("%Y%m%d/%HH%MM%SS")
        obj_key = f"bucket-speeders1/two-wheeler-filtered/{fdate}.csv" # filename in speeders folder
        ## Write the object to S3
        s3_client.put_object(Bucket='consolidated-data-bucket-speeders', Key=obj_key, Body=too_fast.to_csv(sep=";", index=False))
    
    except:
        print("Error in recordreader for two wheeler...")
        pass
    return totals.to_csv(sep=";", index=False)
