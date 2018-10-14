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

# The ```queueGeoMessage``` endpoint defines the message queue endpoint which associated with the queue ```GeoActivities``` for sending geo activities captured from the sensor.
endpoint mb:SimpleQueueSender queueGeoMessage {
    host: "localhost",
    port: 5672,
    queueName: "GeoActivities"
};

# The ```queueHealthCheck``` endpoint defines the message queue endpoint which associated with the queue ```SensorHealth``` to health check messages.
endpoint mb:SimpleQueueSender queueHealthCheck {
    host: "localhost",
    port: 5672,
    queueName: "SensorHealth"
};

# The ```queueMaintenance``` define the message queue endpoint which associated with the queue ```Maintenance``` for maintenance messages.
endpoint mb:SimpleQueueSender queueMaintenance {
    host: "localhost",
    port: 5672,
    queueName: "Maintenance"
};

# The ```queueCalibration``` define the message queue endpoint which associated with the queue ```Calibration``` for maintenance messages.
endpoint mb:SimpleQueueSender queueCalibration {
    host: "localhost",
    port: 5672,
    queueName: "Calibration"
};

# The endpoint ```sensorEventListner``` associated with the service ```SensorEventService```. The port associated with the service is 9090.
endpoint http:Listener sensorEventListner {
    port: 9090
};

# The base path of the ```SensorEventService``` service is ```/service``` via HTTP/1.1.
# The resource path for receiving geo activities captured from the sensor is defined as ```/activity```.
# The resource path for checking the health of the EP of the sensor is defined as ```/health```
# The resource path for invoking a service when the sensor needed mainteinance is defined as ```/maintenance```
# The resource path for invoking a service when the sensor needed calibration is defined as ```/calibrate```
# The received messages on each aforementioned resources paths will be forworded to each related message queues by the assoaciation of below queue senders.
# ```queueGeoMessage```, ```queueHealthCheck```,  ```queueMaintenance```, and the ```queueCalibration```.
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
        json requestMessage = check req.getJsonPayload();
        string msg = requestMessage.toString();
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
        json requestMessage = check req.getJsonPayload();
        string msg = requestMessage.toString();
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
        json requestMessage = check req.getJsonPayload();
        string msg = requestMessage.toString();
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
        json requestMessage = check req.getJsonPayload();
        string msg = requestMessage.toString();
        mb:Message message = check queueCalibration.createTextMessage(msg);
        _ = queueCalibration->send(message) but {
            error e => log:printError("Error sending message", err = e)
        };
        res.setTextPayload("status: successful");
        _ = conn->respond(res);
        log:printInfo("Message received at /calibrate: " + msg + "status:forwarded");
    }
}
