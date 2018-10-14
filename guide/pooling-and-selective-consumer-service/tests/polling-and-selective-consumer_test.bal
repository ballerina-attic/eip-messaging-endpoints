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
import ballerina/task;
import ballerina/test;
import ballerina/runtime;

# The ```queueSender``` is for sending the messages to the queue ```ProcessedQueue``` in order to process them
endpoint mb:SimpleQueueSender queueSender {
    host: "localhost",
    port: 5672,
    queueName: "ProcessedQueue"
};

# The endpoint ```subscriberSetAlarmOff``` subscribes to the topic-pattern of ```Alarm``` and consumes messages of that topic.
endpoint mb:SimpleTopicSubscriber subscriberSetAlarmOff {
    topicPattern: "Alarm"
};

# The endpoint ```subscriberNotifyAuthority``` subscribes to the topic-pattern of ```Authority``` and consumes messages of that topic.
endpoint mb:SimpleTopicSubscriber subscriberNotifyAuthority {
    topicPattern: "Authority"
};

# The endpoint ```subscriberMaintenance``` subscribes to the topic-pattern of ```StatusAndMaintenance``` and consumes messages of that topic.
endpoint mb:SimpleTopicSubscriber subscriberMaintenance {
    topicPattern: "StatusAndMaintenance"
};

# The endpoint ```subscriberResearch``` subscribes to the topic-pattern of ```Research``` and consumes messages of that topic.
endpoint mb:SimpleTopicSubscriber subscriberResearch {
    topicPattern: "Research"
};

string[4] messageTexts;

# The service ```AuthorityListener``` assiciated with the ```subscriberNotifyAuthority``` topic-subscriber which consumes the messages of the Authority topic.
service<mb:Consumer> AuthorityListener bind subscriberNotifyAuthority {
    onMessage(endpoint consumer, mb:Message message) {
        messageTexts[0] = untaint check message.getTextMessageContent();
    }
}
# The service ```AlarmListner``` assiciated with the ```subscriberSetAlarmOff``` topic-subscriber which consumes the messages of the Alarm topic.
service<mb:Consumer> AlarmListner bind subscriberSetAlarmOff {
    onMessage(endpoint consumer, mb:Message message) {
        messageTexts[1] = untaint check message.getTextMessageContent();
    }
}
# The service ```MaintenanceListener``` assiciated with the ```subscriberMaintenance``` topic-subscriber which consumes the messages of the StatusAndMaintenance topic.
service<mb:Consumer> MaintenanceListener bind subscriberMaintenance {
    onMessage(endpoint consumer, mb:Message message) {
        messageTexts[2] = untaint check message.getTextMessageContent();
    }
}
# The service ```ResearchListener``` assiciated with the ```subscriberResearch``` topic-subscriber which consumes the messages of the Research topic.
service<mb:Consumer> ResearchListener bind subscriberResearch {
    onMessage(endpoint consumer, mb:Message message) {
        messageTexts[3] = untaint check message.getTextMessageContent();
    }
}
# The function ```messagePublisher()``` sends the messages to ```ProcessedQueue```.
function messagePublisher() {
    json requestMessage1 = { "Message": "Earth Quake of 10 Richter Scale at the loaction near Panama", "AlarmStatus":
    "ON", "DesasterRecoveryTeamStatus": "Dispatched" };
    string msg1 = requestMessage1.toString();
    mb:Message message1 = check queueSender.createTextMessage(msg1);
    var p1 = message1.setPriority(1);
    log:printInfo("P1 is:" + check message1.getPriority());
    _ = queueSender->send(message1);
    runtime:sleep(5000);
    json requestMessage2 = { "AlarmStatus": "ON" };
    string msg2 = requestMessage2.toString();
    mb:Message message2 = check queueSender.createTextMessage(msg2);
    var p2 = message2.setPriority(2);
    log:printInfo("P2 is:" + check message2.getPriority());
    _ = queueSender->send(message2);
    runtime:sleep(5000);
    json requestMessage3 = { "Maintenance": "Need to send a maintenance team to the sensor with SID 4338" };
    string msg3 = requestMessage3.toString();
    mb:Message message3 = check queueSender.createTextMessage(msg3);
    var p3 = message3.setPriority(3);
    log:printInfo("P3 is:" + check message3.getPriority());
    _ = queueSender->send(message3);
    runtime:sleep(5000);
    json requestMessage4 = { "DATA": "lots of data need to analyze" };
    string msg4 = requestMessage4.toString();
    mb:Message message4 = check queueSender.createTextMessage(msg4);
    var p4 = message4.setPriority(4);
    log:printInfo("P4 is:" + check message4.getPriority());
    _ = queueSender->send(message4);
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
    json requestMessage1 = { "Message": "Earth Quake of 10 Richter Scale at the loaction near Panama", "AlarmStatus":
    "ON", "DesasterRecoveryTeamStatus": "Dispatched" };
    string msg1 = requestMessage1.toString();
    string expectedResponse = msg1;
    log:printInfo("Message 1 is :" + messageTexts[0]);
    test:assertEquals(messageTexts[0], expectedResponse, msg =
        "polling-and-selective-consumer-service failed at testNotifyAuthority");
}
@test:Config
function testSetAlarmOff() {
    json requestMessage2 = { "AlarmStatus": "ON" };
    string msg2 = requestMessage2.toString();
    string expectedResponse = msg2;
    //log:printInfo("Message 2 is :" + messageTexts[1]);
    test:assertEquals(messageTexts[1], expectedResponse, msg =
        "polling-and-selective-consumer-service failed at testSetAlarmOff");
}
@test:Config
function testMaintenance() {
    json requestMessage3 = { "Maintenance": "Need to send a maintenance team to the sensor with SID 4338" };
    string msg3 = requestMessage3.toString();
    string expectedResponse = msg3;
    //log:printInfo("Message 3 is :" + messageTexts[2]);
    test:assertEquals(messageTexts[2], expectedResponse, msg =
        "polling-and-selective-consumer-service failed at testMaintenance");
}
@test:Config
function testResearch() {
    json requestMessage4 = { "DATA": "lots of data need to analyze" };
    string msg4 = requestMessage4.toString();
    string expectedResponse = msg4;
    //log:printInfo("Message 4 is :" + messageTexts[3]);
    test:assertEquals(messageTexts[3], expectedResponse, msg =
        "polling-and-selective-consumer-service failed at testResearch");
}