#!/bin/bash
ssh root@host01 'echo "Importing Red Hat Decision Manager 7 Image Streams into OpenShift." >> script.log'
# Need to temporarily patch the ImageStreams file to point to tech-preview version.
ssh root@host01 'for i in {1..200}; do oc create -f https://raw.githubusercontent.com/jboss-container-images/rhdm-7-openshift-image/7.0.1.GA/rhdm70-image-streams.yaml -n openshift && break || sleep 2; done'
ssh root@host01 'echo "Importing Red Hat Decision Manager 7 - Full template into OpenShift." >> script.log'
#Remove persistent volume claim from the template, as we do not have PVC in Katacoda
ssh root@host01 'for i in {1..200}; do wget https://raw.githubusercontent.com/jboss-container-images/rhdm-7-openshift-image/7.0.1.GA/templates/rhdm70-full.yaml && break || sleep 2; done'
ssh root@host01 'for i in {1..200}; do cat rhdm70-full.yaml | sed "/rhdmcentr-pvol/,+1 d" | sed "/claimName/d" | sed "s/haproxy.router.openshift.io\/timeout: 60s/haproxy.router.openshift.io\/timeout: 600s/g" | head -n -12 > rhdm70-full-no-persistence.yaml && break || sleep 2; done'
ssh root@host01 'for i in {1..200}; do oc create -f rhdm70-full-no-persistence.yaml -n openshift && break || sleep 2; done'
ssh root@host01 'echo "Logging into OpenShift as developer." >> script.log'
ssh root@host01 'for i in {1..200}; do oc login -u developer -p developer && break || sleep 2; done'
ssh root@host01 'echo "Creating new loan-demo project in OpenShift." >> script.log'
ssh root@host01 'for i in {1..200}; do oc new-project loan-demo --display-name="Loan Demo" --description="Red Hat Decision Manager 7 - Loan Demo" && break || sleep 2; done'
ssh root@host01 'echo "Importing secrets and service accounts."'
ssh root@host01 'for i in {1..200}; do oc create -f https://raw.githubusercontent.com/jboss-container-images/rhdm-7-openshift-image/7.0.1.GA/decisioncentral-app-secret.yaml && break || sleep 2; done'
ssh root@host01 'for i in {1..200}; do oc create -f https://raw.githubusercontent.com/jboss-container-images/rhdm-7-openshift-image/7.0.1.GA/kieserver-app-secret.yaml && break || sleep 2; done'
ssh root@host01 'echo "Creating Decision Central and Decision Server containers in OpenShift." >> script.log'
ssh root@host01 'for i in {1..200}; do oc new-app --template=rhdm70-full-persistent -p APPLICATION_NAME="loan-demo" -p IMAGE_STREAM_NAMESPACE="openshift" -p KIE_ADMIN_USER="developer" -p KIE_ADMIN_PWD="developer" -p KIE_SERVER_CONTROLLER_USER="kieserver" -p KIE_SERVER_CONTROLLER_PWD="kieserver1!" -p KIE_SERVER_USER="kieserver" -p KIE_SERVER_PWD="kieserver1!" -p MAVEN_REPO_USERNAME="developer" -p MAVEN_REPO_PASSWORD="developer" -e JAVA_OPTS_APPEND=-Derrai.bus.enable_sse_support=false -n loan-demo && break || sleep 2; done'
