# eip-messaging-endpoints

This Guide will illustrate how to use ballerina to implement following scenarios.
1. Messaging Gateway 
2. Polling Consumer 
3. Event-Driven Consumer 
4. Message Dispatcher
5. Selective Consumer 

> Let’s take a look at a sample real world scenario to understand how to implement messaging endpoints patterns using Ballerina.

The following are the sections available in this guide.
- [What you'll build](#what-youll-build)
- [Prerequisites](#prerequisites)
- [Optional requirements](#optional-requirements)
- [Implementation](#implementation)
- [Testing](#testing)
- [Deployment](#deployment)
- [Observability](#observability)

## What you'll build
In this guide you will build messaging integration for disaster notification system which is listening to sensors which sends information on earth’s  geo-physical or climatic events and process that data. After that relevant authorities are notified automatically and set off an alarm. Below Figure shows the high level component architecture.

![alt text](https://github.com/LahiruLS/eip-messaging-endpoints/blob/master/images/Component_Architecture_Diagram.jpg?raw=true "Title")

Above figure shows each EIP which are used in this use case and also the flow starting from the sensor message. Let's discuss each of the components separately for their functionalities and implementation.

### Messaging Gateway

A Messaging Gateway can be implemented in two different ways:
Blocking (Synchronous) Messaging Gateway
Event-Driven (Asynchronous) Messaging Gateway

In this section we discuss the first one. The Messaging Gateway EIP encapsulates message-specific code from the rest of the application. It is a class that wraps messaging-specific method calls and exposes domain-specific methods to the application. Only the Messaging Gateway knows about the actual implementation of the messaging system. The rest of the application calls the methods of the Messaging Gateway, which are exposed to external applications. 

<img src="https://github.com/LahiruLS/eip-messaging-endpoints/blob/master/images/MG_EIP.jpg" width="360" height="360" />

In this use case we are not exposing real back end services and we pass through and forward each message according to the disaster type by using the uri pattern(methods). (i.e. If the URL contains “earthquake” which means the message should be sent to related processor to process it). In this example sensor will sends a JSON payload with the needed information to the Messaging gateway cluster in order to forward the message. This will forward the message to the related EP.

### Event- Driven Consumer

<img src="https://github.com/LahiruLS/eip-messaging-endpoints/blob/master/images/ED_EIP.jpg" width="280" height="450" />

The Event-Driven Consumer EIP allows an application to automatically consume messages as they become available. 

In this guide Event-Driven Consumer is used to demonstrates how an event will be triggered based on the availability of the related messages which will be consumed afterwords.


When the messages from sensors are sent to the queue then by that event the event driven consumers starting to consumes messages. Then they are going to be sent to relevant processors in the backend cluster in order to process.

### Polling Consumer

The Polling Consumer EIP allows the ESB to explicitly make a call when the application wants to receive a message.

<img src="https://github.com/LahiruLS/eip-messaging-endpoints/blob/master/images/PC_EIP.jpg" width="320" height="420" />

In this guide you use pooling consumer EIP in two places. At first when the messages are forwarded from the messaging gateway they are sent for queues in each EP. Before Event Driven consumer consumes the message it was queued and the consumes in order to guarantee the delivery since these sensor information are very valuable for future calculations.

The other place we use this pattern in this example is after the processing happens before the results,  and alarm set off messages if needed,  and information messages, alert messages, and messages for R&D department to further analyze the new information. Since all these are valuable use cases we use the polling consumer EIP here as guaranteed delivery mechanism.

### Selective consumer

<img src="https://github.com/LahiruLS/eip-messaging-endpoints/blob/master/images/SEC_EIP.jpg" width="320" height="420" />



The Selective Consumer EIP allows a message consumer to select which messages it will receive. It filters the messages delivered by its channel so that it only receives the ones that match its criteria. In this example the message consumer selects the message from a queue based on the priority (Elements in the message request).

### Message Dispatcher 

<img src="https://github.com/LahiruLS/eip-messaging-endpoints/blob/master/images/MD_EIP.jpg" width="320" height="420" />


The Message Dispatcher EIP consumes messages from a single channel and distributes them among performers. It allows multiple consumers on a single channel to coordinate their message processing. When in case of an alarm is needed to set off in several geo locations we need to distributes the same alarm set off command to the related terminal at the same time or in different times. In this guide you are going to use this  EI pattern to achieve this specific use case.

## Prerequisites

- [Ballerina Distribution](https://ballerina.io/learn/getting-started/)
- A Text Editor or an IDE 

## Optional requirements

- Ballerina IDE plugins ([IntelliJ IDEA](https://plugins.jetbrains.com/plugin/9520-ballerina), [VSCode](https://marketplace.visualstudio.com/items?itemName=WSO2.Ballerina), [Atom](https://atom.io/packages/language-ballerina))
- [Docker](https://docs.docker.com/engine/installation/)
- [Kubernetes](https://kubernetes.io/docs/setup/)

## Implementation

> If you want to skip the basics and move directly to the [Testing](#testing) section, you can download the project from git and skip the instructions on [Implementation](#implementation) the service.

### Create the project structure

Ballerina is a complete programming language that allows you to have any custom project structure that you want. 
 
Use the following package structure for this project:
```
eip-messaging-endpoints/
├── guide
│   ├── event-driven-and-pooling-consumer-service
│   │   ├── event-driven-and-pooling-consumer.bal
│   │   └── tests
│   │       └── event-driven-and-pooling-consumer_test.bal
│   ├── message-processor
│   │   ├── message_processor.bal
│   │   └── tests
│   ├── messaging-dispatcher-service
│   │   ├── messaging-dispatcher.bal
│   │   └── tests
│   │       └── messaging-dispatcher_test.bal
│   ├── messaging-gateway-service
│   │   ├── messaging_gateway.bal
│   │   └── tests
│   │       └── messaging_gateway_test.bal
│   └── pooling-and-selective-consumer-service
│       ├── pooling-and-selective-consumer.bal
│       └── tests
│           └── polling-and-selective-consumer_test.bal
├── images
│   ├── Component_Architecture_Diagram.jpg
│   ├── ED_EIP.jpg
│   ├── MD_EIP.jpg
│   ├── MG_EIP.jpg
│   ├── PC_EIP.jpg
│   └── SEC_EIP.jpg
└── README.md
```
Create the above directories in your local machine and also create empty .bal files.

- Create the above directories in your local machine and also create empty `.bal` files.

- Then open the terminal and navigate to `eip-messaging-endpoints/guide` and run Ballerina project initializing toolkit.
```bash
   $ ballerina init
```
Now that you have created the project structure, the next step is to test the disaster notification system. To check the implementation of the each service please refer the `.bal` files in the each service directories.

> Please note that the messaging processor service is not a implementation of messaging endpoint pattern but a helper service for the other services inorder to compleate the whole flow.

## Testing

- First, you need to run Ballerina Message Broker.You can start Ballerina Message Broker by entering the following command in your termainal.
```
$ broker 
```
NOTE: Ballerina Message Broker is included in the Ballerina distribution. You can find the executable file of the message broker at `<BALLERINA_DISTRIBUTION>/bin/broker`. Also the Ballerina Message Broker is avaiblable [here](https://github.com/ballerina-platform/ballerina-message-broker).

> Ballerina Message Broker  
> [Ballerina Message Broker](https://github.com/ballerina-platform/ballerina-message-broker) is a light-weight, easy-to-use, > 100% open source message broker that uses AMQP as the messaging protocol.

### Invoking the disaster notification system with Ballerina

- Next, open a terminal, navigate to `eip-messaging-endpoints/guide`, and execute the following command to run the messaging gateway service (which listen to the messages from sensors and forward them):
```
$ballerina run messaging-gateway-service
```

- Then, open a terminal, navigate to `eip-messaging-endpoints/guide`, and execute the following command to run event-driven and pooling consumer service(which serves messages by their arrival at the related queue. Also here all the messages are served by pooling them):
```
$ballerina run event-driven-and-pooling-consumer-service
```

- Again, open a terminal, navigate to `eip-messaging-endpoints/guide`, and execute the following command to run message processor service(which process the messages and then sends them to a queue):
```
$ballerina run message-processor-service
```

- Once again, open a terminal, navigate to `eip-messaging-endpoints/guide`, and execute the following command to run pooling-and-selective-consumer-service(which acts as a selective consumer based on the message priority):
```
$ballerina run pooling-and-selective-consumer-service
```
- Finally, open a terminal, navigate to `eip-messaging-endpoints/guide`, and execute the following command to run messaging-dispatcher-service(which can dispatch the same message to several endpoints at once):
```
$ballerina run messaging-dispatcher-service
```
- Now you can execute the following curl commands to check on the flow of the disaster notification system.

**Invoking via curl** 
```
curl -v -X POST -d '{ "ID": 27125088, "SID": 4344, "TIME_S": "1536423224", "TIME_E": "1536423584", "TYPE": "EQ",
        "C_DATA": "41.40338, 2.17403", "R_SCALE": 10 }' "http://localhost:9090/service/activity"\
-H "Content-Type:application/json"

Output : 
{status: Sucessfull}
```
- You will see the following logs printed on your console when you invoke the curl command.

```
ballerina: initiating service(s) in 'messaging-gateway-service'
ballerina: started HTTP/WS endpoint 0.0.0.0:9090
2018-09-24 22:29:13,354 INFO  [messaging-gateway-service:0.0.0] - Message recived at /activity: {"ID":27125088, "SID":4344, "TIME_S":"1536423224", "TIME_E":"1536423584", "TYPE":"EQ", "C_DATA":"41.40338, 2.17403", "R_SCALE":10}status:forwarded 

ballerina: initiating service(s) in 'event-driven-and-pooling-consumer-service'
2018-09-24 22:28:34,503 INFO  [ballerina/jms] - Message receiver created for queue GeoActivities 
2018-09-24 22:28:34,540 INFO  [ballerina/jms] - Message receiver created for queue SensorHealth 
2018-09-24 22:28:34,549 INFO  [ballerina/jms] - Message receiver created for queue Maintenance 
2018-09-24 22:28:34,561 INFO  [ballerina/jms] - Message receiver created for queue Calibration 
2018-09-24 22:29:13,881 INFO  [event-driven-and-pooling-consumer-service:0.0.0] - Message recived from queue GeoActivities: {"ID":27125088, "SID":4344, "TIME_S":"1536423224", "TIME_E":"1536423584", "TYPE":"EQ", "C_DATA":"41.40338, 2.17403", "R_SCALE":10}status:forwarded to /activity 

ballerina: initiating service(s) in 'message-processor'
ballerina: started HTTP/WS endpoint 0.0.0.0:8080
2018-09-24 22:29:13,656 INFO  [message-processor:0.0.0] - Message resived at /activity: {"ID":27125088, "SID":4344, "TIME_S":"1536423224", "TIME_E":"1536423584", "TYPE":"EQ", "C_DATA":"41.40338, 2.17403", "R_SCALE":10} 
2018-09-24 22:29:13,798 INFO  [message-processor:0.0.0] - Notifying Authority and then set off alarms{"AlarmStatus":"ON"} 


ballerina: initiating service(s) in 'pooling-and-selective-consumer-service'
2018-09-24 22:28:52,296 INFO  [ballerina/jms] - Message receiver created for queue ProcessedQueue 
2018-09-24 22:29:13,852 INFO  [pooling-and-selective-consumer-service:0.0.0] - Message recived with the priority of: 4 
2018-09-24 22:29:13,859 INFO  [pooling-and-selective-consumer-service:0.0.0] - Message recived with the priority of: 4 


ballerina: initiating service(s) in 'messaging-dispatcher-service'
2018-09-24 22:29:10,337 INFO  [ballerina/jms] - Subscriber created for topic Alarm 
{"AlarmStatus":"ON"}
{"Message":"Earth Quake of 10 Richter Scale at the loaction near Panama", "AlarmStatus":"ON", "DesasterRecoveryTeamStatus":"Dispatched"}
2018-09-24 22:29:14,263 INFO  [messaging-dispatcher-service:0.0.0] - Message had forwarded to /alarm1, /alarm2, /alarm3 endpoints: {"Message":"Earth Quake of 10 Richter Scale at the loaction near Panama", "AlarmStatus":"ON", "DesasterRecoveryTeamStatus":"Dispatched"}status:forwarded 
2018-09-24 22:29:14,267 INFO  [messaging-dispatcher-service:0.0.0] - Message had forwarded to /alarm1, /alarm2, /alarm3 endpoints: {"AlarmStatus":"ON"}status:forwarded 


```

### Writing unit tests 

In Ballerina, the unit test cases should be in the same package inside a folder named as 'tests'.  When writing the test functions the below convention should be followed.
- Test functions should be annotated with `@test:Config`. See the below example.
```ballerina
   @test:Config
   function testGeoActivities() {
```

To run the unit tests, open your terminal and navigate to `messaging-with-ballerina/guide`, and run the following command.
```bash
$ ballerina test messaging-gateway-service 
```
NOTE: You need to run Ballerina Message Broker before running the above test case

To check the implementation of the test file, refer to the `tests` directories in the [repository](https://github.com/LahiruLS/eip-messaging-endpoints).

## Deployment

After you develop the service, you can deploy it. 

### Deploy locally

- As the first step, you can build a Ballerina executable archive (.balx) of the services that we developed above. Navigate to `messaging-with-ballerina/guide` and run the following commands. 

```
$ballerina build messaging-gateway-service
```

```
$ballerina build event-driven-and-pooling-consumer-service
```
```
$ballerina build message-processor-service
```
```
$ballerina build pooling-and-selective-consumer-service
```
```
$ballerina build messaging-dispatcher-service
```
- Once the each `.balx` files created inside the target folder, you can use the following commands to run the .balx files: 

```
$ballerina run target/messaging-gateway-service.balx
```

```
$ballerina run target/event-driven-and-pooling-consumer-service.balx
```
```
$ballerina run target/event-driven-and-pooling-consumer-service.balx
```
```
$ballerina run target/message-processor-service.balx
```
```
$ballerina run target/pooling-and-selective-consumer-service.balx
```
```
$ballerina run target/messaging-dispatcher-service.balx
```

- Successful execution of the service displays the following output. 
```
$ ballerina run target/messaging-gateway-service.balx
  ballerina: initiating service(s) in 'target/messaging-gateway-service.balx'
  ballerina: started HTTP/WS endpoint 0.0.0.0:9090
  
$ ballerina run target/event-driven-and-pooling-consumer-service.balx
  ballerina: initiating service(s) in './target/event-driven-and-pooling-consumer-service.balx'
  2018-09-24 21:51:37,907 INFO  [ballerina/jms] - Message receiver created for queue GeoActivities 
  2018-09-24 21:51:37,944 INFO  [ballerina/jms] - Message receiver created for queue SensorHealth 
  2018-09-24 21:51:37,963 INFO  [ballerina/jms] - Message receiver created for queue Maintenance 
  2018-09-24 21:51:37,975 INFO  [ballerina/jms] - Message receiver created for queue Calibration 

$ ballerina run target/message-processor.balx
  ballerina: initiating service(s) in './target/message-processor.balx'
  ballerina: started HTTP/WS endpoint 0.0.0.0:8080

$ ballerina run target/pooling-and-selective-consumer.balx
  ballerina: initiating service(s) in './target/pooling-and-selective-consumer.balx'
  2018-09-24 21:57:28,685 INFO  [ballerina/jms] - Message receiver created for queue ProcessedQueue 
  
$ ballerina run target/messaging-dispatcher-service.balx
  ballerina: initiating service(s) in './target/messaging-dispatcher-service.balx'
  2018-09-24 21:59:53,915 INFO  [ballerina/jms] - Subscriber created for topic Alarm 
```

### Deploying on Docker

You can run the service that we developed above as a Docker container. As Ballerina platform includes [Ballerina_Docker_Extension](https://github.com/ballerinax/docker), which offers native support for running ballerina programs on containers, you just need to put the corresponding docker annotations on your service code.

- Make sure that Ballerina Message Broker Docker container is up and running to services to connect with the broker. You can pull the message broker Docker image from [here](https://hub.docker.com/r/ballerina/message-broker/) and follow instructions provided to start the Ballerina Message Broker.

- Once you successfully start Ballerina Message Broker, execute `docker ps` command in the terminal and take corresponding Docker process id for message broker. Then execute execute `docker inspect <PROCESS_ID>` and take IP address of the message broker container.

```
   $ docker ps
```

```
   $ docker inspect <PROCESS_ID>
```

- Then update the URLs of the message broker in each services services except `messaging-dispatcher-service` with the message broker container IP address.
- Also in event-driven-and-pooling-consumer-service you need to update the `message-processor-service` deployed contaner IP address as well. 
- In each service, we need to import  `ballerinax/docker` and use the annotation `@docker:Config` as shown below to enable Docker image generation during the build time.

##### messaging_gateway.bal
```ballerina
import ballerinax/docker;
import ballerina/http;
import ballerina/io;
import ballerina/log;
import ballerina/mb;

documentation { Define the message queue endpoint for sending geo activities captured from the sensor. }
endpoint mb:SimpleQueueSender queuesensorGeoMessage {
    host: "<IP_ADDRESS_OF_BALLERINA_MESSAGE_BROKER_CONTAINER>",
    port: 5672,
    queueName: "GeoActivities"
};

documentation { Define the message queue endpoint to health check messages. }
endpoint mb:SimpleQueueSender queueHealthCheck {
    host: "<IP_ADDRESS_OF_BALLERINA_MESSAGE_BROKER_CONTAINER>",
    port: 5672,
    queueName: "SensorHealth"
};
documentation { Define the message queue endpoint for maintenance messages. }
endpoint mb:SimpleQueueSender queueMaintenance {
    host: "<IP_ADDRESS_OF_BALLERINA_MESSAGE_BROKER_CONTAINER>",
    port: 5672,
    queueName: "Maintenance"
};
documentation { Define the message queue endpoint for sensor calibration requests. }
endpoint mb:SimpleQueueSender queueCalibration {
    host: "<IP_ADDRESS_OF_BALLERINA_MESSAGE_BROKER_CONTAINER>",
    port: 5672,
    queueName: "Calibration"
};

documentation { Listener endpoint configurations. }
@docker:Config {
    registry:"ballerina.guides.io",
    name:"messaging_gateway",
    tag:"v1.0"
}
```

##### event-driven-and-pooling-consumer.bal
```ballerina
import ballerinax/docker;
import ballerina/log;
import ballerina/mb;

@docker:Config {
    registry:"ballerina.guides.io",
    name:"event_driven_and_pooling_consumer",
    tag:"v1.0"
}
documentation { Queue receiver endpoint for new geo related messages. }
endpoint mb:SimpleQueueReceiver queueReceiverGeoActivities {
    host: "<IP_ADDRESS_OF_BALLERINA_MESSAGE_BROKER_CONTAINER>",
    port: 5672,
    queueName: "GeoActivities"
};
endpoint http:Client  GeoActivityEP {
    url: "http://<IP_ADDRESS_OF_MESSAGE_PROCESSOR_SERVICE_CONTAINER>:8080/activity"
};
documentation { Queue receiver endpoint for health check messages of the sensors. }
endpoint mb:SimpleQueueReceiver queueReceiverHealth {
    host: "<IP_ADDRESS_OF_BALLERINA_MESSAGE_BROKER_CONTAINER>",
    port: 5672,
    queueName: "SensorHealth"
};
endpoint http:Client  HealthEP {
    url: "http://<IP_ADDRESS_OF_MESSAGE_PROCESSOR_SERVICE_CONTAINER>:8080/health"
};
documentation { Queue receiver endpoint for maintenance messages of sensors. }
endpoint mb:SimpleQueueReceiver queueReceiverMaintenance {
    host: "<IP_ADDRESS_OF_BALLERINA_MESSAGE_BROKER_CONTAINER>",
    port: 5672,
    queueName: "Maintenance"
};
endpoint http:Client  MaintenanceEP {
    url: "http://<IP_ADDRESS_OF_MESSAGE_PROCESSOR_SERVICE_CONTAINER>:8080/maintenance"
};
documentation { Queue receiver endpoint for calibration messages. }
endpoint mb:SimpleQueueReceiver queueReceiverCalibrate {
    host: "<IP_ADDRESS_OF_BALLERINA_MESSAGE_BROKER_CONTAINER>",
    port: 5672,
    queueName: "Calibration"
};
endpoint http:Client  CalibrateEP {
    url: "http://<IP_ADDRESS_OF_MESSAGE_PROCESSOR_SERVICE_CONTAINER>:8080/calibrate"
};
```
##### pooling-and-selective-consumer.bal
```

import ballerina/mb;
import ballerina/log;
import ballerina/http;

@docker:Config {
    registry:"ballerina.guides.io",
    name:"pooling_and_selective_consumer",
    tag:"v1.0"
}
documentation { Queue receiver endpoint for new information messages. }
endpoint mb:SimpleQueueReceiver queueReceiver {
    host: "<IP_ADDRESS_OF_BALLERINA_MESSAGE_BROKER_CONTAINER>",
    port: 5672,
    queueName: "ProcessedQueue"
};
documentation { Topic to publish  Priority 1 messages. }
endpoint mb:SimpleTopicPublisher NotifyAuthority {
    host: "<IP_ADDRESS_OF_BALLERINA_MESSAGE_BROKER_CONTAINER>",
    port: 5672,
    topicPattern: "Authority"
};
documentation { Topic to publish  Priority 2 messages. }
endpoint mb:SimpleTopicPublisher AlarmSetoff {
    host: "<IP_ADDRESS_OF_BALLERINA_MESSAGE_BROKER_CONTAINER>",
    port: 5672,
    topicPattern: "Alarm"
};
documentation { Topic to publish  Priority 3 messages. }
endpoint mb:SimpleTopicPublisher StatusAndMaintenance {
    host: "<IP_ADDRESS_OF_BALLERINA_MESSAGE_BROKER_CONTAINER>",
    port: 5672,
    topicPattern: "StatusAndMaintenance"
};
documentation { Topic to publish  Priority 4 messages. }
endpoint mb:SimpleTopicPublisher Research {
    host: "<IP_ADDRESS_OF_BALLERINA_MESSAGE_BROKER_CONTAINER>",
    port: 5672,
    topicPattern: "Research"
};
documentation {
 Service to receive messages and do the selection process based on the priority and then publish the message to the related topic.
}

```
- `@docker:Config` annotation is used to provide the basic Docker image configurations for the sample. `@docker:Expose {}` is used to expose the port.

- Now you can build a Ballerina executable archive (.balx) of the service that we developed above, using the following command. It points to the service file that we developed above and it will create an executable binary out of that. 
This will also create the corresponding Docker image using the Docker annotations that you have configured above. Navigate to `eip-messaging-endpoints/guide` and run the following command.

```
   $ ballerina build --skiptests messaging-gateway-service

   Run following command to start Docker container:
   docker run -d -p 9090:9090 ballerina.guides.io/messaging_gateway:v1.0

   $ ballerina build event-driven-and-pooling-consumer-service

   Run following command to start Docker container:
   docker run -d ballerina.guides.io/event_driven_and_pooling_consumer:v1.0
   
   $ ballerina build messaging-processor-service

   Run following command to start Docker container:
   docker run -d ballerina.guides.io/message_processor:v1.0
   
   $ ballerina build pooling-and-selective-consumer-service

   Run following command to start Docker container:
   docker run -d ballerina.guides.io/pooling_and_selective_consumer:v1.0
   
   $ ballerina build messaging-dispatcher-service

   Run following command to start Docker container:
   docker run -d ballerina.guides.io/messaging_dispatcher:v1.0
```

- Once you successfully build the Docker images, you can run it with the `docker run` command that is shown in the previous step.
```   
   $ docker run -d ballerina.guides.io/event_driven_and_pooling_consumer:v1.0

   $ docker run -d -p 9090:9090 ballerina.guides.io/messaging_gateway:v1.0
```

  Here we run the Docker image with flag `-p <host_port>:<container_port>` so that we  use  the host port 9090 and the container port 9090. Therefore you can access the service through the host port.

- Verify Docker containers are running with the use of `$ docker ps`. The status of the Docker containers should be shown as 'Up'.
- You can access the service using the same curl commands that we've used above. 
```
curl -v -X POST -d '{ "ID": 27125088, "SID": 4344, "TIME_S": "1536423224", "TIME_E": "1536423584", "TYPE": "EQ",
        "C_DATA": "41.40338, 2.17403", "R_SCALE": 10 }' "http://localhost:9090/service/activity"\
-H "Content-Type:application/json"
```

### Deploying on Kubernetes

- You can run the service that we developed above, on Kubernetes. The Ballerina language offers native support for running a ballerina programs on Kubernetes, with the use of Kubernetes annotations that you can include as part of your service code. Also, it will take care of the creation of the Docker images. So you don't need to explicitly create Docker images prior to deploying it on Kubernetes. Refer to [Ballerina_Kubernetes_Extension](https://github.com/ballerinax/kubernetes) for more details and samples on Kubernetes deployment with Ballerina. You can also find details on using Minikube to deploy Ballerina programs.

- Make sure that Ballerina Message Broker Docker container is up and running to services to connect with the broker. You can pull the message broker Docker image from [here](https://hub.docker.com/r/ballerina/message-broker/) and follow the instructions provided to start the Ballerina Message Broker.

- Once you successfully start Ballerina Message Broker, execute `docker ps` command in the terminal and take corresponding Docker process id for message broker. Then execute execute `docker inspect <PROCESS_ID>` and take IP address of the message broker container.

```
   $ docker ps
```

```
   $ docker inspect <PROCESS_ID>
```

- Then update the URLs of the message broker in each service with the message broker container IP address

- Let's now see how we can deploy our `messaging-gateway-service` on Kubernetes.

-  We need to import `ballerinax/kubernetes` and use `@kubernetes` annotations as shown below to enable Kubernetes deployment for the service we developed above.

> NOTE: Linux users can use Minikube to try this out locally.

##### messaging_gateway.bal

```ballerina
import ballerina/http;
import ballerina/io;
import ballerina/log;
import ballerina/mb;
import ballerinax/kubernetes;

documentation { Define the message queue endpoint for sending geo activities captured from the sensor. }
endpoint mb:SimpleQueueSender queuesensorGeoMessage {
    host: "<IP_ADDRESS_OF_BALLERINA_MESSAGE_BROKER_CONTAINER>",
    port: 5672,
    queueName: "GeoActivities"
};
documentation { Define the message queue endpoint to health check messages. }
endpoint mb:SimpleQueueSender queueHealthCheck {
    host: "<IP_ADDRESS_OF_BALLERINA_MESSAGE_BROKER_CONTAINER>",
    port: 5672,
    queueName: "SensorHealth"
};
documentation { Define the message queue endpoint for maintenance messages. }
endpoint mb:SimpleQueueSender queueMaintenance {
    host: "<IP_ADDRESS_OF_BALLERINA_MESSAGE_BROKER_CONTAINER>",
    port: 5672,
    queueName: "Maintenance"
};
documentation { Define the message queue endpoint for sensor calibration requests. }
endpoint mb:SimpleQueueSender queueCalibration {
    host: "<IP_ADDRESS_OF_BALLERINA_MESSAGE_BROKER_CONTAINER>",
    port: 5672,
    queueName: "Calibration"
};
documentation { Attributes associated with the service endpoint. }
endpoint http:Listener sensorEventListner {
    port: 9090
};
@kubernetes:Ingress {
    hostname:"ballerina.guides.io",
    name:"ballerina-guides-messaging-gateway-service",
    path:"/"
}

@kubernetes:Service {
    serviceType:"NodePort",
    name:"ballerina-guides-messaging-gateway-service"
}

@kubernetes:Deployment {
    image:"ballerina.guides.io/messaging-gateway-service:v1.0",
    name:"ballerina-guides-messaging-gateway-service"
}
documentation {  via HTTP/1.1. }
@http:ServiceConfig {
    basePath: "/service"
}
``` 

- Here we have used `@kubernetes:Deployment` to specify the Docker image name which will be created as part of building this service.
- We have also specified `@kubernetes:Service` so that it will create a Kubernetes service which will expose the Ballerina service that is running on a Pod.  
- In addition we have used `@kubernetes:Ingress` which is the external interface to access your service (with path `/` and host name `ballerina.guides.io`)

If you are using Minikube, you need to set a couple of additional attributes to the `@kubernetes:Deployment` annotation.
- `dockerCertPath` - The path to the certificates directory of Minikube (e.g., `/home/ballerina/.minikube/certs`).
- `dockerHost` - The host for the running cluster (e.g., `tcp://192.168.99.100:2376`). The IP address of the cluster can be found by running the `minikube ip` command.

- Now you can build a Ballerina executable archive (.balx) of the service that we developed above, using the following command. It points to the service file that we developed above and it will create an executable binary out of that. 
This will also create the corresponding Docker image and the Kubernetes artifacts using the Kubernetes annotations that you have configured above.
  
```
   $ ballerina build messaging-gateway-service
  
   Run following command to deploy Kubernetes artifacts:
   kubectl apply -f target/kubernetes/messaging-gateway-service
```

- You can verify that the Docker image that we specified in `@kubernetes:Deployment` is created, by using `$ docker images`.
- Also the Kubernetes artifacts related our service, will be generated in `./target/messaging-gateway-service/kubernetes`. 
- Now you can create the Kubernetes deployment using:

```
   $ kubectl apply -f target/kubernetes/messaging-gateway-service
 
   deployment.extensions "ballerina-guides-messaging-gateway-service" created
   ingress.extensions "ballerina-guides-messaging-gateway-service" created
   service "ballerina-guides-messaging-gateway-service" created
```

- You can verify Kubernetes deployment, service and ingress are running properly, by using following Kubernetes commands.

```
   $ kubectl get service
   $ kubectl get deploy
   $ kubectl get pods
   $ kubectl get ingress
```

- If everything is successfully deployed, you can invoke the service either via Node port or ingress. 

Node Port:
 
```
curl -v -X POST -d '{ "ID": 27125088, "SID": 4344, "TIME_S": "1536423224", "TIME_E": "1536423584", "TYPE": "EQ",
        "C_DATA": "41.40338, 2.17403", "R_SCALE": 10 }' "http://localhost:<Node_Port>/service/activity"\
-H "Content-Type:application/json"
```
If you are using Minikube, you should use the IP address of the Minikube cluster obtained by running the `minikube ip` command. The port should be the node port given when running the `kubectl get services` command.

Ingress:

- Make sure that Nginx backend and controller deployed as mentioned in [here](https://github.com/ballerinax/kubernetes/tree/master/samples#setting-up-nginx).

Add `/etc/hosts` entry to match hostname. For Minikube, the IP address should be the IP address of the cluster.
``` 
127.0.0.1 ballerina.guides.io
```

Access the service 
``` 
curl -v -X POST -d '{ "ID": 27125088, "SID": 4344, "TIME_S": "1536423224", "TIME_E": "1536423584", "TYPE": "EQ",
        "C_DATA": "41.40338, 2.17403", "R_SCALE": 10 }' "http://ballerina.guides.io/service/activity"\
-H "Content-Type:application/json"
```

## Observability 
Ballerina is by default observable. Meaning yo, resources, etc.u can easily observe your services
However, observability is disabled by default via configuration. Observability can be enabled by adding following configurations to `ballerina.conf` file and starting the ballerina service using it. A sample configuration file can be found in `messaging-with-ballerina/guide/messaging-gateway-service`.

```ballerina
[b7a.observability]

[b7a.observability.metrics]
# Flag to enable Metrics
enabled=true

[b7a.observability.tracing]
# Flag to enable Tracing
enabled=true
```

To start the ballerina service using the configuration file, run the following command
```
   $ ballerina run --config messaging-gateway-service/ballerina.conf messaging-gateway-service/
```
NOTE: The above configuration is the minimum configuration needed to enable tracing and metrics. With these configurations default values are load as the other configuration parameters of metrics and tracing.

### Tracing 

You can monitor ballerina services using in built tracing capabilities of Ballerina. We'll use [Jaeger](https://github.com/jaegertracing/jaeger) as the distributed tracing system.
Follow the following steps to use tracing with Ballerina.

- You can add the following configurations for tracing. Note that these configurations are optional if you already have the basic configuration in `ballerina.conf` as described above.
```
   [b7a.observability]

   [b7a.observability.tracing]
   enabled=true
   name="jaeger"

   [b7a.observability.tracing.jaeger]
   reporter.hostname="localhost"
   reporter.port=5775
   sampler.param=1.0
   sampler.type="const"
   reporter.flush.interval.ms=2000
   reporter.log.spans=true
   reporter.max.buffer.spans=1000
```

- Run Jaeger Docker image using the following command
```bash
   $ docker run -d -p5775:5775/udp -p6831:6831/udp -p6832:6832/udp -p5778:5778 -p16686:16686 \
   -p14268:14268 jaegertracing/all-in-one:latest
```

- Navigate to `eip-messaging-endpoints/guide` and run the restful-service using the following command
```
   $ ballerina run --config messaging-gateway-service/ballerina.conf messaging-gateway-service/
```

- Observe the tracing using Jaeger UI using following URL
```
   http://localhost:16686
```

### Metrics
Metrics and alerts are built-in with ballerina. We will use Prometheus as the monitoring tool.
Follow the below steps to set up Prometheus and view metrics for Ballerina restful service.

- You can add the following configurations for metrics. Note that these configurations are optional if you already have the basic configuration in `ballerina.conf` as described under `Observability` section.

```
   [b7a.observability.metrics]
   enabled=true
   reporter="prometheus"

   [b7a.observability.metrics.prometheus]
   port=9797
   host="0.0.0.0"
```

- Create a file `prometheus.yml` inside `/tmp/` location. Add the below configurations to the `prometheus.yml` file.
```
   global:
     scrape_interval:     15s
     evaluation_interval: 15s

   scrape_configs:
     - job_name: prometheus
       static_configs:
         - targets: ['172.17.0.1:9797']
```

   NOTE : Replace `172.17.0.1` if your local Docker IP differs from `172.17.0.1`
   
- Run the Prometheus Docker image using the following command
```
   $ docker run -p 19090:9090 -v /tmp/prometheus.yml:/etc/prometheus/prometheus.yml \
   prom/prometheus
```

- Navigate to `eip-messaging-endpoints/guide` and run the restful-service using the following command
```
   $ ballerina run --config messaging-gateway-service/ballerina.conf messaging-gateway-service/
```

- You can access Prometheus at the following URL
```
   http://localhost:19090/
```

NOTE:  Ballerina will by default have following metrics for HTTP server connector. You can enter following expression in Prometheus UI
-  http_requests_total
-  http_response_time


### Logging

Ballerina has a log package for logging to the console. You can import ballerina/log package and start logging. The following section will describe how to search, analyze, and visualize logs in real time using Elastic Stack.

- Start the Ballerina Service with the following command from `restful-service/guide`
```
   $ nohup ballerina run messaging-gateway-service &>> ballerina.log&
```
   NOTE: This will write the console log to the `ballerina.log` file in the `messaging-with-ballerina/guide` directory

- Start Elasticsearch using the following command

- Start Elasticsearch using the following command
```
   $ docker run -p 9200:9200 -p 9300:9300 -it -h elasticsearch --name \
   elasticsearch docker.elastic.co/elasticsearch/elasticsearch:6.2.2 
```

   NOTE: Linux users might need to run `sudo sysctl -w vm.max_map_count=262144` to increase `vm.max_map_count` 
   
- Start Kibana plugin for data visualization with Elasticsearch
```
   $ docker run -p 5601:5601 -h kibana --name kibana --link \
   elasticsearch:elasticsearch docker.elastic.co/kibana/kibana:6.2.2     
```

- Configure logstash to format the ballerina logs

i) Create a file named `logstash.conf` with the following content
```
input {  
 beats{ 
     port => 5044 
 }  
}

filter {  
 grok{  
     match => { 
	 "message" => "%{TIMESTAMP_ISO8601:date}%{SPACE}%{WORD:logLevel}%{SPACE}
	 \[%{GREEDYDATA:package}\]%{SPACE}\-%{SPACE}%{GREEDYDATA:logMessage}"
     }  
 }  
}   

output {  
 elasticsearch{  
     hosts => "elasticsearch:9200"  
     index => "store"  
     document_type => "store_logs"  
 }  
}  
```

ii) Save the above `logstash.conf` inside a directory named as `{SAMPLE_ROOT}\pipeline`
     
iii) Start the logstash container, replace the `{SAMPLE_ROOT}` with your directory name
     
```
$ docker run -h logstash --name logstash --link elasticsearch:elasticsearch \
-it --rm -v ~/{SAMPLE_ROOT}/pipeline:/usr/share/logstash/pipeline/ \
-p 5044:5044 docker.elastic.co/logstash/logstash:6.2.2
```
  
 - Configure filebeat to ship the ballerina logs
    
i) Create a file named `filebeat.yml` with the following content
```
filebeat.prospectors:
- type: log
  paths:
    - /usr/share/filebeat/ballerina.log
output.logstash:
  hosts: ["logstash:5044"]  
```
NOTE : Modify the ownership of filebeat.yml file using `$chmod go-w filebeat.yml` 

ii) Save the above `filebeat.yml` inside a directory named as `{SAMPLE_ROOT}\filebeat`   
        
iii) Start the logstash container, replace the `{SAMPLE_ROOT}` with your directory name
     
```
$ docker run -v {SAMPLE_ROOT}/filbeat/filebeat.yml:/usr/share/filebeat/filebeat.yml \
-v {SAMPLE_ROOT}/guide/messaging-gateway-service/ballerina.log:/usr/share\
/filebeat/ballerina.log --link logstash:logstash docker.elastic.co/beats/filebeat:6.2.2
```
 
 - Access Kibana to visualize the logs using following URL
```
   http://localhost:5601 
```
