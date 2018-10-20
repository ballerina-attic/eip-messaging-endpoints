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
import ballerina/log;
import ballerina/mb;

// Queue receiver endpoint for new geo related messages.
endpoint mb:SimpleQueueReceiver queueReceiverGeoActivities {
    host: "localhost",
    port: 5672,
    queueName: "GeoActivities"
};

// Geo-Activity message endpoint.
endpoint http:Client  GeoActivityEP {
    url: "http://localhost:8080/activity"
};

// Queue receiver endpoint for health check messages.
endpoint mb:SimpleQueueReceiver queueReceiverHealth {
    host: "localhost",
    port: 5672,
    queueName: "SensorHealth"
};

// Health message endpoint.
endpoint http:Client  HealthEP {
    url: "http://localhost:8080/health"
};

// Queue receiver endpoint for maintenance messages.
endpoint mb:SimpleQueueReceiver queueReceiverMaintenance {
    host: "localhost",
    port: 5672,
    queueName: "Maintenance"
};

endpoint http:Client  MaintenanceEP {
    url: "http://localhost:8080/maintenance"
};

// Queue receiver endpoint for calibration messages.
endpoint mb:SimpleQueueReceiver queueReceiverCalibrate {
    host: "localhost",
    port: 5672,
    queueName: "Calibration"
};

endpoint http:Client  CalibrateEP {
    url: "http://localhost:8080/calibrate"
};

// Service to receive messages to the new Geo-Activity messages.
service<mb:Consumer> geoListener bind queueReceiverGeoActivities {
    onMessage(endpoint consumer, mb:Message message) {
        http:Request outRequest;
        outRequest.setJsonPayload(untaint check message.getTextMessageContent());
        var resp = GeoActivityEP->post("/", outRequest);
        log:printInfo("Message received from queue GeoActivities: " + check message.
                getTextMessageContent() +
                "status:forwarded to /activity");
    }
}
// Service to receive messages to the SensorHealth message.
service<mb:Consumer> healthListener bind queueReceiverHealth {
    onMessage(endpoint consumer, mb:Message message) {
        http:Request outRequest;
        outRequest.setJsonPayload(untaint check message.getTextMessageContent());
        var resp = HealthEP->post("/", outRequest);
        log:printInfo("Message received from queue SensorHealth: " + message.getTextMessageContent()
                +
                "status:forwarded to /health");
    }
}
// Service to receive messages to the Maintenance messages.
service<mb:Consumer> maintenanceListener bind queueReceiverMaintenance {
    onMessage(endpoint consumer, mb:Message message) {
        http:Request outRequest;
        outRequest.setJsonPayload(untaint check message.getTextMessageContent());
        var resp = MaintenanceEP->post("/", outRequest);
        log:printInfo("Message received from queue Maintenance: " + check message.
                getTextMessageContent() +
                "status:forwarded to /maintenance");
    }
}
// Service to receive messages to the Calibration messages.
service<mb:Consumer> calibrateListener bind queueReceiverCalibrate {
    onMessage(endpoint consumer, mb:Message message) {
        http:Request outRequest;
        outRequest.setJsonPayload(untaint check message.getTextMessageContent());
        var resp = CalibrateEP->post("/", outRequest);
        log:printInfo("Message received from queue Calibration: " + check message.
                getTextMessageContent() +
                "status:forwarded to /calibrate");
    }
}
