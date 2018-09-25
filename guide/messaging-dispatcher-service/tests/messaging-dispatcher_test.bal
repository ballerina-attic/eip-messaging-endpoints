// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;
import ballerina/io;
import ballerina/jms;
import ballerina/log;
import ballerina/mb;
import ballerina/runtime;
import ballerina/task;
import ballerina/test;

documentation { Topic to publish Priority 2 messages. }
endpoint jms:SimpleTopicPublisher SetoffAlarm {
    initialContextFactory: "bmbInitialContextFactory",
    providerUrl: "amqp://admin:admin@carbon/carbon"
        + "?brokerlist='tcp://localhost:5672'",
    acknowledgementMode: "AUTO_ACKNOWLEDGE",
    topicPattern: "Alarm"
};
documentation { Attributes associated with the service endpoint. }
endpoint http:Listener serviceEventListner {
    port: 8080
};
documentation {  via HTTP/1.1. }
@http:ServiceConfig {
    basePath: "/"
}
service<http:Service> EventService bind serviceEventListner {
    @http:ResourceConfig {
        methods: ["POST"], consumes: ["application/json"], produces: ["application/json"],
        path: "/alarm1"
    }
    documentation { Resources for Alarm 1 }
    activity(endpoint conn, http:Request req) {
        http:Response res = new;
        json requestMessage = check req.getJsonPayload();
        string msg = requestMessage.toString();
        log:printInfo("Message Recives at Alarm 1: " + msg);
        res.setTextPayload("status: Recived");
        _ = conn->respond(res);
    }
    @http:ResourceConfig {
        methods: ["POST"],
        path: "/alarm2"
    }
    documentation { Resource for Alarm 2}
    health(endpoint conn, http:Request req) {
        http:Response res = new;
        json requestMessage = check req.getJsonPayload();
        string msg = requestMessage.toString();
        log:printInfo("Message Recives at Alarm 2: " + msg);
        res.setTextPayload("status: Recived");
        _ = conn->respond(res);
    }
    @http:ResourceConfig {
        methods: ["POST"],
        path: "/alarm3"
    }
    documentation { Resource for Alarm 3}
    maintanance(endpoint conn, http:Request req) {
        http:Response res = new;
        json requestMessage = check req.getJsonPayload();
        string msg = requestMessage.toString();
        log:printInfo("Message Recives at Alarm 3: " + msg);
        res.setTextPayload("status: Recived");
        _ = conn->respond(res);
    }
}
@test:BeforeSuite
function beforeFunc() {
    // Start EventService
    _ = test:startServices("EventService");
}
// After suite function
@test:AfterSuite
function afterFunc() {
    // Stop EventService
    _ = test:stopServices("EventService");
}
@test:Config
function testAlarm() {
    //Need to create a git issue for this
}
function main(string... args) {
    json requestMessage = { "AlarmStatus": "ON" };
    string messageText = requestMessage.toString();
    match (SetoffAlarm.createTextMessage(messageText)) {
        error e => {
            log:printError("Error occurred while creating message", err = e);
        }
        jms:Message msg => {
            SetoffAlarm->send(msg) but {
                error e => log:printError("Error occurred while sending"
                        + "message", err = e)
            };
        }
    }
}
