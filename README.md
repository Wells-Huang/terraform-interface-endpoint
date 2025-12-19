**專案簡介**
按照架構圖設計
位於VPC(10.0.0.0/16)內, 部署在特定Private Subnet中的運算資源(EC2, Lambda, etc)發送SQS API請求, DNS 查詢被解析為 VPC Interface Endpoint 的私有 IP, 
流量依據 Route Table 導向 Endpoint ENI, Interface Endpoint 透過 AWS 內部網路連線到 SQS, 成功透過SQS API將訊息送入SQS queue或者從SQS queue接收訊息

**使用說明**
1. 執行terraform init, terraform plan, terraform apply看執行結果


**架構圖**
![Architecture Diagram](docs/interface_endpoint.png)
