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

// Endpoint for invoking the messaging-gateway-service.
endpoint http:Client httpEndpoint {
    url: "http://localhost:9090/service"
};

// Queue receiver endpoint for new geo related messages.
endpoint mb:SimpleQueueReceiver queueReceiverGeoActivities {
    host: "localhost",
    port: 5672,
    queueName: "GeoActivities"
};

// Queue receiver endpoint for health check messages.
endpoint mb:SimpleQueueReceiver queueReceiverHealth {
    host: "localhost",
    port: 5672,
    queueName: "SensorHealth"
};

// Queue receiver endpoint for maintenance messages.
endpoint mb:SimpleQueueReceiver queueReceiverMaintenance {
    host: "localhost",
    port: 5672,
    queueName: "Maintenance"
};

// Queue receiver endpoint for calibration messages.
endpoint mb:SimpleQueueReceiver queueReceiverCalibrate {
    host: "localhost",
    port: 5672,
    queueName: "Calibration"
};

string[4] messageTexts;

// Service to receive messages to the new Geo-Activity messages.
service<mb:Consumer> geoListener bind queueReceiverGeoActivities {
    onMessage(endpoint consumer, mb:Message message) {
        messageTexts[0] = untaint check message.getTextMessageContent();
    }
}

// Service to receive messages to the SensorHealth messages.
service<mb:Consumer> healthListener bind queueReceiverHealth {
    onMessage(endpoint consumer, mb:Message message) {
        messageTexts[1] = untaint check message.getTextMessageContent();
    }
}

// Service to receive messages to the Maintenance messages.
service<mb:Consumer> maintenanceListener bind queueReceiverMaintenance {
    onMessage(endpoint consumer, mb:Message message) {
        messageTexts[2] = untaint check message.getTextMessageContent();
    }
}

// Service to receive messages to the Calibration messages.
service<mb:Consumer> calibrateListener bind queueReceiverCalibrate {
    onMessage(endpoint consumer, mb:Message message) {
        messageTexts[3] = untaint check message.getTextMessageContent();
    }
}

// To invoke the messaging gateway service.
function messageSender() {
    http:Request activityReq;
    json activitySampleRequest = { "ID": 27125088, "SID": 4344, "TIME_S": "1536423224", "TIME_E":
    "1536423584", "TYPE": "EQ", "C_DATA": "41.40338, 2.17403", "R_SCALE": 10 };
    activityReq.setJsonPayload(activitySampleRequest);
    var activityResp = httpEndpoint->post("/activity", activityReq);
    runtime:sleep(2000);

    http:Request healthReq;
    json healthSampleRequest = { "ID": 67602894, "SID": 1781, "TIME_S": "1536596384", "STATUS":
    "1122" };
    healthReq.setJsonPayload(healthSampleRequest);
    var healthResp = httpEndpoint->post("/health", healthReq);
    runtime:sleep(2000);

    http:Request maintenanceReq;
    json maintenanceSampleRequest = { "ID": 88885089, "SID": 5848, "TIME_S": "1536578384", "DATA":
    "ROTC1234 module need to be replaced" };
    maintenanceReq.setJsonPayload(maintenanceSampleRequest);
    var maintenanceResp = httpEndpoint->post("/maintenance", maintenanceReq);
    runtime:sleep(2000);

    http:Request calibReq;
    json calibSampleRequest = { "ID": 54256677, "SID": 7098, "TIME_S": "1536599984", "DATA":
    "Sensor need to be calibrated" };
    calibReq.setJsonPayload(calibSampleRequest);
    var resp = httpEndpoint->post("/calibrate", calibReq);
    runtime:sleep(2000);
}
@test:BeforeSuite
function beforeFunc() {
    // Start messaging_gateway service
    _ = test:startServices("geoListener");
    _ = test:startServices("healthListener");
    _ = test:startServices("maintenanceListener");
    _ = test:startServices("calibrateListener");
    messageSender();
}
// After suite function
@test:AfterSuite
function afterFunc() {
    // Stop messaging_gateway service
    _ = test:stopServices("geoListener");
    _ = test:stopServices("healthListener");
    _ = test:stopServices("maintenanceListener");
    _ = test:stopServices("calibrateListener");
}
@test:Config
function testGeoActivities() {
    json sampleRequest = { "ID": 27125088, "SID": 4344, "TIME_S": "1536423224", "TIME_E":
    "1536423584", "TYPE": "EQ", "C_DATA": "41.40338, 2.17403", "R_SCALE": 10 };
    string expectedResponse = sampleRequest.toString();
    test:assertEquals(messageTexts[0], expectedResponse, msg =
        "messaging gateway service failed at testGeoActivties");
}
@test:Config
function testSensorHealth() {
    json sampleRequest = { "ID": 67602894, "SID": 1781, "TIME_S": "1536596384", "STATUS": "1122" };
    string expectedResponse = sampleRequest.toString();
    test:assertEquals(messageTexts[1], expectedResponse, msg =
        "messaging gateway service failed at testSesorHealth");
}
@test:Config
function testMaintenance() {
    json sampleRequest = { "ID": 88885089, "SID": 5848, "TIME_S": "1536578384", "DATA":
    "ROTC1234 module need to be replaced" };
    string expectedResponse = sampleRequest.toString();
    test:assertEquals(messageTexts[2], expectedResponse, msg =
        "messaging gateway service failed at testMaintenance");
}
@test:Config
function testCalibration() {
    json sampleRequest = { "ID": 54256677, "SID": 7098, "TIME_S": "1536599984", "DATA":
    "Sensor need to be calibrated" }
    ;
    string expectedResponse = sampleRequest.toString();
    test:assertEquals(messageTexts[3], expectedResponse, msg =
        "messaging gateway service failed at testCalibration");
}
