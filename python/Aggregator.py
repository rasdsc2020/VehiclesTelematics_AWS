import os
import pandas as pd
import awswrangler as wr
import pytz
from datetime import datetime

tz = pytz.timezone('Europe/Berlin')


def lambda_handler(event, context):
    filter_date = datetime.now(tz).strftime("%Y%m%d")
    df = wr.s3.read_csv(f"s3://consolidated-data-bucket-speeders/")
    df.head()
    
    print(filter_date)
    wr.s3.to_csv(df,f"s3://consolidated-data-bucket-speeders/final-report/{filter_date}.csv", sep=";", index=False)
    return "Test terraform for the streaming data from Lambda!"