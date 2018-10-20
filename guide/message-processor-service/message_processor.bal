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

// The message queue endpoint for sending newly processed messages.
endpoint mb:SimpleQueueSender queueProcessedQueue {
    host: "localhost",
    port: 5672,
    queueName: "ProcessedQueue"
};

// The httpListner endpoint which associated with the MessageProcessingService service.
endpoint http:Listener httpListner {
    port: 8080
};

// Service to process messages and forward them.
@http:ServiceConfig {
    basePath: "/"
}
service<http:Service> MessageProcessingService bind httpListner {
    @http:ResourceConfig {
        methods: ["POST"],
        consumes: ["application/json"],
        produces: ["application/json"],
        path: "/activity"
    }
    activity(endpoint conn, http:Request req) {
        http:Response res = new;
        log:printInfo("Message received at /activity: " + check req.getTextPayload());
        json processedGeoJson = { "Message":
        "An earthquake of magnitude 10 on the Richter scale near Panama", "AlarmStatus": "ON",
            "DisasterRecoveryTeamStatus": "Dispatched" };
        mb:Message processedGeoMessage = check queueProcessedQueue.createTextMessage(
                                                                      processedGeoJson.toString());
        var geoMsgPriority = processedGeoMessage.setPriority(1);
        _ = queueProcessedQueue->send(processedGeoMessage) but {
            error e => log:printError("Error sending message", err = e)
        };
        json AlarmJson = { "AlarmStatus": "ON" };
        mb:Message AlarmMessage = check queueProcessedQueue.createTextMessage(AlarmJson.toString());
        var p2 = AlarmMessage.setPriority(2);
        _ = queueProcessedQueue->send(AlarmMessage) but {
            error e => log:printError("Error sending message", err = e)
        };
        res.setTextPayload("status: Received and processed by Message Processor");
        _ = conn->respond(res);
    }
    @http:ResourceConfig {
        methods: ["POST"],
        consumes: ["application/json"],
        produces: ["application/json"],
        path: "/health"
    }
    health(endpoint conn, http:Request req) {
        http:Response res = new;
        log:printInfo("Message received at /health: " + check req.getTextPayload());
        res.setTextPayload("status: Received and processed by Message Processor");
        _ = conn->respond(res);
    }
    @http:ResourceConfig {
        methods: ["POST"],
        consumes: ["application/json"],
        produces: ["application/json"],
        path: "/maintenance"
    }
    maintenance(endpoint conn, http:Request req) {
        http:Response res = new;
        log:printInfo("Message received at /maintenance: " + check req.getTextPayload());
        json responseMessage = { "Maintenance":
        "Need to send a maintenance team to the sensor with SID 4338" };
        mb:Message message = check queueProcessedQueue.createTextMessage(responseMessage.toString())
        ;
        var p = message.setPriority(3);
        _ = queueProcessedQueue->send(message) but {
            error e => log:printError("Error sending message", err = e)
        };
        res.setTextPayload("status: Received and processed by Message Processor");
        _ = conn->respond(res);
    }
    @http:ResourceConfig {
        methods: ["POST"],
        consumes: ["application/json"],
        produces: ["application/json"],
        path: "/calibrate"
    }
    calibrate(endpoint conn, http:Request req) {
        http:Response res = new;
        log:printInfo("Message received at /calibrate: " + check req.getTextPayload());
        json responseMessage = { "data store": "IUBA01IBMSTORE-0221", "entry no": "145QAZYNRFV11",
            "task": "ANALYZE", "priority": "IMMEDIATE" };
        mb:Message message = check queueProcessedQueue.createTextMessage(responseMessage.toString())
        ;
        var p = message.setPriority(4);
        _ = queueProcessedQueue->send(message) but {
            error e => log:printError("Error sending message", err = e)
        };
        res.setTextPayload("status: Received and processed by Message Processor");
        _ = conn->respond(res);
    }
}
