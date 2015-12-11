//
//  ChannelConnector.swift
//  XpushFramework
//
//  Created by notdol on 9/1/15.
//  Copyright (c) 2015 stalk. All rights reserved.
//

import Foundation

public class ChannelConnector: SocketConnector{
    let serverInfo:JSON = [];

    override func initWithServerInfo(info:JSON, cb:XpushNormalCallback? = nil)->Void{
        print(info);
        let serverUrl:String = info[XpushConst.SERVER][XpushConst.URL].string!;
        //let token:String = info[XpushConst.TOKEN].string!; // deprecated before version
        // A C S U D
        /*
        "seq" : "41IkPPCQg",
        "channel" : "4yo3c8pQx",
        "server" : {
            "channel" : "4yo3c8pQx",
            "name" : "10",
            "url" : "http:\/\/www.notdol.com:8080"
        }
        */
        
        var parameters:[String:AnyObject] = [String:AnyObject]();
        parameters["A"] = xpush.APP_ID;
        parameters["C"] = info[XpushConst.CHANNEL].string;
        parameters["S"] = info[XpushConst.SERVER][XpushConst.NAME].string!;
        parameters["U"] = xpush.USER_ID;
        parameters["D"] = xpush.DEVICE_ID;
        //parameters["TK"] = token;
        
        connect(serverUrl,parameters: parameters,cb:cb);
    }
    
    override func connect(url:String,parameters:[String:AnyObject],cb:XpushNormalCallback? = nil)->Void{
        print("=== xpush : \(url + XpushConst.GLOBAL_NS)");
        var params:[String:AnyObject] = [String:AnyObject]();
        params["connectParams"] = parameters;
        params["nsp"] = XpushConst.CHANNEL_NS;
        params["log"] = true;
        
        self.socket = SocketIOClient(socketURL: url,opts : params);
        
        self.socket?.onAny(){ event in
            print("========= any event");
            print(event);
            
            let evtNm:String = event.event;
            let dt:JSON = JSON(event.items!);
            self.emit(evtNm,param: dt);
        };
        
        self.socket!.on("connect") {data, ack in
            print("socket connected")
            if cb != nil{
                cb!(nil);
            }
        }
        self.socket!.on("error") {data, ack in
            print("socket error: \(data)");
        }
        
        
        self.socket!.on("disconnect") { data, ack in
            print("socket disconnected");
        }
        
        self.socket!.connect()
    }
    
    func getUsers(callback:(data:JSON)->Void)->Void{
        let params:JSON = [];
        self.emit(XpushConst.CH_USERS, parameters: params, cb: { data in
            print("===== channel user list");
            callback(data: data);
        });
    }
    
    func getUsersNumberGeneral(callback:(data:JSON)->Void)->Void{
        let params:JSON = [];
        self.emit(XpushConst.CH_USERS, parameters: params, cb: { data in
            print("===== channel user list");
            callback(data: data);
        });
    }
    
    public func sendMessage(var meta:JSON, callback:(data:JSON)->Void)->Void{
        var params:JSON = ["NM":"message"];
        meta["sender"].string = xpush.USER_ID;
        params["DT"] = meta;

        self.emit(XpushConst.CH_SEND_MESSAGE, parameters: params, cb: { data in
            print("===== sendMessage");
            callback(data: data);
        });
    }
    
    
    
}