Include %occInclude

Class Demo.Installer Extends Demo.InstallerBase
{

XData Install [ XMLNamespace = INSTALLER ]
{
<Manifest>

  <Var Name="iscusrPwd" Value="iscdemo" />
  <User Username="iscusr" PasswordVar="iscusrPwd" Roles="%All" Enabled="1" />
  
  <!-- Create the HS_Services user here to prevent "Change Password" flag from being turned on -->
  <Var Name="HS_ServicesPwd" Value="HS_Services" />
  <User Username="HS_Services" PasswordVar="HS_ServicesPwd" Roles="%All" Enabled="1" />
  
  <Namespace Name="FHIRDEMO" Create="yes" Code="FHIRDEMO" Data="FHIRDEMO">
    <Log Text="Creating FHIRDEMO Database" Level="0"/>
    <Configuration>
	<Database Name="FHIRDEMO" Create="yes" Dir="${MGRDIR}/FHIRDEMO" MountAtStartup="1" MountRequired="1" Resource="%DB_FHIRDEMO"/>
    </Configuration>
  </Namespace>
    
  <Namespace Name="HSLIB" Create="no">
	<Log Text="Installing Foundation" Level="0"/>
	<Invoke Class="HS.HC.Util.Installer" Method = "InstallFoundation" CheckStatus="true">
		<Arg Value="FHIRDEMO"/>
	</Invoke>
  </Namespace>
  
  <Namespace Name="FHIRDEMO" Create="no" Code="FHIRDEMO" Data="FHIRDEMO">
     <Log Text="Import XML Schemas" Level="0"/>
     <Invoke Class="EnsLib.EDI.XML.SchemaXSD" Method="Import" CheckStatus="true">
   		<Arg Value="${ISC_PACKAGE_INSTALLDIR}/mgr/ISCPATIENTtoFHIR.xsd"/>
   	</Invoke>
	
    <Log Text="Importing FHIRStarter Export" Level="0"/>
	<Import File='${ISC_PACKAGE_INSTALLDIR}/mgr/FHIRStarter_Export.xml' Flags="cuk" Recurse="true" />

	<!-- Install elements required for FHIR-enabled namespace -->
	<Log Text="FHIR Enabling FHIRDEMO namespace" Level="0"/>
	<Invoke Class="HS.FHIRServer.Installer" Method="InstallNamespace" CheckStatus="false">
	</Invoke>
	
	<!-- Install an instance of a FHIR Service into the current namespace for FHIRSTARTER-->
	<Log Text="Installing FHIR Service into FHIRDEMO for FHIRSTARTER" Level="0"/>
	<Invoke Class="HS.FHIRServer.Installer" Method="InstallInstance" CheckStatus="false">
   		<Arg Value="/fhirstarter/r4"/>
   		<Arg Value="HS.FHIRServer.Storage.Json.InteractionsStrategy"/>
   		<Arg Value="HL7v40"/>
		<Arg Value=""/>
		<Arg Value=""/>
		<Arg Value="0"/>
	</Invoke>
	
		<!-- Install an instance of a FHIR Service into the current namespace for FHIRPLACE-->
	<Log Text="Installing FHIR Service into FHIRDEMO for FHIRPLACE" Level="0"/>
	<Invoke Class="HS.FHIRServer.Installer" Method="InstallInstance" CheckStatus="false">
   		<Arg Value="/fhirplace/r4"/>
   		<Arg Value="HS.FHIRServer.Storage.Json.InteractionsStrategy"/>
   		<Arg Value="HL7v40"/>
		<Arg Value=""/>
		<Arg Value=""/>
		<Arg Value="0"/>
	</Invoke>
<Production Name="FHIRDEMOPKG.FoundationProduction" AutoStart="1" />
  </Namespace>
  
    <Namespace Name="%SYS" Create="no">
  		<!-- Instantiate the Service Registry entry required for FHIRPLACE-->
		<Log Text="Initializing Service Registry entry in FHIRDEMO for FHIRPLACE" Level="0"/>
		<Invoke Class="Demo.Installer" Method="AddServiceRegistryEntry" CheckStatus="true">
		</Invoke>
    </Namespace>
</Manifest>
}

}

