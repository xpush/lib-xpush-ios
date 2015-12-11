//
//  SocketConnector.swift
//  XpushFramework
//
//  Created by notdol on 8/30/15.
//  Copyright (c) 2015 stalk. All rights reserved.
//

import Foundation

public class SocketConnector : Event{
    var xpush:Xpush;
    var socket:SocketIOClient?;
    
    init(xpush:Xpush){
        self.xpush = xpush;
    }
    
    func initWithServerInfo(info:JSON, cb:XpushNormalCallback? = nil)->Void{
        let serverUrl:String = info[XpushConst.SESSION_SERVER_URL_KEY].string!;
        //let token:String = info[XpushConst.TOKEN].string!; // deprecated before version
        var serverId:String = info[XpushConst.SERVER].string!;
    
        var parameters:[String:AnyObject] = [String:AnyObject]();
        parameters["A"] = xpush.APP_ID;
        parameters["U"] = xpush.USER_ID;
        parameters["D"] = xpush.DEVICE_ID;
        //parameters["TK"] = token;
        
        connect(serverUrl,parameters: parameters,cb:cb);
    }
    
    func connect(url:String,parameters:[String:AnyObject],cb:XpushNormalCallback? = nil)->Void{
        print("=== xpush : \(url + XpushConst.GLOBAL_NS)");
        var params:[String:AnyObject] = [String:AnyObject]();
        params["connectParams"] = parameters;
        params["nsp"] = XpushConst.GLOBAL_NS;
        params["log"] = true;
        
        self.socket = SocketIOClient(socketURL: url,opts : params);
        
        self.socket!.on("connect") {data, ack in
            print("socket connected")
            if cb != nil {
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
    
    func initSocket(socket:SocketIOClient)->Void{
        socket.on(XpushConst.SS_GLOBAL_EVENT_KEY, callback:{ data , emitter in
            var event:String = data[0][XpushConst.SS_EVENT_KEY] as! String;
            switch event {
                case "NOTIFICATION":
                    print("a");
                case "CONNECT":
                    print("a");
                
                case "DISCONNECT":
                    print("a");
                case "LOGOUT":
                    print("a");
            default:
                print("a");

            }
        });
        
    }
    
    func emit(key:String, parameters:JSON?, cb:((data:JSON)->Void)? = nil)->Void{
        
        if parameters == nil {
        self.socket?.emitWithAck(key)(timeoutAfter: 0){ data in
            print("===== emit success");
            print(data[0] as! NSDictionary);
            if cb != nil{
                cb!(data: JSON(data[0]));
            }
        };
        }
        else {
        
        self.socket?.emitWithAck(key, parameters!.rawValue)(timeoutAfter: 0){ data in
            print("===== emit success");
            print(data[0] as! NSDictionary);
            if cb != nil{
                cb!(data: JSON(data[0]));
            }
        };
        }
    
    }
    
    func signup(userId:String, passwd:String, cb:(()->Void)? = nil)->Void{
    
    }
    
    func createChannel(channelName:String? = nil,var users:[String]? = nil,cb:((data:JSON)->Void)? = nil)->Void{
        print("====== start create channel");
        
        var params:JSON = ["A": xpush.APP_ID! /*, "C":"temp_channel"*//*, "U":"notdol"*/];
        params["C"].string = channelName == nil ? nil : channelName!;
        if(users == nil){
            users = [xpush.USER_ID!];
        }else{
            users?.append(xpush.USER_ID!);
        }
        params["U"].arrayObject = users;
        self.emit(XpushConst.SS_CHANNEL_CREATE, parameters: params, cb: { data in
            print("===== channel created");
            if cb != nil{
                cb!(data: data);
            }
        });
    }
    func channelList(cb:((data:JSON)->Void)? = nil)->Void{
        //let params:JSON = ["A": xpush.APP_ID!];

        self.emit(XpushConst.SS_CHANNEL_LIST, parameters: nil, cb: { data in
            print("===== channelList");
            if cb != nil{
                cb!(data: data);
            }
        });
    }

    func channelUpdate(channelName:String, q:String, cb:((data:JSON)->Void)? = nil)->Void{
        let params:JSON = ["A": xpush.APP_ID!];
        self.emit(XpushConst.SS_CHANNEL_UPDATE, parameters: params, cb: { data in
            print("===== channelUpdate");
            if cb != nil{
                cb!(data: data);
            }
        });
    }

    func channelGet(channelName:String, cb:((data:JSON)->Void)? = nil)->Void{
        let params:JSON = ["A": xpush.APP_ID!];
        self.emit(XpushConst.SS_CHANNEL_GET, parameters: params, cb: { data in
            print("===== channelGet");
            if cb != nil{
                cb!(data: data);
            }
        });
    }

    func channelExit(channelName:String,user:String, cb:((data:JSON)->Void)? = nil)->Void{
        let params:JSON = ["A": xpush.APP_ID!];
        self.emit(XpushConst.SS_CHANNEL_EXIT, parameters: params, cb: { data in
            print("===== channelExit");
            if cb != nil{
                cb!(data: data);
            }
        });
    }
    
    func userList(cb:((data:JSON)->Void)? = nil)->Void{
        let params:JSON = ["page": ["num": 1, "size" : 50 ]];        
        self.emit(XpushConst.SS_USER_LIST, parameters: params, cb: { data in
            print("===== userList");
        });
    }
    func userListQuery(query:String, columns:[String], cb:((data:JSON)->Void)? = nil)->Void{
        let params:JSON = ["A": xpush.APP_ID!];
        self.emit(XpushConst.SS_USER_QUERY, parameters: params, cb: { data in
            print("===== userListQuery");
            if cb != nil{
                cb!(data: data);
            }
        });
    }
    
    func messageUnread(cb:((data:JSON)->Void)? = nil)->Void{
        let params:JSON = ["A": xpush.APP_ID!,"U": xpush.USER_ID!, "D":xpush.DEVICE_ID!];
        self.emit(XpushConst.SS_MESSAGE_UNREAD, parameters: params, cb: { data in
            print("===== messageUnread");
            if cb != nil{
                cb!(data: data);
            }
        });
    }

    func messageReceived(cb:((data:JSON)->Void)? = nil)->Void{
        let params:JSON = ["A": xpush.APP_ID!,"U": xpush.USER_ID!, "D":xpush.DEVICE_ID!];
        self.emit(XpushConst.SS_MESSAGE_RECEIVED, parameters: params, cb: { data in
            print("===== messageReceived");
            if cb != nil{
                cb!(data: data);
            }
        });
    }

}