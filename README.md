# aws-homestack
### Regions
- 2 US (us-east-1, us-west-1)
- 1 Europe (Reserved)

2 Network Ranges per Region
Assume 4 Accounts
- 3 (regions) x 2 (Ranges) x 4 (Accounts) = 24 Total Ranges

### Subnets
At least 3 + 1 Reserved = 4
How many tiers?
Assume 3 (Web, App, DB) + Spare = 4
4 x 4 = 16 subnets

10.20.0.0/16 -> 10.20.255.255 (65,456)
**/16** per VPC - 3 AZ (+1), 3 Tiers (+1) - **16** subnets
**/16** split into 16 subnets = **/20** per subnet (**4091 IPs**)

