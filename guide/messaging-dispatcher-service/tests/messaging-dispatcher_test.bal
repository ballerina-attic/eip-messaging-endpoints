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

# The endpoint ```SetoffAlarm``` is to publish Priority 2 messages with the topicPattern: "```Alarm```", which are intend to dispatch to several endpoints later on.
endpoint jms:SimpleTopicPublisher SetoffAlarm {
    initialContextFactory: "bmbInitialContextFactory",
    providerUrl: "amqp://admin:admin@carbon/carbon" + "?brokerlist='tcp://localhost:5672'",
    acknowledgementMode: "AUTO_ACKNOWLEDGE",
    topicPattern: "Alarm"
};

# The ```serviceEventListner``` is the endpoint which defined the attributes associated with the ```EventService``` endpoint.
endpoint http:Listener serviceEventListner {
    port: 8080
};

# The ```EventService``` is for receiving the messages on each endpoints defined in the message-dispatcher-service
# The base pathe of the ```serviceEventListner``` endpoint via HTTP/1.1 is "/".
# The resources path for the Alarm 1 is ```/alarm1```.
# The resources path for the Alarm 2 is ```/alarm2```.
# And the resources path for the Alarm 3 is ```/alarm3```.
@http:ServiceConfig {
    basePath: "/"
}
service<http:Service> EventService bind serviceEventListner {
    @http:ResourceConfig {
        methods: ["POST"],
        consumes: ["application/json"],
        produces: ["application/json"],
        path: "/alarm1"
    }
    activity(endpoint conn, http:Request req) {
        http:Response res = new;
        log:printInfo("Message received at Alarm 1: " + check req.getTextPayload());
        res.setTextPayload("status: Received");
        _ = conn->respond(res);
    }
    @http:ResourceConfig {
        methods: ["POST"],
        path: "/alarm2"
    }
    health(endpoint conn, http:Request req) {
        http:Response res = new;
        log:printInfo("Message received at Alarm 2: " + check req.getTextPayload());
        res.setTextPayload("status: Received");
        _ = conn->respond(res);
    }
    @http:ResourceConfig {
        methods: ["POST"],
        path: "/alarm3"
    }
    maintanance(endpoint conn, http:Request req) {
        http:Response res = new;
        log:printInfo("Message received at Alarm 3: " + check req.getTextPayload());
        res.setTextPayload("status: Received");
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
    messageSender();
}
function messageSender() {
    json requestMessage = { "AlarmStatus": "ON" };
    match (SetoffAlarm.createTextMessage(requestMessage.toString())) {
        error e => {
            log:printError("Error occurred while creating message", err = e);
        }
        jms:Message msg => {
            SetoffAlarm->send(msg) but {
                error e => log:printError("Error occurred while sending" + "message", err = e)
            };
        }
    }
}
