//
//  XpushConst.swift
//  XpushFramework
//
//  Created by notdol on 8/30/15.
//  Copyright (c) 2015 stalk. All rights reserved.
//

import Foundation


class XpushConst{
    static var SERVER:String = "server";
    static var CHANNEL:String = "channel";
    static var NAME:String = "name";
    static var URL:String = "url";
    
    static var GLOBAL_NS:String = "/global";
    static var CHANNEL_NS:String = "/"+CHANNEL;
    
    static var RESULT_OK:String = "ok";
    static var RESULT_STATUS_KEY:String = "status";
    static var RESULT_KEY:String = "result";
    
    static var USER_KEY:String = "user";
    
    static var S_USER:String = "U";
    static var S_DEVICE:String = "D";
    static var S_TOKEN:String = "TK";
    static var S_APPLICATION:String = "A";
    
    static var SESSION_SERVER_URL_KEY:String = "serverUrl";
    static var TOKEN:String = "token";

    static var CREATE_CHANNEL:String = "channel-create";
    
    static var SS_CHANNEL_CREATE = "channel.create";
    static var SS_CHANNEL_LIST = "channel.list";
    static var SS_CHANNEL_UPDATE = "channel-update";
    static var SS_CHANNEL_GET = "channel-get";
    static var SS_CHANNEL_EXIT = "channel-exit";
    static var SS_USER_LIST = "user-list";
    static var SS_USER_QUERY = "user-query";
    static var SS_CHANNEL_LIST_ACTIVE = "channel-list-active";
    static var SS_MESSAGE_UNREAD = "message-unread";
    static var SS_MESSAGE_RECEIVED = "message-received";
    
    static var SS_GLOBAL_EVENT_KEY = "_event";
    static var SS_EVENT_KEY = "event";
    
    static var CH_USERS = "users";
    static var CH_SEND_MESSAGE = "send";
    
    
    
    static var REST_AUTH:String = "/auth";
    static var REST_SIGNUP:String = "/user/register";
    static var REST_USER_SEARCH:String = "/user/search";
    static var REST_CHANENL:String = "/"+CHANNEL;
    static var REST_SIGNOUT:String = "/signout";
    static var REST_MESSAGE:String = "/msg";
    static var REST_NODE:String = "/node";
    
    
}