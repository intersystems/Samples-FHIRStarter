# SUREFHIR Demo R4 Version 1.0

This demo will show how incoming messages of different formats (HL7, XML, or CDA) can be transformed into SDA and ulitmately sent out via a our FHIR Server Interop Operation.

## Contents

### Script files
 1. DockerFile - script for building Docker container
 2. Installer.xml - Installer manifest for setting up IRIS instance
 3. SDAShredder-Export.xml - All classes required for SDAShredder Production
 4. ISCPATIENTtoFHIR.xsd - Schema for XML file
 5. HS.SDA3.xsd - Schema for CDA file

### Sample files
 6. ISC/ISCPATIENTtoFHIR.xml - Sample XML file
 7. ISC/EpicCCDA21toFHIR.xml - Sample CDA file
 8. ISC/HL7toFHIR.HL7 - Sample HL7 file
 9. ISC/PatientsCSVtoFHIR.csv - Sample CSV file
10. ISC/In - folder for dropping test files
11. README.md - Instructions to set up the code sample

## Installation instructions: 

1. Clone this repository: `git clone`

2. Open Terminal/Command Prompt window and change directory to the  SUREFHIRDemo folder.

3. Execute the Docker Build command by either:

* Executing the `build.sh` shell script.
* Or using Docker Build Command: `docker build -t irishealth-surefhir-demo:1.0 .`

**Note:** the ending '.' is REQUIRED

4. Execute the Docker Run command by either:

* Executing  the `run.sh` shell script.
* Or using Docker Run Command: `docker run -d --hostname SUREFHIR -p 52773:52773 --init -v $PWD/ISC:/tmp/ISC --name SUREFHIR irishealth-surefhir-demo:1.0`

5. Frequently asked questions

* If you need to change the webserver port to avoid port conflict, the argument format is NEWPORT:CURRENTPORT (ex. to switch to port 51773 you would set the parameter is 51773:52733)
* The hostname flag sets the server name of the container instance to "sdashredder" which matches how the FHIR components are being installed - if you change this to something else, you will need to adjust per the Post Installation Notes, specifically #1
* The production makes use of file drops so you must map a folder to the docker container, in order to use - for this example, I have mapped a local folder path (using the "-v" flag): `/users/tmp/docker/sdashredder/ISC` to the container folder `/tmp/ISC`

## Check installation work
To verify you have installed succesfully, do the following steps:

1. Check the file path referenced in the file services within the SDAShredder production
     - Go to Interoperability -> Configure -> System Default Settings
     - The inbound file service path may need to be updated
     - Click the System Default Setting **FilePath** and confirm the Setting Value is the drive you mounted during the `Docker Run` execution
     - Make sure to click Save, once you've made your change

3. Make sure all folders and sub-folders you have mapped to the Docker container, have the correct `Read & Write privilege set - otherwise, the file adapters won't be able to delete your test files after processing.

## Test the sample FHIRStarter

First, we will  take a look at FHIRStarter sample, which contains the folloing files:

* `ISC/ISCPATIENTtoFHIR.xml` - Sample XML file
* `ISC/EpicCCDA21toFHIR.xml` - Sample CDA file
* `ISC/HL7toFHIR.HL7` - Sample HL7 file to be converted into FHIR
* `ISC/PatientsCSVtoFHIR.csv` - Sample CSV file

Drop one sample file into the mapped folder and watch that it is picked up, processed. If successful, you should receive a successful FHIR response!
Note that the PatientsCSVtoFHIR sample file has 200 patients to convert into FHIR resources.  This can take up to 60 seconds depending on the system resources that are available to the demonstration instance.

## Test the sample FHIRPlace

Now, let's look at FHIRPlace sample, which contains the folloing files:

* `ISC/HL7toFHIR.HL7` - Sample HL7 file to be converted into FHIR
* `ISC/HL7v2_ORU_R01.hl7` - Sample HL7 file
* `ISC/MRNFlatFile.txt` - Sample flat file with single MRN

To test:
1. Drop HL7toFHIR.HL7 into the input folder to add a FHIR resource to the "EMREmulatorFHIRR4" FHIR endpoint.  The Service Registry entry EMREmulatorFHIRR4 points to the /fhirstarter/r4 FHIR endpoint. If you have already dropped HL7toFHIR.HL7 into the input folder for the FHIRStarter demonstration skip step this step.
2. Drop either HL7v2_ORU_R01.hl7 or MRNFlatFile.txt into the input folder to trigger the external FHIR data collection based on a patient MRN.  
The .hl7 message includes an MRN value in the list of patient identifiers that gets extracted by the HL7v2.MRNExtractor. 
The .txt file is picked up by a simple Record Map definition in the demonstration.
Both of these MRN input values are handed off to the PatientRecordCollector BPL.

Then, do the following steps

1. Deletes any existing resources in the local /fhirplace/r4 endpoint for the MRN from the input file.  This assures there is no accidental duplication of data inside the FHIR repository.
2. Calls out to an external FHIR endpoint, labeled EMREmulatorFHIRR4.  In this demonstration, that Service Registry points to the FHIRStarter endpoint of /fhirstarter/r4.  There are two calls to this endpoint.
* First is to ask the endpoint, "Do you have a patient that matches the input MRN".  
* If a patient is found, the second call is a GET $everything against the FHIR Patient resource.
This returns a 'searchset' bundle that needs to be "flipped" in order to be saved into the IRIS for Health FHIR Repository.
3. Send the 'searchset' bundle to the BundleFlip BPL.  This component does two major changes to the bundle.
* Change the type of bundle from 'searchset' to 'transaction' and updates the necessary subfields to reflect this change.
* Change all of the URL references to resources from /<RESOURCE>/<ID> to UUID values.  Note that the /<RESOURCE>/<ID> values in the bundle will reflect the external endpoint resource IDs and need to be replaced (I4H 2020.4 and earlier).  Changing these references to UUIDs ensures that the IRIS for Health FHIR code maintains the bundle integrity when it is submitted to the local FHIR endpoint.
4. Submit the bundle to the local FHIR endpoint, /fhirplace/r4
 

## Stop the sample

After you are done with this sample, you can enter the following commands to stop containers that may still be running and remove them:

```
docker-compose stop
docker-compose rm
```

This is helpful, particularly if you have other demos running on the same machine.


