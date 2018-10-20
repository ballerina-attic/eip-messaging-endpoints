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

// Queue receiver endpoint for the ProcessedQueue.
endpoint mb:SimpleQueueReceiver queueReceiver {
    host: "localhost",
    port: 5672,
    queueName: "ProcessedQueue"
};

// Endpoint for publish  Priority 1 messages.
endpoint mb:SimpleTopicPublisher NotifyAuthority {
    host: "localhost",
    port: 5672,
    topicPattern: "Authority"
};

// Endpoint for publish  Priority 2 messages.
endpoint mb:SimpleTopicPublisher AlarmSetoff {
    host: "localhost",
    port: 5672,
    topicPattern: "Alarm"
};

// Endpoint for publish  Priority 3 messages.
endpoint mb:SimpleTopicPublisher StatusAndMaintenance {
    host: "localhost",
    port: 5672,
    topicPattern: "StatusAndMaintenance"
};

// Endpoint for publish  Priority 4 messages.
endpoint mb:SimpleTopicPublisher Research {
    host: "localhost",
    port: 5672,
    topicPattern: "Research"
};

// Service to receive messages and publish them based on their priority.
service<mb:Consumer> geoListener bind queueReceiver {
    onMessage(endpoint consumer, mb:Message message) {
        int|error priority = message.getPriority() but {
            int i => i,
            error e => e
        };
        string messageText = check message.getTextMessageContent();
        log:printInfo("Message received with the priority of: " + check priority);
        if (priority == 1) {
            mb:Message msg = check NotifyAuthority.createTextMessage(messageText);
            _ = NotifyAuthority->send(msg) but {
                error e => log:printError("Error sending message", err = e)
            };
        } else if (priority == 2) {
            mb:Message msg = check AlarmSetoff.createTextMessage(messageText);
            _ = AlarmSetoff->send(msg) but {
                error e => log:printError("Error sending message", err = e)
            };
        } else if (priority == 3) {
            mb:Message msg = check StatusAndMaintenance.createTextMessage(messageText);
            _ = StatusAndMaintenance->send(msg) but {
                error e => log:printError("Error sending message", err = e)
            };
        } else if (priority == 4) {
            mb:Message msg = check Research.createTextMessage(messageText);
            _ = Research->send(msg) but {
                error e => log:printError("Error sending message", err = e)
            };
        }
    }
}
