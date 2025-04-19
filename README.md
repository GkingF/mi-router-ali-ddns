# mi-router-ali-ddns
A pure shell implementation of Aliyun DDNS script suitable for Xiaomi routers

### 1. Introduction
This is a pure shell implementation of Aliyun DDNS script suitable for Xiaomi routers and without any external dependencies(valid in BE6500Pro and ax3600). 
Only updating when IP of local machine is different from the one in Aliyun DNS service.

### 2. Prerequisites
- A domain name registered in Aliyun DNS service.
- Aliyun Access Key ID and Access Key Secret.
- A Xiaomi router with SSH access.
- DNS record configured in Aliyun DNS service.(or created automatically by the script, call the `addRecord` function)

### 3. Usage
- configure the script with your Aliyun Access Key ID, Access Key Secret, domain name, and subdomain name.
- upload the script to your Xiaomi router.
- make the script executable.
- run the script manually to test it.
- create a cron job to run the script periodically with log file or not.
- check the log file to see if the script is working correctly.