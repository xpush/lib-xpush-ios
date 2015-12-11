//
//  Xpush.swift
//  XpushFramework
//
//  Created by notdol on 8/29/15.
//  Copyright (c) 2015 stalk. All rights reserved.
//

import Foundation


public func XPushAPI()->Xpush{
    return Xpush.sharedInstance;
}

public func XPushChannel(id:String)->ChannelConnector
{
    return Xpush.sharedInstance.getChannel(id);
}

public class Xpush{
    var SESSION_SERVER_URL:String?;
    var SESSION_SOCKET_URL:String?;
    var SESSION_SOCKET_TOKEN:String?;
    var SESSION_SOCKET_ID:String?;
    
    var APP_ID:String?;
    var USER_ID:String?;
    var DEVICE_ID:String? = "web";
    
    var AUTH:String = "/auth";
    var SIGNUP:String = "/user/register/";
    var CHANENL:String = "/channel";
    var SIGNOUT:String = "/signout";
    var MESSAGE:String = "/msg";
    var NODE:String = "/node";
    var SESSION_SERVER:SocketConnector?;
    var CHANNEL_SERVERS:[String:ChannelConnector] = [String:ChannelConnector]();
    
    var host:String?
    var appId:String?
    
    public class func setup(host: String = "", appId:String = "") {
        _XpushInstance = Xpush(host: host, appId: appId);
    }
    
    public class var sharedInstance: Xpush {
        if _XpushInstance == nil {
            print("error: shared called before setup")
        }
        
        return _XpushInstance!
    }
    
    public init(host: String = "", appId:String = "") {
        if host != "" {
            self.SESSION_SERVER_URL = host;
            print("$$$ session server is : \(self.SESSION_SERVER_URL)");
        }
        if appId != ""{
            self.APP_ID = appId;
            print("$$$ application id : \(self.APP_ID)");
        }
    }
    
    public func signup(userId:String, passwd:String, cb:XpushRestCallback? = nil)->Void{
        var parameters:[String:AnyObject]? = [String:AnyObject]();
        parameters!["A"] = APP_ID;
        parameters!["U"] = userId;
        parameters!["PW"] = passwd;
        parameters!["D"] = DEVICE_ID;
        
        
        
        request(.POST, SESSION_SERVER_URL!+XpushConst.REST_SIGNUP, parameters: parameters)
            .responseJSON { res in
                let error = res.result.error;
                let json = res.result.value;
                if(error != nil) {
                    NSLog("Error: \(error)")
                }
                else {
                    NSLog("Success: \(self.SESSION_SERVER_URL)")
                    var json = JSON(json!);
                    print(json);
                    if json[XpushConst.RESULT_STATUS_KEY].string == XpushConst.RESULT_OK {
                        print("$$$ Signup Success $$$");
                    }else{
                        if cb != nil {
                            cb!(status: json["status"].stringValue, data: json);
                        }
                        print(json["message"]);
                    }
                }
        }
    }
    
    public func login(userId:String, passwd:String,  cb:XpushRestCallback? = nil)->Void{
        var parameters:[String:AnyObject]? = [String:AnyObject]();
        parameters!["A"] = APP_ID;
        parameters!["U"] = userId;
        parameters!["PW"] = passwd;
        parameters!["D"] = DEVICE_ID;
        
        request(.POST, SESSION_SERVER_URL!+AUTH, parameters: parameters)
            .responseJSON { res in
                let error = res.result.error;
                let json = res.result.value;
                
                if(error != nil) {
                    NSLog("Error: \(error)")
                }
                else {
                    NSLog("Success: \(self.SESSION_SERVER_URL)")
                    var json = JSON(json!);

                    if json[XpushConst.RESULT_STATUS_KEY].string == XpushConst.RESULT_OK {
                        if cb != nil {
                            cb!(status: json[XpushConst.RESULT_STATUS_KEY].stringValue, data: json);
                        }
                        
                        self.USER_ID = json[XpushConst.RESULT_KEY][XpushConst.USER_KEY][XpushConst.S_USER].string;
                        
                        self.SESSION_SOCKET_URL = json[XpushConst.SESSION_SERVER_URL_KEY].string;
                        self.SESSION_SOCKET_TOKEN = json[XpushConst.TOKEN].string;
                        self.SESSION_SOCKET_ID = json[XpushConst.SERVER].string;
                        
                        self.createSessionServer(json[XpushConst.RESULT_KEY]);
                    }else{
                        if cb != nil {
                            cb!(status: json[XpushConst.RESULT_STATUS_KEY].stringValue, data: json);
                        }
                        print(json["message"]);
                    }
                }
        }
    }
    
    
    public func getServerNodeInfo(channelId:String,  cb:XpushRestCallback? = nil)->Void{
        print("====== getServerNodeInfo "+channelId);
        request(.GET, SESSION_SERVER_URL!+XpushConst.REST_NODE+"/"+APP_ID!+"/"+channelId)
            .responseJSON { res in
                let error = res.result.error;
                let json = res.result.value;
                
                if(error != nil) {
                    NSLog("Error: \(error)")
                }
                else {
                    NSLog("Success: \(self.SESSION_SERVER_URL)")
                    var json = JSON(json!);
                    
                    if json[XpushConst.RESULT_STATUS_KEY].string == XpushConst.RESULT_OK {
                        if cb != nil {
                            cb!(status: json[XpushConst.RESULT_STATUS_KEY].stringValue, data: json);
                        }
                        
                    }else{
                        if cb != nil {
                            cb!(status: json[XpushConst.RESULT_STATUS_KEY].stringValue, data: json);
                        }
                        print(json["message"]);
                    }
                }
        }
    }
    
    
    public func channelList(cb:((data:JSON)->Void)? = nil)->Void{
        self.SESSION_SERVER?.channelList(cb);
    }
    
    public func createChannel(channelName:String? = nil,var users:[String]? = nil,cb:((data:JSON)->Void)? = nil)->Void{
        print("### xpush : createChannel");
        self.SESSION_SERVER?.createChannel(channelName, users: users, cb: cb);
    }
    
    public func userList(cb:XpushRestCallback? = nil)->Void{
        //self.SESSION_SERVER?.userList(cb);
        //let params:JSON = ["page": ["num": 1, "size" : 50 ]];
        var parameters:[String:AnyObject]? = [String:AnyObject]();
        parameters!["A"] = APP_ID;
        parameters!["K"] = "notdol";
        //parameters!["page"] = ["num": 1, "size" : 50 ];

        request(.POST, SESSION_SERVER_URL!+XpushConst.REST_USER_SEARCH, parameters: parameters)
            .responseJSON { res in
                let error = res.result.error;
                let json = res.result.value;
                
                if(error != nil) {
                    NSLog("Error: \(error)")
                }
                else {
                    NSLog("Success: \(self.SESSION_SERVER_URL)")
                    var json = JSON(json!);
                    
                    if json[XpushConst.RESULT_STATUS_KEY].string == XpushConst.RESULT_OK {
                        if cb != nil {
                            cb!(status: json[XpushConst.RESULT_STATUS_KEY].stringValue, data: json);
                        }
                    }else{
                        if cb != nil {
                            cb!(status: json[XpushConst.RESULT_STATUS_KEY].stringValue, data: json);
                        }
                    }
                }
        }
        
    }
    
    func getChannel(id:String)->ChannelConnector{
        if CHANNEL_SERVERS[id] == nil{
            let ch:ChannelConnector = self.createChannel(id);
            getServerNodeInfo(id, cb: { status, data in
                if(status == "ok"){
                    print(data);
                    ch.initWithServerInfo(data[XpushConst.RESULT_KEY]);
                }
            } );
            return ch;
        }else{
            return CHANNEL_SERVERS[id]!;
        }
    }
    
    func createChannel(id:String)->ChannelConnector{
        self.CHANNEL_SERVERS[id] = ChannelConnector(xpush: self);
        
        return CHANNEL_SERVERS[id]!;
    }
        
    func createSessionServer(info:JSON)->Void{
        self.SESSION_SERVER = SocketConnector(xpush:self);
        print("======= create sesseion server");
        print(info);
        self.SESSION_SERVER?.initWithServerInfo(info, cb: { data in
            print("===== socket Connected");
            /*
            self.SESSION_SERVER?.createChannel(nil, users:["notdol"], cb:{data in
                print("========= yes!");
                print(data);
            });
            */
        });
    }

    public func subscribe(channelId:String) -> ChannelConnector{
        print("====== subscribe : \(channelId)");
        return getChannel(channelId);
    }
}

private var _XpushInstance: Xpush?