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

# The endpoint ```queueReceiver``` is the queue receiver endpoint for the queue ```ProcessedQueue```.
endpoint mb:SimpleQueueReceiver queueReceiver {
    host: "localhost",
    port: 5672,
    queueName: "ProcessedQueue"
};

# The endpoint ```NotifyAuthority``` defines the topic to publish  Priority 1 messages as ```Authority```.
endpoint mb:SimpleTopicPublisher NotifyAuthority {
    host: "localhost",
    port: 5672,
    topicPattern: "Authority"
};

# The endpoint ```AlarmSetoff``` defines the topic to publish  Priority 2 messages as ```Alarm```.
endpoint mb:SimpleTopicPublisher AlarmSetoff {
    host: "localhost",
    port: 5672,
    topicPattern: "Alarm"
};

# The endpoint ```StatusAndMaintenance``` defines the topic to publish  Priority 3 messages as ```StatusAndMaintenance```.
endpoint mb:SimpleTopicPublisher StatusAndMaintenance {
    host: "localhost",
    port: 5672,
    topicPattern: "StatusAndMaintenance"
};

# The endpoint ```Research``` defines the topic to publish  Priority 4 messages as ```Research```.
endpoint mb:SimpleTopicPublisher Research {
    host: "localhost",
    port: 5672,
    topicPattern: "Research"
};

# The ```geoListener``` service is associated with the ```queueReceiver``` endpoint to receive messages and do the selection process based on the priority and then publish the message to the related topic.
# If the message has a priority of 1 then publish the  message using ```NotifyAuthority``` endpoint.
# If the message has a priority of 2 then publish the  message using ```AlarmSetoff``` endpoint.
# If the message has a priority of 3 then publish the  message using ```StatusAndMaintenance``` endpoint.
# If the message has a priority of 4 then publish the  message using ```Research``` endpoint.
service<mb:Consumer> geoListener bind queueReceiver {
    onMessage(endpoint consumer, mb:Message message) {
        int|error priority = message.getPriority() but {
            int i => i,
            error e => e
        };
        string messageText = check message.getTextMessageContent();
        log:printInfo("Message received with the priority of: " + check priority);
        if (priority == 1){
            mb:Message msg = check NotifyAuthority.createTextMessage(messageText);
            _ = NotifyAuthority->send(msg);
        } else if (priority == 2){
            mb:Message msg = check AlarmSetoff.createTextMessage(messageText);
            _ = AlarmSetoff->send(msg);
        } else if (priority == 3){
            mb:Message msg = check StatusAndMaintenance.createTextMessage(messageText);
            _ = StatusAndMaintenance->send(msg);
        } else if (priority == 4){
            mb:Message msg = check Research.createTextMessage(messageText);
            _ = Research->send(msg);
        }
    }
}
