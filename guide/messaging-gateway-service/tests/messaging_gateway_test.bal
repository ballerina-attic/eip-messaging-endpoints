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
import ballerina/mb;
import ballerina/runtime;
import ballerina/task;
import ballerina/test;

endpoint http:Client httpEndpoint {
    url: "http://localhost:9090/service"
};
documentation { Queue receiver endpoint for new geo related messages. }
endpoint mb:SimpleQueueReceiver queueReceiverGeoActivities {
    host: "localhost",
    port: 5672,
    queueName: "GeoActivities"
};
documentation { Queue receiver endpoint for health check messages of the sensors. }
endpoint mb:SimpleQueueReceiver queueReceiverHealth {
    host: "localhost",
    port: 5672,
    queueName: "SensorHealth"
};
documentation { Queue receiver endpoint for maintenance messages of sensors. }
endpoint mb:SimpleQueueReceiver queueReceiverMaintenance {
    host: "localhost",
    port: 5672,
    queueName: "Maintenance"
};
documentation { Queue receiver endpoint for calibration messages. }
endpoint mb:SimpleQueueReceiver queueReceiverCalibrate {
    host: "localhost",
    port: 5672,
    queueName: "Calibration"
};
@test:BeforeSuite
function beforeFunc() {
    // Start messaging_gateway service
}
// After suite function
@test:AfterSuite
function afterFunc() {
    // Stop messaging_gateway service
}
@test:Config
function testGeoActivities() {
    http:Request req;
    json sampleRequest = { "ID": 27125088, "SID": 4344, "TIME_S": "1536423224", "TIME_E": "1536423584", "TYPE": "EQ",
        "C_DATA": "41.40338, 2.17403", "R_SCALE": 10 };
    req.setJsonPayload(sampleRequest);
    string expectedResponse = "status: Sucessfull";
    var resp = httpEndpoint->post("/activity", req);
    //test:assertEquals(resp.getTextPayload(), expectedResponse, msg = "messaging gateway service failed at testGeoActivties");
}
@test:Config
function testSensorHealth() {
    http:Request req;
    json sampleRequest = { "ID": 67602894, "SID": 1781, "TIME_S": "1536596384", "STATUS": "1122" };
    req.setJsonPayload(sampleRequest);
    string expectedResponse = "status: Sucessfull";
    var resp = httpEndpoint->post("/health", req);
    //test:assertEquals(resp.getTextPayload(), expectedResponse, msg = "messaging gateway service failed at testSesorHealth");
}
@test:Config
function testMaintenance() {
    http:Request req;
    json sampleRequest = { "ID": 88885089, "SID": 5848, "TIME_S": "1536578384", "DATA":
    "ROTC1234 module need to be replaced" };
    req.setJsonPayload(sampleRequest);
    string expectedResponse = "status: Sucessfull";
    var resp = httpEndpoint->post("/maintenance", req);
    //test:assertEquals(resp.getTextPayload(), expectedResponse, msg = "messaging gateway service failed at testMaintenance");
}
@test:Config
function testCalibration() {
    http:Request req;
    json sampleRequest = { "ID": 54256677, "SID": 7098, "TIME_S": "1536599984", "DATA": "Sensor need to be calibrated" }
    ;
    req.setJsonPayload(sampleRequest);
    string expectedResponse = "status: Sucessfull";
    var resp = httpEndpoint->post("/calibrate", req);
    //test:assertEquals(resp.getTextPayload(), expectedResponse, msg = "messaging gateway service failed at testCalibration");
}