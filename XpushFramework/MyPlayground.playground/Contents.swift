public typealias CB = (String) -> Void

public class Event {
    
    var handlers = [String:[CB]]();
    
    
    func on(key: String, handler: CB) {
        var hs = handlers[key];
        if hs == nil {
            handlers[key] = [handler];
        }else{
            hs!.append(handler);
        }
        //hs.append(handler);
        //handlers.append(handler)
    }
    
    func emit(key: String, param:String) {
        let hs = handlers[key];
        if hs != nil{
            for handler in hs! {
                print(param);
                handler(param)
            }
        }
    }
}//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

var e = Event();

e.on("aaa", handler: { param in
    print("=== this is param : \(param)");
});

e.emit("aaa", param: " liejtliwjelifjliasdjf");
e.emit("bbb", param: " aaadfsd");
e.emit("ccc", param: " 123123");



