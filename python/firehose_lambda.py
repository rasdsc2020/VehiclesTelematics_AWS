'''This module processed the incoming records from vehicle sensors.'''

import json
import base64


def transform_data(data):
    """ Invoked once for each record and decide if vehicle is two_whl or four_whl"""
    print("Processing data: %s" % data)
    vehiclelist = ['VW', 'PORSCHE', 'BMW', 'AUDI', 'MERCEDES']
    if any(substring in data for substring in vehiclelist):
        data = data + " " + "four_whl"
    else:
        data = data + " " + "two_whl"

    return data 

    
def lambda_handler(event, context):
    """ This is the main Lambda entry point """
    output = []
    for record in event["records"]:
        data=base64.b64decode(record['data'])
        payload = base64.b64decode(record['data']).decode('utf-8')
        print('Data:',data)
        print('payload:',payload)
        newpayload = transform_data(payload)  # manipulate/validate record
        x = base64.b64encode(json.dumps(newpayload).encode('utf-8') + b'\n').decode('utf-8')
    
        output_record = {
            'recordId': record['recordId'],
            'result': 'Ok',
            'data': x
            }

        output.append(output_record)
    print('Successfully processed {} records.'.format(len(event['records'])))
    return {'records': output}



