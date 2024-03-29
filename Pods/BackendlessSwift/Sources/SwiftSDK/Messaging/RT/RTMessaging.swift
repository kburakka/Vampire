//
//  RTMessaging.swift
//
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2019 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

class RTMessaging: RTListener {
    
    private let rtClient = RTClient.shared
    private let processResponse = ProcessResponse.shared
    
    private var channel: Channel
    private var channelName: String
    private var subscriptionId: String!
    
    init(channel: Channel) {
        self.channel = channel
        self.channelName = channel.channelName
    }
    
    func connect(responseHandler: (() -> Void)!, errorHandler: ((Fault) -> Void)!) {
        let options = ["channel": channelName] as [String : Any]
        let subscription = createSubscription(type: rtTypes.pubSubConnect, options: options, connectionHandler: responseHandler, responseHandler: nil, errorHandler: errorHandler)
        self.subscriptionId = subscription.subscriptionId
        subscription.subscribe()
    }
    
    func disconnect() {
        rtClient.unsubscribe(subscriptionId: subscriptionId)
        removeWaitingSubscriptions()
    }
    
    func addConnectListener(responseHandler: (() -> Void)!, errorHandler: ((Fault) -> Void)!) -> RTSubscription? {
        let wrappedBlock: (Any) -> () = { response in
            responseHandler()
        }
        let subscription = RTSubscription()
        subscription.subscriptionId = UUID().uuidString
        subscription.options = ["channel": channelName]
        subscription.onResult = wrappedBlock
        subscription.onError = errorHandler
        rtClient.addSimpleListener(type: rtTypes.pubSubConnect, subscription: subscription)
        return subscription
    }
    
    func removeConnectListeners() {
        rtClient.removeSimpleListeners(type: rtTypes.pubSubConnect)
    }
    
    func addStringMessageListener(selector: String?, responseHandler: ((String) -> Void)!, errorHandler: ((Fault) -> Void)!) -> RTSubscription? {
        let wrappedBlock: (Any) -> () = { response in
            if let response = response as? [String : Any],
                let message = response["message"] as? String {
                responseHandler(message)
            }
        }
        if self.channel.isJoined {
            var options = [String : Any]()
            options["channel"] = self.channelName
            if let selector = selector {
                options["selector"] = selector
            }
            let subscription = createSubscription(type: rtTypes.pubSubMessages, options: options, connectionHandler: nil, responseHandler: wrappedBlock, errorHandler: errorHandler)
            subscription.subscribe()
            return subscription
        }
        else {
            return addWaitingSubscription(event: rtTypes.pubSubMessages, selector: selector, responseHandler: wrappedBlock, errorHandler: errorHandler)
        }
    }
    
    func addDictionaryMessageListener(selector: String?, responseHandler: (([String : Any]) -> Void)!, errorHandler: ((Fault) -> Void)!) -> RTSubscription? {
        let wrappedBlock: (Any) -> () = { response in
            if let response = response as? [String : Any],
                let message = response["message"] as? [String : Any],
                message["___class"] == nil {
                responseHandler(message)
            }
        }
        if self.channel.isJoined {
            var options = [String : Any]()
            options["channel"] = self.channelName
            if let selector = selector {
                options["selector"] = selector
            }
            let subscription = createSubscription(type: rtTypes.pubSubMessages, options: options, connectionHandler: nil, responseHandler: wrappedBlock, errorHandler: errorHandler)
            subscription.subscribe()
            return subscription
        }
        else {
            return addWaitingSubscription(event: rtTypes.pubSubMessages, selector: selector, responseHandler: wrappedBlock, errorHandler: errorHandler)
        }
    }
    
    func addCustomObjectMessageListener(forClass: AnyClass, selector: String?, responseHandler: ((Any) -> Void)!, errorHandler: ((Fault) -> Void)!) -> RTSubscription? {
        let wrappedBlock: (Any) -> () = { response in
            if let response = response as? [String : Any],
                let message = response["message"] as? [String : Any],
                let className = message["___class"] as? String,
                className == PersistenceServiceUtils().getClassName(entity: forClass),
                let result = PersistenceServiceUtils().dictionaryToEntity(dictionary: message, className: className) {
                responseHandler(result)
            }
        }        
        if self.channel.isJoined {
            var options = [String : Any]()
            options["channel"] = self.channelName
            if let selector = selector {
                options["selector"] = selector
            }
            let subscription = createSubscription(type: rtTypes.pubSubMessages, options: options, connectionHandler: nil, responseHandler: wrappedBlock, errorHandler: errorHandler)
            subscription.subscribe()
            return subscription
        }
        else {
            return addWaitingSubscription(event: rtTypes.pubSubMessages, selector: selector, responseHandler: wrappedBlock, errorHandler: errorHandler)
        }
    }
    
    func addMessageListener(selector: String?, responseHandler: ((PublishMessageInfo) -> Void)!, errorHandler: ((Fault) -> Void)!) -> RTSubscription? {
        let wrappedBlock: (Any) -> () = { response in
            if let response = response as? [String : Any] {
                let publishMessageInfo = self.processResponse.adapt(responseDictionary: response, to: PublishMessageInfo.self)
                responseHandler(publishMessageInfo as! PublishMessageInfo)
            }            
        }
        if self.channel.isJoined {
            var options = [String : Any]()
            options["channel"] = self.channelName
            if let selector = selector {
                options["selector"] = selector
            }
            
            let subscription = createSubscription(type: rtTypes.pubSubMessages, options: options, connectionHandler: nil, responseHandler: wrappedBlock, errorHandler: errorHandler)
            subscription.subscribe()
            return subscription
        }
        return addWaitingSubscription(event: rtTypes.pubSubMessages, selector: selector, responseHandler: wrappedBlock, errorHandler: errorHandler)
    }
    
    func removeMessageListeners(selector: String?) {
        stopSubscriptionForChannel(channel: self.channel, event: rtTypes.pubSubMessages, selector: selector)
    }
    
    func addCommandListener(responseHandler: ((CommandObject) -> Void)!, errorHandler: ((Fault) -> Void)!) -> RTSubscription? {
        let wrappedBlock: (Any) -> () = { response in
            if let response = response as? [String : Any] {
                let commandObject = self.processResponse.adaptToCommandObject(commandObjectDictionary: response)
                responseHandler(commandObject)
            }
        }
        if self.channel.isJoined {
            let options = ["channel" : self.channelName] as [String : Any]
            let subscription = createSubscription(type: rtTypes.pubSubCommands, options: options, connectionHandler: nil, responseHandler: wrappedBlock, errorHandler: errorHandler)
            subscription.subscribe()
            return subscription
        }
        else {
            return addWaitingSubscription(event: rtTypes.pubSubCommands, selector: nil, responseHandler: wrappedBlock, errorHandler: errorHandler)
        }
    }
    
    func removeCommandListeners() {
        stopSubscriptionForChannel(channel: self.channel, event: rtTypes.pubSubCommands, selector: nil)
    }
    
    func addUserStatusListener(responseHandler: ((UserStatus) -> Void)!, errorHandler: ((Fault) -> Void)!) -> RTSubscription? {
        let wrappedBlock: (Any) -> () = { response in
            if let response = response as? [String : Any] {
                let userStatus = ProcessResponse.shared.adaptToUserStatus(userStatusDictionary: response)
                responseHandler(userStatus)
            }
        }
        if self.channel.isJoined {
            let options = ["channel" : self.channelName] as [String : Any]
            let subscription = createSubscription(type: rtTypes.pubSubUsers, options: options, connectionHandler: nil, responseHandler: wrappedBlock, errorHandler: errorHandler)
            subscription.subscribe()
            return subscription
        }
        else {
            return addWaitingSubscription(event: rtTypes.pubSubUsers, selector: nil, responseHandler: wrappedBlock, errorHandler: errorHandler)
        }
    }
    
    func removeUserStatusListeners() {
        stopSubscriptionForChannel(channel: self.channel, event: rtTypes.pubSubUsers, selector: nil)
    }
    
    // ********************************************
    
    func addWaitingSubscription(event: String, selector: String?, responseHandler: ((Any) -> Void)?, errorHandler: ((Fault) -> Void)!) -> RTSubscription? {
        var waitingSubscription: RTSubscription?
        var options = ["event": event, "channel": channelName]
        if let selector = selector {
            options["selector"] = selector
        }
        if responseHandler != nil {
            waitingSubscription = createSubscription(type: event, options: options, connectionHandler: nil, responseHandler: responseHandler, errorHandler: errorHandler)
        }
        if let waitingSubscription = waitingSubscription {
            RTClient.shared.waitingSubscriptions.append(waitingSubscription)
        }
        return waitingSubscription
    }
    
    func removeWaitingSubscriptions() {
        var indexesToRemove = [Int]() // waiting subscriptions will be removed
        for waitingSubscription in RTClient.shared.waitingSubscriptions {
            if let data = waitingSubscription.data,
                let name = data["name"] as? String,
                name == rtTypes.pubSubMessages ||
                    name == rtTypes.pubSubCommands ||
                    name == rtTypes.pubSubUsers,
                let options = waitingSubscription.options,
                options["channel"] as? String == self.channelName {
                indexesToRemove.append(RTClient.shared.waitingSubscriptions.firstIndex(of: waitingSubscription)!)
            }
        }
        RTClient.shared.waitingSubscriptions = RTClient.shared.waitingSubscriptions.enumerated().compactMap {
            indexesToRemove.contains($0.0) ? nil : $0.1
        }
    }
    
    func subscribeForWaiting() {
        var indexesToRemove = [Int]() // waiting subscriptions will be removed after subscription is done
        for waitingSubscription in RTClient.shared.waitingSubscriptions {
            if let data = waitingSubscription.data,
                let name = data["name"] as? String,
                name == rtTypes.pubSubMessages ||
                    name == rtTypes.pubSubCommands ||
                    name == rtTypes.pubSubUsers,
                let options = waitingSubscription.options,
                options["channel"] as? String == self.channelName {
                waitingSubscription.subscribe()
                indexesToRemove.append(RTClient.shared.waitingSubscriptions.firstIndex(of: waitingSubscription)!)
            }
        }
        RTClient.shared.waitingSubscriptions = RTClient.shared.waitingSubscriptions.enumerated().compactMap {
            indexesToRemove.contains($0.0) ? nil : $0.1
        }
    }
    
    func processConnectSubscriptions() {
        if var connectSubscriptions = RTClient.shared.getSimpleListeners(type: rtTypes.pubSubConnect) {
            connectSubscriptions = connectSubscriptions.filter({ $0.options?.contains(where: { $0.value as? String == self.channelName }) ?? false })
            for subscription in connectSubscriptions {
                subscription.onResult!(nil)
            }            
        }
    }
    
    func processConnectErrors(fault: Fault) {
        if var connectSubscriptions = RTClient.shared.getSimpleListeners(type: rtTypes.pubSubConnect) {
            connectSubscriptions = connectSubscriptions.filter({ $0.options?.contains(where: { $0.value as? String == self.channelName }) ?? false })
            for subscription in connectSubscriptions {
                subscription.onError!(fault)
            }
        }
    }
}
