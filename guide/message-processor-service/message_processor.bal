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
import ballerina/log;
import ballerina/mb;

# The endpoint ```queueProcessedQueue``` is the message queue endpoint for sending newly processed messages from the ```message-processor-service```.
endpoint mb:SimpleQueueSender queueProcessedQueue {
    host: "localhost",
    port: 5672,
    queueName: "ProcessedQueue"
};

# The endpoint ```httpListner``` which listen on port:```8080``` is associated with the ```MessageProcessingService``` service endpoint.
endpoint http:Listener httpListner {
    port: 8080
};

# The base path for the ```MessageProcessingService``` which associated with ```httpListner``` via HTTP/1.1.
# The resources path for reciving geo activities is ```/activity```
# The resources path for reciving geo activities is ```/health```
# The resources path for reciving geo activities is ```/maintenanc```
# The resources path for reciving geo activities is ```/calibrate```
# Each above resource paths consumes and produces messages of Content-Type: ```application/json```
@http:ServiceConfig {
    basePath: "/"
}
service<http:Service> MessageProcessingService bind httpListner {
    @http:ResourceConfig {
        methods: ["POST"], consumes: ["application/json"], produces: ["application/json"],
        path: "/activity"
    }
    activity(endpoint conn, http:Request req) {
        http:Response res = new;
        json requestMessage = check req.getJsonPayload();
        log:printInfo("Message resived at /activity: " + requestMessage.toString());
        json responseMessage1 = { "Message": "Earth Quake of 10 Richter Scale at the loaction near Panama",
            "AlarmStatus":
            "ON", "DesasterRecoveryTeamStatus": "Dispatched" };
        string msg1 = responseMessage1.toString();
        mb:Message message1 = check queueProcessedQueue.createTextMessage(msg1);
        var p = message1.setPriority(1);
        _ = queueProcessedQueue->send(message1);
        json responseMessage2 = { "AlarmStatus": "ON" };
        string msg2 = responseMessage2.toString();
        mb:Message message2 = check queueProcessedQueue.createTextMessage(msg2);
        var p2 = message2.setPriority(2);
        log:printInfo("Notifying Authority and then set off alarms" + msg2);
        _ = queueProcessedQueue->send(message2);
        res.setTextPayload("status: Recived and processed by Message Processor");
        _ = conn->respond(res);
    }
    @http:ResourceConfig {
        methods: ["POST"], consumes: ["application/json"], produces: ["application/json"],
        path: "/health"
    }
    health(endpoint conn, http:Request req) {
        http:Response res = new;
        json requestMessage = check req.getJsonPayload();
        log:printInfo("Message resived at /health: " + requestMessage.toString());
        res.setTextPayload("status: Recived and processed by Message Processor");
        _ = conn->respond(res);
    }
    @http:ResourceConfig {
        methods: ["POST"], consumes: ["application/json"], produces: ["application/json"],
        path: "/maintenance"
    }
    maintenance(endpoint conn, http:Request req) {
        http:Response res = new;
        json requestMessage = check req.getJsonPayload();
        log:printInfo("Message resived at /maintenance: " + requestMessage.toString());
        json responseMessage = { "Maintenance": "Need to send a maintenance team to the sensor with SID 4338" };
        string msg = responseMessage.toString();
        mb:Message message = check queueProcessedQueue.createTextMessage(msg);
        var p = message.setPriority(3);
        _ = queueProcessedQueue->send(message);
        res.setTextPayload("status: Recived and processed by Message Processor");
        _ = conn->respond(res);
    }
    @http:ResourceConfig {
        methods: ["POST"], consumes: ["application/json"], produces: ["application/json"],
        path: "/calibrate"
    }
    calibrate(endpoint conn, http:Request req) {
        http:Response res = new;
        json requestMessage = check req.getJsonPayload();
        log:printInfo("Message resived at /calibrate: " + requestMessage.toString());
        json responseMessage = { "DATA": "lots of data need to analyze" };
        string msg = responseMessage.toString();
        mb:Message message = check queueProcessedQueue.createTextMessage(msg);
        var p = message.setPriority(4);
        _ = queueProcessedQueue->send(message);
        res.setTextPayload("status: Recived and processed by Message Processor");
        _ = conn->respond(res);
    }
}