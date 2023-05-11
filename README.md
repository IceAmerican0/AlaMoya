# AlaMoya (Alamofire + Moya) Study

![image](https://github.com/Moya/Moya/raw/master/web/diagram.png)

## 구성

MoyaProvider<Target>: MoyaProvidable
  
  Provider - URLRequest / session / stubBehavior(never/immediate/delay) / endpoint / plugin / callbackQueue
  
   .requestPublisher > MoyaPublisher > subscriber.receive(response or error)
  
  Target - request / path / HTTPMethod / task(JSONEncodable.. etc) / sampleData
  
  endpoint - URLRequest 정제
