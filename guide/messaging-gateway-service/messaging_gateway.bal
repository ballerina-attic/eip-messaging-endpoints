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

// Endpoint for sending geo activity messages.
endpoint mb:SimpleQueueSender queueGeoMessage {
    host: "localhost",
    port: 5672,
    queueName: "GeoActivities"
};

// Endpoint for sending health messages.
endpoint mb:SimpleQueueSender queueHealthCheck {
    host: "localhost",
    port: 5672,
    queueName: "SensorHealth"
};

// Endpoint for sending maintenance messages.
endpoint mb:SimpleQueueSender queueMaintenance {
    host: "localhost",
    port: 5672,
    queueName: "Maintenance"
};

// Endpoint for sending calibration messages.
endpoint mb:SimpleQueueSender queueCalibration {
    host: "localhost",
    port: 5672,
    queueName: "Calibration"
};

// The endpoint associated with the service SensorEventService.
endpoint http:Listener sensorEventListner {
    port: 9090
};

// Service to receive messages.
@http:ServiceConfig {
    basePath: "/service"
}
service<http:Service> SensorEventService bind sensorEventListner {
    @http:ResourceConfig {
        methods: ["POST"],
        consumes: ["application/json"],
        produces: ["plain/text"],
        path: "/activity"
    }
    activity(endpoint conn, http:Request req) {
        http:Response res = new;
        string msg = check req.getTextPayload();
        mb:Message message = check queueGeoMessage.createTextMessage(msg);
        _ = queueGeoMessage->send(message) but {
            error e => log:printError("Error sending message", err = e)
        };
        res.setTextPayload("status: successful");
        _ = conn->respond(res);
        log:printInfo("Message received at /activity: " + msg + "status:forwarded");
    }
    @http:ResourceConfig {
        methods: ["POST"],
        path: "/health"
    }
    health(endpoint conn, http:Request req) {
        http:Response res = new;
        string msg = check req.getTextPayload();
        mb:Message message = check queueHealthCheck.createTextMessage(msg);
        _ = queueHealthCheck->send(message) but {
            error e => log:printError("Error sending message", err = e)
        };
        res.setTextPayload("status: successful");
        _ = conn->respond(res);
        log:printInfo("Message received at /health: " + msg + "status:forwarded");
    }
    @http:ResourceConfig {
        methods: ["POST"],
        path: "/maintenance"
    }
    maintanance(endpoint conn, http:Request req) {
        http:Response res = new;
        string msg = check req.getTextPayload();
        mb:Message message = check queueMaintenance.createTextMessage(msg);
        _ = queueMaintenance->send(message) but {
            error e => log:printError("Error sending message", err = e)
        };
        res.setTextPayload("status: successful");
        _ = conn->respond(res);
        log:printInfo("Message received at /maintenance: " + msg + "status:forwarded");
    }
    @http:ResourceConfig {
        methods: ["POST"],
        path: "/calibrate"
    }
    calibrate(endpoint conn, http:Request req) {
        http:Response res = new;
        string msg = check req.getTextPayload();
        mb:Message message = check queueCalibration.createTextMessage(msg);
        _ = queueCalibration->send(message) but {
            error e => log:printError("Error sending message", err = e)
        };
        res.setTextPayload("status: successful");
        _ = conn->respond(res);
        log:printInfo("Message received at /calibrate: " + msg + "status:forwarded");
    }
}
