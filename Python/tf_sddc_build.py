#! /usr/bin/python

import os
import sys
import json
import argparse
from prettytable import PrettyTable

#  TASKS
#
# DONE: create local file with API key and OrgID for SDDC creation
# DONE: Setup a pretty table to report back current key_file content
# DONE: create API Key env variable and start tf script to build SDDC
# 3. create env variables from tf output
#    - create output.json
#    - read output.json with python and create env variables for TF
# 4. start tf script to build NSX

# Adds orgID and Refresh Token to the API_KEY.txt file
def read_apikey_file():
    with open(f'{key_file}') as f:
        for jsonObj in f:
            response = json.loads(jsonObj)
            response_list.append(response)
        return(response_list)

def add_key(key_file):
    content = {
        'org': input('Enter the OrgID: '),
        'r_token' : input('Enter refresh tolken for this Org: ')
    }
    with open(f'{key_file}','a+') as f:
        json.dump(content,f)
        f.write('\n')

# Update Refresh Token for specified OrgID
def updel_key():
    new_keyfile = []
    org_to_change = input('Input OrgID to update/delete: ')
    for record in response_list:
        if (record['org'] == org_to_change):
            if args.delete :
                print('Found OrgID: '+record['org']+ 'with Refresh Token: '+record['r_token'])
                confirm = input('Are you sure you want to delete this record? [Y/n]')
                if confirm.upper == "Y":
                    print('remove record')
                else:
                    print ('Do you want to update this record? [Y/n] ')
                    

    exit()
#    content = {
#        'org': input('Enter the OrgID: '),
#        'r_token' : input('Enter NEW refresh tolken for this Org: ')
#    }
#    with open(f'{key_file}','w+') as f:
#        json.dump(content,f)
#        f.write('\n')

# Generates a pretty table of orgID and Refresh token
def generate_token_table():
    table_data = PrettyTable()
    table_data.field_names = ['Org ID','Refresh Token']
    for org_response in response_list:
        table_data.add_row([org_response['org'],org_response['r_token']])
    print(table_data)

parser = argparse.ArgumentParser(description='Create and Update a local API_KEY file to store Org and refresh token.  Create Terraform environment variables for the Refresh Token and API keys')
parser.add_argument('key_dir',help='Path to the directory of an existing API_KEY file to validate.')
parser.add_argument('-a','--add',action='store_true',help='Add a Refresh token to existing API_KEY file')
parser.add_argument('-c','--create',action='store_true',help='Create an API_KEY file to store your refresh tokens')
parser.add_argument('-d','--delete',action='store_true',help='Delete a Refresh Token')
parser.add_argument('-l','--list',action='store_true',help='List the Refresh tokens in the current API_KEY file')
parser.add_argument('-tc','--terraformEnv',action='store_true',help='Create ENV variables for Terraform to use')
parser.add_argument('-u','--update',action='store_true',help='Update a refresh Token')

args = parser.parse_args()
key_file = (args.key_dir+'/api_key.txt')
response_list = []

# Add orgIDs and refresh tokens to an existing "api_key.txt" file.
if args.list:
    if os.path.exists(f'{key_file}'):
        print('\n***********************************')
        print('Successfully found API_KEY file at: '+key_file)
        print('***********************************\n')
        read_apikey_file()
        generate_token_table()
elif args.create:
    file_create = input('A key file does not exist at this location, do you want to create it? [Y/n]: ' or 'Y')
    if file_create.upper() == 'Y':
        add_key()
elif args.add:
    add_key()
elif args.update:
    change_mode = 'u'
    read_apikey_file()
    generate_token_table()
    updel_key()
elif args.delete:
    change_mode = 'd'
    read_apikey_file()
    generate_token_table()
    updel_key()
elif args.terraformEnv:
    working_org = input('Which org would you like to use? ')
    for source_org in response_list:
        s_orgID = str(source_org['org'])
        if working_org == s_orgID:
            print('Creating environment variables from the api_key.txt file.')
            os.environ['TF_VAR_orgid'] = str(source_org['org'])
            os.environ['TF_VAR_rtoken'] = str(source_org['r_token'])
            os.system('env | grep -i tf')
            os.system('terraform -chdir=/home/rcarson/Projects/vmc-open-source/Terraform plan')
            sys.exit()
        else:
            print("\nYou have not defined an refresh token for org: "+working_org)
            sys.exit()
elif args.terraformchange:
    print('This is where I add code - Terraformchange')
else:
    print('\n***************************')
    print('Please run tf_sddc_build -h')
    print('***************************\n')