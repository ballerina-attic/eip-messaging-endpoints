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
import ballerina/jms;
import ballerina/log;
import ballerina/mb;
import ballerina/io;

// Endpoints for dispatch messages arrive at messaging dispatcher service
endpoint http:Client  alarm1 {
    url: "http://localhost:8080/alarm1"
};

endpoint http:Client  alarm2 {
    url: "http://localhost:8080/alarm2"
};

endpoint http:Client  alarm3 {
    url: "http://localhost:8080/alarm3"
};

// The Jms endpoint which subscribed to the topicPattern: Alarm to consumes messages.
endpoint jms:SimpleTopicSubscriber subscriberSetAlarmOff {
    initialContextFactory: "bmbInitialContextFactory",
    providerUrl: "amqp://admin:admin@carbon/carbon?" + "brokerlist='tcp://localhost:5672'",
    acknowledgementMode: "AUTO_ACKNOWLEDGE",
    topicPattern: "Alarm"
};

//Service to dispatch the messages to alarm1, alarm2, alarm3 endpoints.
service<mb:Consumer> mbListener bind subscriberSetAlarmOff {
    onMessage(endpoint consumer, mb:Message message) {
        http:Request outRequest;
        string messageText = check message.getTextMessageContent();
        io:println(messageText);
        json requestPayload = messageText;
        outRequest.setJsonPayload(untaint requestPayload);
        var response1 = alarm1->post("/", outRequest);
        var response2 = alarm2->post("/", outRequest);
        var response3 = alarm3->post("/", outRequest);
        log:printInfo("Message had forwarded to /alarm1, /alarm2, /alarm3 endpoints: " + messageText
                + "status:forwarded");
    }
}
