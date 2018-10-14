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
import ballerina/runtime;
import ballerina/task;
import ballerina/test;

string activitymessage;
string healthMessage;
string maintenanceMessage;
string calibMessage;

# The endpoint ```queueGeoMessage``` define the message queue endpoint for sending geo activities captured from the sensor.
endpoint mb:SimpleQueueSender queueGeoMessage {
    host: "localhost",
    port: 5672,
    queueName: "GeoActivities"
};

# ```queueHealthCheck``` define the message queue endpoint to health check messages.
endpoint mb:SimpleQueueSender queueHealthCheck {
    host: "localhost",
    port: 5672,
    queueName: "SensorHealth"
};

# The endpoint ```queueMaintenance``` define the message queue endpoint for maintenance messages
endpoint mb:SimpleQueueSender queueMaintenance {
    host: "localhost",
    port: 5672,
    queueName: "Maintenance"
};

# The endpoint ```queueCalibration``` define the message queue endpoint for sensor calibration requests
endpoint mb:SimpleQueueSender queueCalibration {
    host: "localhost",
    port: 5672,
    queueName: "Calibration"
};

# The endpoint ```sensorEventListner``` is the service endpoint which listen to the variouus events.
endpoint http:Listener sensorEventListner {
    port: 8080
};

# The base path of the ```SensorEventService``` is ```\``` which listens to the ```sensorEventListner``` via HTTP/1.1
# Resource path for receiving geo activities captured from the sensor is ```/activity```
# Resource path for checking the health of the EP of the sensor is ```"/health"```
# Resource path for invoking a service when the sensor needed mainteinance is ```/maintenance```
# Resource path for invoking a service when the sensor needed calibration is ```/calibrat```
@http:ServiceConfig {
    basePath: "/"
}
service<http:Service> SensorEventService bind sensorEventListner {
    @http:ResourceConfig {
        methods: ["POST"],
        consumes: ["application/json"],
        produces: ["application/json"],
        path: "/activity"
    }

    activity(endpoint conn, http:Request req) {
        activitymessage = untaint check req.getTextPayload();
    }
    @http:ResourceConfig {
        methods: ["POST"],
        path: "/health"
    }
    health(endpoint conn, http:Request req) {
        http:Response res = new;
        healthMessage = untaint check req.getTextPayload();
        res.setPayload("Status Received");
    }
    @http:ResourceConfig {
        methods: ["POST"],
        path: "/maintenance"
    }
    maintenance(endpoint conn, http:Request req) {
        http:Response res = new;
        maintenanceMessage = untaint check req.getTextPayload();
        res.setPayload("Ack - maintenance team on the way");
    }
    @http:ResourceConfig {
        methods: ["POST"],
        path: "/calibrate"
    }
    calibrate(endpoint conn, http:Request req) {
        http:Response res = new;
        calibMessage = untaint check req.getTextPayload();
        res.setPayload("Ack - Calibration scheduled");
    }
}
function messageSender() {
    json sensorJson = { "ID": 27125088, "SID": 4344, "TIME_S": "1536423224", "TIME_E": "1536423584", "TYPE": "EQ",
        "C_DATA": "41.40338, 2.17403", "R_SCALE": 10 };
    mb:Message sensorMsg = check queueGeoMessage.createTextMessage(sensorJson.toString());
    _ = queueGeoMessage->send(sensorMsg) but {
        error e => log:printError("Error sending message", err = e)
    };

    json healthJson = { "ID": 67602894, "SID": 1781, "TIME_S": "1536596384", "STATUS": "1122" };
    mb:Message healthMsg = check queueGeoMessage.createTextMessage(healthJson.toString());
    _ = queueHealthCheck->send(healthMsg) but {
        error e => log:printError("Error sending message", err = e)
    };

    json maintenanceJson = { "ID": 88885089, "SID": 5848, "TIME_S": "1536578384", "DATA":
    "ROTC1234 module need to be replaced" };
    mb:Message maintenanceMsg = check queueGeoMessage.createTextMessage(maintenanceJson.toString());
    _ = queueMaintenance->send(maintenanceMsg) but {
        error e => log:printError("Error sending message", err = e)
    };

    json calibJson = { "ID": 54256677, "SID": 7098, "TIME_S": "1536599984", "DATA": "Sensor need to be calibrated" };
    mb:Message calibMsg = check queueGeoMessage.createTextMessage(calibJson.toString());
    _ = queueCalibration->send(calibMsg) but {
        error e => log:printError("Error sending message", err = e)
    };
}
@test:BeforeSuite
function beforeFunc() {
    // Start SensorEventService service
    _ = test:startServices("SensorEventService");
    messageSender();
    runtime:sleep(5000);
}
// After suite function
@test:AfterSuite
function afterFunc() {
// Stop SensorEventService service
    test:stopServices("SensorEventService");
}
@test:Config
function testGeoActivitiesEP() {
    json sampleRequest = { "ID": 27125088, "SID": 4344, "TIME_S": "1536423224", "TIME_E": "1536423584", "TYPE": "EQ",
        "C_DATA": "41.40338, 2.17403", "R_SCALE": 10 };
    string expectedResponse = sampleRequest.toString();
    test:assertEquals(activitymessage, expectedResponse, msg =
        "event-driven-and-pooling-consumer-service failed at testGeoActivties EndPoint");
}
@test:Config
function testSensorHealthEP() {
    json sampleRequest = { "ID": 67602894, "SID": 1781, "TIME_S": "1536596384", "STATUS": "1122" };
    string expectedResponse = sampleRequest.toString();
    test:assertEquals(healthMessage, expectedResponse, msg =
        "event-driven-and-pooling-consumer-service failed at testSesorHealth EndPoint");
}
@test:Config
function testMaintenanceEP() {
    json sampleRequest = { "ID": 88885089, "SID": 5848, "TIME_S": "1536578384", "DATA":
    "ROTC1234 module need to be replaced" };
    string expectedResponse = sampleRequest.toString();
    test:assertEquals(maintenanceMessage, expectedResponse, msg =
        "event-driven-and-pooling-consumer-service failed at testMaintenance EndPoint");
}
@test:Config
function testCalibrationEP() {
    json sampleRequest = { "ID": 54256677, "SID": 7098, "TIME_S": "1536599984", "DATA": "Sensor need to be calibrated" }
    ;
    string expectedResponse = sampleRequest.toString();
    test:assertEquals(calibMessage, expectedResponse, msg =
        "event-driven-and-pooling-consumer-service failed at testCalibration EndPoint");
}
