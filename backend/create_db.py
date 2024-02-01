import boto3

# Get the service resource.
dynamodb = boto3.resource('dynamodb')

# Create the DynamoDB table.
table = dynamodb.create_table(
    TableName='visit_count',
    KeySchema=[
        {
            'AttributeName': 'ref_id',
            'KeyType': 'HASH'
        },
    ],
    AttributeDefinitions=[
         {
            'AttributeName': 'ref_id',  # This needs to be defined
            'AttributeType': 'N'  # Assuming 'ref_id' is of type String
        },
    ],
    ProvisionedThroughput={
        'ReadCapacityUnits': 5,
        'WriteCapacityUnits': 5
    }
)

# Wait until the table exists.
table.wait_until_exists()


table.put_item(
    Item={
        'ref_id': 100,
        'visits': 0
    }
)

# Print out some data about the table.
print(table.item_count)