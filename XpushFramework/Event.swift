//
//  Event.swift
//  XpushFramework
//
//  Created by notdol on 10/25/15.
//  Copyright © 2015 stalk. All rights reserved.
//

import Foundation

public typealias CB = (JSON) -> Void

public class Event {
    
    var handlers = [String:[CB]]();
    
    
    public func on(key: String, handler: CB) {
        var hs = handlers[key];
        if hs == nil {
            handlers[key] = [handler];
        }else{
            hs!.append(handler);
        }
        //hs.append(handler);
        //handlers.append(handler)
    }
    
    public func emit(key: String, param:JSON) {
        let hs = handlers[key];
        if hs != nil{
            for handler in hs! {
                print(param);
                handler(param)
            }
        }
    }
}
