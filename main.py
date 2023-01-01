'''This module generates the fake telematics data and sends to aws kinesis.'''

import json
from pprint import pprint
import random
import time
import boto3
import datetime
import uuid
import string
import pandas as pd
import config
from faker import Faker
fake = Faker()

# kinesis firehose name
STREAM_NAME = "kinesis_firehose_vehicleTelematics"

def get_data():
    return {
        'EVENT_TIME': datetime.datetime.now().isoformat(),
        'Model': random.choice(['VW', 'PORSCHE', 'BMW', 'AUDI', 'MERCEDES',"MAN","IVECO","SCANIA","DAF","Daimler"]),
        'speed': str(random.randint(80,250)),
        'record_id': fake.uuid4(),
        'lat':str(fake.latitude()),
        'lon':str(fake.longitude()),
        'vin':''.join([random.choice(string.ascii_letters + string.digits) for n in range(17)])}



def generate(stream_name, kinesis_client, numrecords):

    # numrecords : number of data points sent to firehose
    # stream_name : name of the kinesis firehose service
    max_try = numrecords
    df = pd.DataFrame()
    while max_try >0:
        data = get_data()
        df = df.append(data,ignore_index=True)
        #print(json.dumps(data))
        payload = " ".join(str(value) for value in data.values())
        print('\x1b[6;30;42m' + payload + '\x1b[0m')
        ## kinesis stream
        kinesis_client.put_record(DeliveryStreamName=stream_name, Record= {'Data':payload})
        max_try -= 1


if __name__ == "__main__":
    generate(STREAM_NAME, boto3.client('firehose', aws_access_key_id= config.aws_access_key_id,
    aws_secret_access_key=config.aws_secret_access_key,region_name = config.region_name), config.num_records)
    
