# aws-homestack
This project builds on my completion of Adrian Cantril’s course "[AWS Certified Solutions Architect - Associate (SAA-C03)](https://learn.cantrill.io/p/aws-certified-solutions-architect-associate-saa-c03)" and earning the "AWS Solutions Architect - Associate" [certification](https://www.credly.com/badges/d7865611-1094-4126-9cb7-957e04841e72/public_url).

Some of my implementations will be based off of Adrian's teachings

## Some helpful commands
1. Set AWS profile after `aws sso configure`
   - `export AWS_PROFILE=<sso_profile_name>`

## Architecture

### Regions
- 2 US (us-east-1, us-west-1)
- 1 Europe (Reserved)

2 Network Ranges per Region. Assume 4 Accounts
- 3 (regions) x 2 (Ranges) x 4 (Accounts) = 24 Total Ranges

### Availability Zones
At least 3 + 1 Reserved = 4

How many tiers?
- Assume 3 (Web, App, DB) + Spare = 4
4 (Tiers) x 4 (AZs) = 16 Subnets

## VPC Configuration
**CIDR RANGE**: 10.20.0.0/16 (-> 10.20.255.255 - 65,456 IPs)

**/16** per VPC - 3 AZ (+1), 3 Tiers (+1) - **16** subnets

**/16** split into 16 subnets = **/20** per subnet (**4091 IPs**)

