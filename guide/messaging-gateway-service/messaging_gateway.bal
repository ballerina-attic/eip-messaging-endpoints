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

documentation { Define the message queue endpoint for sending geo activities captured from the sensor. }
endpoint mb:SimpleQueueSender queuesensorGeoMessage {
    host: "localhost",
    port: 5672,
    queueName: "GeoActivities"
};
documentation { Define the message queue endpoint to health check messages. }
endpoint mb:SimpleQueueSender queueHealthCheck {
    host: "localhost",
    port: 5672,
    queueName: "SensorHealth"
};
documentation { Define the message queue endpoint for maintenance messages. }
endpoint mb:SimpleQueueSender queueMaintenance {
    host: "localhost",
    port: 5672,
    queueName: "Maintenance"
};
documentation { Define the message queue endpoint for sensor calibration requests. }
endpoint mb:SimpleQueueSender queueCalibration {
    host: "localhost",
    port: 5672,
    queueName: "Calibration"
};
documentation { Attributes associated with the service endpoint. }
endpoint http:Listener sensorEventListner {
    port: 9090
};
documentation {  via HTTP/1.1. }
@http:ServiceConfig {
    basePath: "/service"
}
service<http:Service> SensorEventService bind sensorEventListner {
    @http:ResourceConfig {
        methods: ["POST"], consumes: ["application/json"], produces: ["application/json"],
        path: "/activity"
    }
    documentation { Resources for reciving geo activities captured from the sensor }
    activity(endpoint conn, http:Request req) {
        http:Response res = new;
        json requestMessage = check req.getJsonPayload();
        string msg = requestMessage.toString();
        mb:Message message = check queuesensorGeoMessage.createTextMessage(msg);
        _ = queuesensorGeoMessage->send(message);
        res.setTextPayload("status: Sucessfull");
        _ = conn->respond(res);
        log:printInfo("Message recived at /activity: " + msg + "status:forwarded");
    }
    @http:ResourceConfig {
        methods: ["POST"],
        path: "/health"
    }
    documentation { Resource for checking the health of the EP of the sensor}
    health(endpoint conn, http:Request req) {
        http:Response res = new;
        json requestMessage = check req.getJsonPayload();
        string msg = requestMessage.toString();
        mb:Message message = check queueHealthCheck.createTextMessage(msg);
        _ = queueHealthCheck->send(message);
        res.setTextPayload("status: Sucessfull");
        _ = conn->respond(res);
        log:printInfo("Message recived at /health: " + msg + "status:forwarded");
    }
    @http:ResourceConfig {
        methods: ["POST"],
        path: "/maintenance"
    }
    documentation { Resource for invoking a service when the sensor needed mainteinance }
    maintanance(endpoint conn, http:Request req) {
        http:Response res = new;
        json requestMessage = check req.getJsonPayload();
        string msg = requestMessage.toString();
        mb:Message message = check queueMaintenance.createTextMessage(msg);
        _ = queueMaintenance->send(message);
        res.setTextPayload("status: Sucessfull");
        _ = conn->respond(res);
        log:printInfo("Message recived at /maintenance: " + msg + "status:forwarded");
    }
    @http:ResourceConfig {
        methods: ["POST"],
        path: "/calibrate"
    }
    documentation { Resource for invoking a service when the sensor needed calibration }
    calibrate(endpoint conn, http:Request req) {
        http:Response res = new;
        json requestMessage = check req.getJsonPayload();
        string msg = requestMessage.toString();
        mb:Message message = check queueCalibration.createTextMessage(msg);
        _ = queueCalibration->send(message);
        res.setTextPayload("status: Sucessfull");
        _ = conn->respond(res);
        log:printInfo("Message recived at /calibrate: " + msg + "status:forwarded");
    }
}