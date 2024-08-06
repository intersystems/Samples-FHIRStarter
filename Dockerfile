# Dockerfile:
#
# Build from the latest IRIS container image 
# Derive container image from InterSystems container image 
# FROM intersystemsdc/irishealth-community:2023.1.0.229.0-zpm
ARG IMAGE=containers.intersystems.com/intersystems/irishealth-community:latest-cd
FROM $IMAGE AS builder

# Copy app file dependencies from the host to the container IRIS mgr dir:
USER root
COPY ./Installer.xml ./FHIRStarter_Export.xml ./ISCPATIENTtoFHIR.xsd $ISC_PACKAGE_INSTALLDIR/mgr/

# RUN a series of commands
# * Loading installer directives (create DB, etc. see Installer.xml)
#
# Use the new irisowner, IRIS instance owner
USER ${ISC_PACKAGE_MGRUSER}
RUN iris start $ISC_PACKAGE_INSTANCENAME \
    && iris session $ISC_PACKAGE_INSTANCENAME -U %SYS "##class(%SYSTEM.OBJ).Load(\"$ISC_PACKAGE_INSTALLDIR/mgr/Installer.xml\",\"cdk\")" \
    && iris session $ISC_PACKAGE_INSTANCENAME -U %SYS "##class(Demo.Installer).Install()" \
    && iris stop $ISC_PACKAGE_INSTANCENAME quietly
#--

FROM $IMAGE AS final
ADD --chown=${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} https://github.com/grongierisc/iris-docker-multi-stage-script/releases/latest/download/copy-data.py /home/irisowner/dev/copy-data.py    
RUN --mount=type=bind,source=/,target=/builder/root,from=builder \
    cp -f /builder/root/usr/irissys/iris.cpf /usr/irissys/iris.cpf && \
    python3 /home/irisowner/dev/copy-data.py -c /usr/irissys/iris.cpf -d /builder/root/ 
    