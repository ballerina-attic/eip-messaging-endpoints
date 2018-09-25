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

documentation { Queue receiver endpoint for new geo related messages. }
endpoint mb:SimpleQueueReceiver queueReceiverGeoActivities {
    host: "localhost",
    port: 5672,
    queueName: "GeoActivities"
};
endpoint http:Client  GeoActivityEP {
    url: "http://localhost:8080/activity"
};
documentation { Queue receiver endpoint for health check messages of the sensors. }
endpoint mb:SimpleQueueReceiver queueReceiverHealth {
    host: "localhost",
    port: 5672,
    queueName: "SensorHealth"
};
endpoint http:Client  HealthEP {
    url: "http://localhost:8080/health"
};
documentation { Queue receiver endpoint for maintenance messages of sensors. }
endpoint mb:SimpleQueueReceiver queueReceiverMaintenance {
    host: "localhost",
    port: 5672,
    queueName: "Maintenance"
};
endpoint http:Client  MaintenanceEP {
    url: "http://localhost:8080/maintenance"
};
documentation { Queue receiver endpoint for calibration messages. }
endpoint mb:SimpleQueueReceiver queueReceiverCalibrate {
    host: "localhost",
    port: 5672,
    queueName: "Calibration"
};
endpoint http:Client  CalibrateEP {
    url: "http://localhost:8080/calibrate"
};
documentation { Service to receive messages to the new GeoActivities message queue. }
service<mb:Consumer> geoListener bind queueReceiverGeoActivities {
    documentation { Resource handler for new messages from queue. }
    onMessage(endpoint consumer, mb:Message message) {
        http:Request outRequest;
        string messageText = check message.getTextMessageContent();
        json requestPayload = messageText;
        outRequest.setJsonPayload(untaint requestPayload);
        var resp = GeoActivityEP->post("/", outRequest);
        log:printInfo("Message recived from queue GeoActivities: " + messageText + "status:forwarded to /activity");
    }
}
documentation { Service to receive messages to the SensorHealth message queue. }
service<mb:Consumer> healthListener bind queueReceiverHealth {
    documentation { Resource handler for new messages from queue. }
    onMessage(endpoint consumer, mb:Message message) {
        http:Request outRequest;
        string messageText = check message.getTextMessageContent();
        json requestPayload = messageText;
        outRequest.setJsonPayload(untaint requestPayload);
        var resp = HealthEP->post("/", outRequest);
        log:printInfo("Message recived from queue SensorHealth: " + messageText + "status:forwarded to /health");
    }
}
documentation { Service to receive messages to the Maintenance message queue. }
service<mb:Consumer> maintenanceListener bind queueReceiverMaintenance {
    documentation { Resource handler for new messages from queue. }
    onMessage(endpoint consumer, mb:Message message) {
        http:Request outRequest;
        string messageText = check message.getTextMessageContent();
        json requestPayload = messageText;
        outRequest.setJsonPayload(untaint requestPayload);
        var resp = MaintenanceEP->post("/", outRequest);
        log:printInfo("Message recived from queue Maintenance: " + messageText + "status:forwarded to /maintenance");
    }
}
documentation { Service to receive messages to the Calibration message queue. }
service<mb:Consumer> calibrateListener bind queueReceiverCalibrate {
    documentation { Resource handler for new messages from queue. }
    onMessage(endpoint consumer, mb:Message message) {
        http:Request outRequest;
        string messageText = check message.getTextMessageContent();
        json requestPayload = messageText;
        outRequest.setJsonPayload(untaint requestPayload);
        var resp = CalibrateEP->post("/", outRequest);
        log:printInfo("Message recived from queue Calibration: " + messageText + "status:forwarded to /calibrate");
    }
}