Cloud Foundry Broker for ForgeRock Identity Platform
===============================

The ForgeRock Cloud Foundry Broker allows applications running inside Cloud Foundry to access the ForgeRock identity platform.

The broker currently offers the following services:
 * Apps may obtain OAuth2 credentials for authorization from an externally hosted OpenAM instance.

Prerequisites
-------------

Installation and configuration of the ForgeRock Cloud Foundry Broker requires an installation of the Cloud Foundry CLI tools, which are available from [https://github.com/cloudfoundry/cli](https://github.com/cloudfoundry/cli).

### To Create OpenAM Credentials for the Cloud Foundry Broker

Use the following steps to create user credentials in OpenAM that allow the Cloud Foundry Broker to create and delete OAuth 2.0 clients:

1.  Log in to the OpenAM console as an administrative user, such as `amAdmin`.
2.  Navigate to the realm in which the broker will create and delete OAuth2 clients, and then click **Subjects**.
3.  On the _Group_ tab, click **New**.
4.  Create a new group for a Cloud Foundry Broker user, and then click **OK**.
5.  On the _User_ tab, click **New**.
6.  Create a new user for the Cloud Foundry Broker, and then click **OK**.
7.  Click the created user, and then select the _Group_ tab.
8.  In the _Available_ list box, select the group you created earlier, click **Add**, and then click **Save**.
9.  Click **Back to Subjects**.
10. On the _Privileges_ tab, select the group you created earlier, and then select **Read and write access to all configured Agents**.
11. Save your changes.

Deploying the Cloud Foundry Broker
----------------------------------

You can deploy the Cloud Foundry Broker to Pivotal Cloud Foundry, or non-Pivotal Cloud Foundry.

### To Deploy to Pivotal Cloud Foundry

Deploying the Cloud Foundry Broker into Pivotal Cloud Foundry allows use of a tile package rather than using the command line. This simplifies the deployment process, removing the majority of the command line operations.

Use the following steps to deploy the Cloud Foundry Broker into Pivotal Cloud Foundry:

1. Log in to Pivotal Cloud Foundry OpsMgr.
2. Click on **Import a Product** on the bottom left of the screen.
3. Browse to the ForgeRock Broker Pivotal package, and upload it to Pivotal Cloud Foundry.  
   The _Pivotal Cloud Foundry ForgeRock Broker_ tile is displayed on the _Installation Dashboard_.
4. Click on the _Pivotal Cloud Foundry ForgeRock Broker_ tile.
5. In the _OpenAM_ section, complete the following properties:  
  * `Location` - the URL of the OpenAM instance (http://host:port/path/openam)
  * `Username` - the username of the account to use to create the OAuth2 clients
  * `Password` - the password of the account to use to create the OAuth2 clients
  * `Realm` - the realm in which to create the OAuth2 clients (specify `/` to use the top-level realm)
6. Click **Save** and return to the _Installation Dashboard_.
7. Click **Apply Changes** to install the _Pivotal Cloud Foundry ForgeRock Broker_.
8. On the command line, create the service:  
	`cf create-service openam-oauth2 shared {servicename}`
9. Bind applications as necessary:  
	`cf bind-service {application} {servicename}`
	
### To Deploy to Non-Pivotal Cloud Foundry

Deploying the Cloud Foundry Broker to non-Pivotal Cloud Foundry installations requires use of the command line as follows:

1. Unzip the Cloud Foundry Broker WAR file:  
    `unzip cloudfoundry-service-broker-openam-{version}.war -d ~/cf-broker`
2. Navigate to the folder containing the extracted WAR file:
    `cd ~/cf-broker`
3. Push the application to Cloud Foundry:  
    `cf push forgerockbroker-{version}`
4. Set the required environment variables for the broker:
   * `cf set-env forgerockbroker-{version} {variable} {value}`
   
   | Name                     | Description                                                                                                         |
   |--------------------------|---------------------------------------------------------------------------------------------------------------------|
   | `OPENAM_BASE_URI`        | The URI to the OpenAM instance. e.g. `https://sso.my.org/openam/`                                                   |
   | `OPENAM_USERNAME`        | Username the broker will use to authenticate with OpenAM                                                            |
   | `OPENAM_PASSWORD`        | Password the broker will use to authenticate with OpenAM                                                            |
   | `SECURITY_USER_NAME`     | Username that will be used by Cloud Foundry when accessing the broker. You should securely generate a random value. |
   | `SECURITY_USER_PASSWORD` | Password that will be used by Cloud Foundry when accessing the broker. You should securely generate a random value. |
   | `OPENAM_REALM`           | Realm to use to authenticate and create the OAuth2 clients. (Optional)                                              |
   
5. Restage the application so that changes to the environment variables are applied:  
    `cf restage forgerockbroker-{version}`
6. Find the URL for the application:  
    `cf app forgerockbroker-{version}`
7. Create the service broker:  
    `cf create-service-broker forgerockbroker {cf-username} {cf-password} {url}`
   where `{cf-username}` and `{cf-password}` are the same as `SECURITY_USER_NAME` and `SECURITY_USER_PASSWORD`, respectively.
8. After the service broker has been created, grant access to its service plans:  
    `cf enable-service-access openam-oauth2`
9. Create the service:  
    `cf create-service openam-oauth2 shared {servicename}`
10. Bind applications as necessary:  
    `cf bind-service {application-to-bind} {servicename}`

Removing the Cloud Foundry Broker
---------------------------------

### To Remove from Pivotal Cloud Foundry

Uninstalling the _Pivotal Cloud Foundry ForgeRock Broker_ tile in the OpsMgr does not unbind applications from the broker or remove the OAuth2 clients from OpenAM. 

Unbinding must be performed before uninstallation, as follows:

1. Unbind the application from the service broker:  
	`cf unbind-service {application} {servicename}`
2. Log in to Pivotal Cloud Foundry OpsMgr.
3. On the bottom right of the _Pivotal Cloud Foundry ForgeRock Broker_ tile, click on the trashcan icon.
4. Acknowledge the uninstallation message, and then click **Apply Changes** to remove the _Pivotal Cloud Foundry ForgeRock Broker_.

### To Remove from Non-Pivotal Cloud Foundry

To remove the Cloud Foundry Broker from Cloud Foundry, the bindings, service, broker, and application must all be removed in order:

1. Unbind the application(s) from the service broker:  
    `cf unbind-service {bound-application} {servicename}`
2. Delete the service:  
    `cf delete-service {servicename}`
3. Delete the broker:  
    `cf delete-service-broker forgerockbroker`
4. Delete the application:  
    `cf delete forgerockbroker-{version}`

* * * 

The contents of this file are subject to the terms of the Common Development and
Distribution License (the License). You may not use this file except in compliance with the
License.

You can obtain a copy of the License at legal/CDDLv1.0.txt. See the License for the
specific language governing permission and limitations under the License.

When distributing Covered Software, include this CDDL Header Notice in each file and include
the License file at legal/CDDLv1.0.txt. If applicable, add the following below the CDDL
Header, with the fields enclosed by brackets [] replaced by your own identifying
information: "Portions copyright [year] [name of copyright owner]".

Copyright 2016 ForgeRock AS.
