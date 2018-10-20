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

# Queue receiver endpoint for new geo related messages is ```queueReceiverGeoActivities```
endpoint mb:SimpleQueueReceiver queueReceiverGeoActivities {
    host: "localhost",
    port: 5672,
    queueName: "GeoActivities"
};

endpoint http:Client  GeoActivityEP {
    url: "http://localhost:8080/activity"
};

# Queue receiver endpoint for health check messages of the sensors is ```queueReceiverHealth```
endpoint mb:SimpleQueueReceiver queueReceiverHealth {
    host: "localhost",
    port: 5672,
    queueName: "SensorHealth"
};

endpoint http:Client  HealthEP {
    url: "http://localhost:8080/health"
};

# Queue receiver endpoint for maintenance messages of sensors is ```queueReceiverMaintenance```
endpoint mb:SimpleQueueReceiver queueReceiverMaintenance {
    host: "localhost",
    port: 5672,
    queueName: "Maintenance"
};

endpoint http:Client  MaintenanceEP {
    url: "http://localhost:8080/maintenance"
};

# Queue receiver endpoint for calibration messages ```queueReceiverCalibrate```
endpoint mb:SimpleQueueReceiver queueReceiverCalibrate {
    host: "localhost",
    port: 5672,
    queueName: "Calibration"
};

endpoint http:Client  CalibrateEP {
    url: "http://localhost:8080/calibrate"
};

# Service to receive messages to the new Geo-Activity messages queue is ```GeoActivities```,
# which listens to the ```queueReceiverGeoActivities```
# The ```geoListener``` resource handler is for the new messages from queue ```GeoActivities```.
service<mb:Consumer> geoListener bind queueReceiverGeoActivities {
    onMessage(endpoint consumer, mb:Message message) {
        http:Request outRequest;
        outRequest.setJsonPayload(untaint check message.getTextMessageContent());
        var resp = GeoActivityEP->post("/", outRequest);
        log:printInfo("Message received from queue GeoActivities: " + check message.getTextMessageContent() +
                "status:forwarded to /activity");
    }
}
# Service to receive messages to the SensorHealth message queue is ```SensorHealth``` ,
# which listens to the ```queueReceiverHealth```
# The ```healthListener``` resource handler is for the new messages from queue ```SensorHealth```
service<mb:Consumer> healthListener bind queueReceiverHealth {
    onMessage(endpoint consumer, mb:Message message) {
        http:Request outRequest;
        outRequest.setJsonPayload(untaint check message.getTextMessageContent());
        var resp = HealthEP->post("/", outRequest);
        log:printInfo("Message received from queue SensorHealth: " + message.getTextMessageContent() +
                "status:forwarded to /health");
    }
}
# Service to receive messages to the Maintenance message queue ```Maintenance```,
# which listens to the ```queueReceiverMaintenance```
# The ```maintenanceListener``` resource handler is for the new messages from queue ```Maintenance```
service<mb:Consumer> maintenanceListener bind queueReceiverMaintenance {
    onMessage(endpoint consumer, mb:Message message) {
        http:Request outRequest;
        outRequest.setJsonPayload(untaint check message.getTextMessageContent());
        var resp = MaintenanceEP->post("/", outRequest);
        log:printInfo("Message received from queue Maintenance: " + check message.getTextMessageContent() +
                "status:forwarded to /maintenance");
    }
}
# Service to receive messages to the Calibration message queue ```Calibration```,
# which listens to the ```queueReceiverCalibrate```
# The ```calibrateListener``` resource handler is for the new messages from queue ```Calibration```
service<mb:Consumer> calibrateListener bind queueReceiverCalibrate {
    onMessage(endpoint consumer, mb:Message message) {
        http:Request outRequest;
        outRequest.setJsonPayload(untaint check message.getTextMessageContent());
        var resp = CalibrateEP->post("/", outRequest);
        log:printInfo("Message received from queue Calibration: " + check message.getTextMessageContent() +
                "status:forwarded to /calibrate");
    }
}
