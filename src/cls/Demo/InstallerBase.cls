Class Demo.InstallerBase [ Abstract ]
{

/// This method must always be here
ClassMethod Setup(ByRef pVars, pLogLevel As %Integer = 0, pInstaller As %Installer.Installer) As %Status [ CodeMode = objectgenerator, Internal ]
{
	     Quit ##class(%Installer.Manifest).%Generate(%compiledclass, %code, "Install")
}

/// This method is called by a RUN instruction inside your Dockerfile or VM script. It will
/// use environment variables to further parameterize this Setup.
ClassMethod Install()
{
	#dim pVars
	#dim tStatus As %Status
	#dim tLogLevel As %Integer = 3
	
	Try {
			
		// Initialize any variables we want to pass to the installer
		Set pVars("GLOBALBUFFERS") = 4096
		Set pVars("ROUTINEBUFFERS") = 512 
		Set pVars("ISC_PACKAGE_INSTALLDIR") = $SYSTEM.Util.InstallDirectory()
				
		Set tStatus = ..Setup(.pVars,tLogLevel)
	} 
	Catch (oException) {
		Set tStatus = oException.AsStatus()
	}
		
	/// This terminates this process with a exit value for the operating system so that
	/// Docker can know if everything worked fine or not.
	If $System.Status.IsError(tStatus) 
	{ 
		Do $System.Status.DisplayError(tStatus) // Show error message before exiting 
		Do $zu(4,$j,1)  // exit status 1
	} 
	Else 
	{ 
		Do $zu(4,$j,0) // exit status 0
	}
}

/// This method is called by the Installer Manifest to add a Service Registry entry to the FHIRStarter namespace
ClassMethod AddServiceRegistryEntry() As %Status
{
	#dim tStatus As %Status
	
	//Save current namespace and then switch to "FHIRDEMO"
	Set tStartingNamespace = $NAMESPACE
	Set $NAMESPACE = "FHIRDEMO"
	
	Try {
		// Initialize Service Registry Entry
		Set tRegEntry = ##Class(HS.Registry.Service.HTTP).%New()
		Set tRegEntry.Name = "EMREmulatorFHIRR4"
		Set tRegEntry.Type = "HTTP"
		Set tRegEntry.Host = "localhost"
		Set tRegEntry.Port = $GET(^%SYS("WebServer","Port"))
		Set tRegEntry.URL = "/fhirstarter/r4"
		Set tRegEntry.HTTPCredentialsConfig = "HS_Services"
		Set tStatus = tRegEntry.%Save()		
	} 
	Catch (oException) {
		Set tStatus = oException.AsStatus()
	}
	
	//Switch back to original namespace
	Set $NAMESPACE = tStartingNamespace
	
	Quit tStatus
}

XData Install [ XMLNamespace = INSTALLER ]
{
<Manifest>

	</Manifest>
}

}

