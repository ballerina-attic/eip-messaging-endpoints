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

// Endpoint for sending the messages to ProcessedQueue.
endpoint mb:SimpleQueueSender queueSender {
    host: "localhost",
    port: 5672,
    queueName: "ProcessedQueue"
};

// Topic subscriber to the pattern: Alarm
endpoint mb:SimpleTopicSubscriber subscriberSetAlarmOff {
    topicPattern: "Alarm"
};

// Topic subscriber to the pattern: Authority
endpoint mb:SimpleTopicSubscriber subscriberNotifyAuthority {
    topicPattern: "Authority"
};


// Topic subscriber to the pattern: StatusAndMaintenance
endpoint mb:SimpleTopicSubscriber subscriberMaintenance {
    topicPattern: "StatusAndMaintenance"
};

// Topic subscriber to the pattern: Research
endpoint mb:SimpleTopicSubscriber subscriberResearch {
    topicPattern: "Research"
};

string[4] messageTexts;

// Service to  consumes the messages of the Authority topic.
service<mb:Consumer> AuthorityListener bind subscriberNotifyAuthority {
    onMessage(endpoint consumer, mb:Message message) {
        messageTexts[0] = untaint check message.getTextMessageContent();
    }
}
// Service to  consumes the messages of the Alarm topic.
service<mb:Consumer> AlarmListner bind subscriberSetAlarmOff {
    onMessage(endpoint consumer, mb:Message message) {
        messageTexts[1] = untaint check message.getTextMessageContent();
    }
}
// Service to  consumes the messages of the StatusAndMaintenance topic.
service<mb:Consumer> MaintenanceListener bind subscriberMaintenance {
    onMessage(endpoint consumer, mb:Message message) {
        messageTexts[2] = untaint check message.getTextMessageContent();
    }
}
// Service to  consumes the messages of the Research topic.
service<mb:Consumer> ResearchListener bind subscriberResearch {
    onMessage(endpoint consumer, mb:Message message) {
        messageTexts[3] = untaint check message.getTextMessageContent();
    }
}
// To sends the messages to ProcessedQueue.
function messagePublisher() {
    json priorityOneJson = { "Message":
    "An earthquake of magnitude 10 on the Richter scale near Panama", "AlarmStatus": "ON",
        "DisasterRecoveryTeamStatus": "Dispatched" };
    mb:Message priorityOneMessage = check queueSender.createTextMessage(priorityOneJson.toString());
    var priorityOne = priorityOneMessage.setPriority(1);
    _ = queueSender->send(priorityOneMessage) but {
        error e => log:printError("Error sending message", err = e)
    };
    runtime:sleep(5000);

    json priorityTwoJson = { "AlarmStatus": "ON" };
    mb:Message priorityTwoMessage = check queueSender.createTextMessage(priorityTwoJson.toString());
    var priorityTwo = priorityTwoMessage.setPriority(2);
    _ = queueSender->send(priorityTwoMessage) but {
        error e => log:printError("Error sending message", err = e)
    };
    runtime:sleep(5000);

    json priorityThreeJson = { "Maintenance":
    "Need to send a maintenance team to the sensor with SID 4338" };
    mb:Message priorityThreeMessage = check queueSender.createTextMessage(priorityThreeJson.toString
        ());
    var priorityThree = priorityThreeMessage.setPriority(3);
    _ = queueSender->send(priorityThreeMessage) but {
        error e => log:printError("Error sending message", err = e)
    };
    runtime:sleep(5000);

    json priorityFourJson = { "data store": "IUBA01IBMSTORE-0221", "entry no": "145QAZYNRFV11",
        "task": "ANALYZE", "priority": "IMMEDIATE" };
    mb:Message priorityFourMessage = check queueSender.createTextMessage(priorityFourJson.toString()
    );
    var priorityFour = priorityFourMessage.setPriority(4);
    _ = queueSender->send(priorityFourMessage) but {
        error e => log:printError("Error sending message", err = e)
    };
    runtime:sleep(5000);
}
@test:BeforeSuite
function beforeFunc() {
    // Start required services
    _ = test:startServices("AuthorityListener");
    _ = test:startServices("AlarmListner");
    _ = test:startServices("MaintenanceListener");
    _ = test:startServices("ResearchListener");
    messagePublisher();
}
@test:AfterSuite
function afterFunc() {
    // Stop started services
    _ = test:stopServices("AuthorityListener");
    _ = test:stopServices("AlarmListner");
    _ = test:stopServices("MaintenanceListener");
    _ = test:stopServices("ResearchListener");
}
@test:Config
function testNotifyAuthority() {
    json priorityOneJson = { "Message":
    "Earth Quake of 10 Richter Scale at the loaction near Panama", "AlarmStatus": "ON",
        "DesasterRecoveryTeamStatus": "Dispatched" };
    string expectedResponse = priorityOneJson.toString();
    log:printInfo("Message 1 is :" + messageTexts[0]);
    test:assertEquals(messageTexts[0], expectedResponse, msg =
        "polling-and-selective-consumer-service failed at testNotifyAuthority");
}
@test:Config
function testSetAlarmOff() {
    json priorityTwoJson = { "AlarmStatus": "ON" };
    string expectedResponse = priorityTwoJson.toString();
    test:assertEquals(messageTexts[1], expectedResponse, msg =
        "polling-and-selective-consumer-service failed at testSetAlarmOff");
}
@test:Config
function testMaintenance() {
    json priorityThreeJson = { "Maintenance":
    "Need to send a maintenance team to the sensor with SID 4338" };
    string expectedResponse = priorityThreeJson.toString();
    test:assertEquals(messageTexts[2], expectedResponse, msg =
        "polling-and-selective-consumer-service failed at testMaintenance");
}
@test:Config
function testResearch() {
    json priorityFourJson = { "DATA": "lots of data need to analyze" };
    string expectedResponse = priorityFourJson.toString();
    test:assertEquals(messageTexts[3], expectedResponse, msg =
        "polling-and-selective-consumer-service failed at testResearch");
}
