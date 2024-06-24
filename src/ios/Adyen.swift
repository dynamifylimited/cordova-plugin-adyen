import Adyen
@objc(Adyen) class Adyen: CDVPlugin {
    
    private var dropInExample: DropInExample?
    
    @objc(pluginInitialize)
      override func pluginInitialize() {
        DispatchQueue.global().async {
            self.dropInExample = DropInExample()
        }
      }
    
   
    @objc(echo:)
    func echo(command: CDVInvokedUrlCommand) {
        dropInExample?.start()
        
       
//        let message = command.arguments[0] as? String ?? ""
//        
//        if !message.isEmpty {
//            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: message)
//            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
//        } else {
//            let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Expected one non-empty string argument.")
//            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
//        }
       
     
    }
    
    func getSessionsData() -> String {
        return "Ab02b4c0!BQABAgBOAjAoXzGZQQNwdB7D17XRULITLO/R1Nmz3nIbM+Llx89byTgpUFQUA0CFAv4+XG5zHCn6BbN4vw2twTKqanToYZqJqaKQ9pX4Lw6DhbwZo3U1DIiHlx53lIJwb4Vuec/u1BCtU8SvroBFqah2eXHpksVLIYxrWtgcnokUxVUy4kbysJ9lC6oSVEft7vo1I31c+IPQSrn/7UlkjAXQ4lde//PQVsPQv2qnAPUBY1O9Qc9wVAQuUgQPrXVnbbHXyJ6hrciQSXdtabg1OCBFLGulTdcId3t1pKGvbispG66JiarsT9fRBkg+QUUBcDoO/scc4AXaklNQNcvoV8TjWxh6wxaINszZDWM7+r35G6gmGJx4vgfN/OrmFNKRbaYfns6d2AG13Uk6UrY7Is2xkuGjG9eQ5BvV3f4BIrD6BI0w609g321DZfI3BSW+ZM4sRSv77ay6MwWwdLx4qGXeUSn4hHLEyhIlVTkat5vvMDrxo4uxpovxZuhiVK+rhDRTo9M55RqikpMsGvzr8/nYv2Bqw+6C1/tA6hb/FRb+GQ/FYw3oxKCHpH/ljnKugYNI1pD6JQyGKP8bjFDk5Kq9qWSmybj7q9+1ytllP2cr+GXewA+cx+ujyGfmQOJqIUbce579fc5L1Zt+pC1BZkX7/0rJf5vyiB3QUMkBCs7XmdEVIwwl9u+Ei9WOi2a4Z9IASnsia2V5IjoiQUYwQUFBMTAzQ0E1MzdFQUVEODdDMjRERDUzOTA5QjgwQTc4QTkyM0UzODIzRDY4REFDQzk0QjlGRjgzMDVEQyJ9GzeLxTDQz79iItZA1WVEQwDvjL9XW/usyanRwcwGbbCtv5mtQL6ELibxoRQKXoBib44VbycsIxEBPQRrtensDuBwkelBNthvi9yHNfO4/KSRsW1AsxBdw9HXOItbrtY/iO9d0YIIbZsC8yHy4/EY2yycUjkGe9E45F9ycfkJCBEdRkmpkMyLLKf6RI61qnUgDB6sPL4x6SPE4EzrxENJEXOUS+nYb7lu4dfJofwSciTAh/feoM1nb86NSZ4UCbJ+HCEdTGugz89KE43VDipApsAFDh/RHvO95Sn+X6i1hptAV1+9BSv0DhEa84fejawwkgnE7Er6xkcJHWsQpjhEfd2gxqg9qSA2raip53X0Un4qBcjXuWdSYipuWd4oiZhOw8vznvxqYGDvKV/f1bOu9Dj0hGeGk6kln/0ouTX7Cmsa1fmKwlQD7QDnwNDFLc790VEc5KEhdjzK2BUEk17OEkDbHdmnwj+srkxFBGTdk2I63Bgmavicy8C89icxvY01WlfX5dWH3wYcyBU5zXqlLqllo4PUgP/WGXc5aGEicqfm1Qv/v8UQteZhn+ROaFkiiyFFYoJHEWSwwb1I6nBttjpsHjJzEA3NTQogBFwbBHqlAWndfOnvOEDL2dDy4TuuBcmJ"
    }
    
    func getSessionId() -> String {
        return "CSEF83B7707477A224"
    }
    
    func setupAdyenContext() {

    }
}
