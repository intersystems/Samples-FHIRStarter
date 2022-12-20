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
	#define slash $s($zversion(1)=3:"/",1:"\")
	new $namespace
	Try {
			
		// Initialize any variables we want to pass to the installer
		Set pVars("GLOBALBUFFERS") = 4096
		Set pVars("ROUTINEBUFFERS") = 512 
		Set pVars("ISC_PACKAGE_INSTALLDIR") = $SYSTEM.Util.InstallDirectory()
		Set tStatus = ..Setup(.pVars,tLogLevel)
		set st=..AddServiceRegistryEntry()
		set targetns="FHIRDEMO"
		    /*
		    <Namespace Name="%SYS" Create="no">
		  		<!-- Instantiate the Service Registry entry required for FHIRPLACE-->
				<Log Text="Initializing Service Registry entry in FHIRDEMO for FHIRPLACE" Level="0"/>
				<Invoke Class="Demo.Installer" Method="AddServiceRegistryEntry" CheckStatus="true">
				</Invoke>
		    </Namespace>	*/
		do ..Stop(targetns)
		set newpath=$SYSTEM.Util.InstallDirectory()_"mgr"_$$$slash_"fhir-starter-demo"_$$$slash_"ISC"_$$$slash_"In"_$$$slash
		do ##class(Demo.InstallerBase).ProdChangeProp(targetns,newpath)
		do ..Start(targetns)
	} 
	Catch (oException) {
		Set st = oException.AsStatus()
		write !,$System.Status.GetErrorText(st) 
		
	}
	quit $$$OK
	
		/// This terminates this process with a exit value for the operating system so that
		/// Docker can know if everything worked fine or not.
		/*
		If $System.Status.IsError(tStatus) 
		{ 
			Do $System.Status.DisplayError(tStatus) // Show error message before exiting 
			Do $zu(4,$j,1)  // exit status 1
		} 
		Else 
		{ 
			Do $zu(4,$j,0) // exit status 0
		} */
}

/// do ##class(Demo.InstallerBase).ProdChangeProp("FHIRDEMO","/tmp/In123")
ClassMethod ProdChangeProp(ns, NewPaht) As %Status
{
 new $namespace
 set $namespace=ns
 set sc=$$$OK
 #dim p As Ens.Config.Production
 Set p = ##class(Ens.Config.DefaultSettings).%OpenId("*||*||*||FilePath")
 quit:p="" $$$ERROR($$$GeneralError,"Object not found")
 set p.SettingValue=NewPaht
 ;zw p
 Set sc = p.%Save()
 if sc write !,"Config items changed successfully"
 If $$$ISERR(sc) { write !,$System.Status.GetErrorText(sc)	} 
 quit sc
}

ClassMethod Start(ns) As %Status
{
	new $namespace
	try {
		set $namespace=ns
		Set sc = ##class(Ens.Director).StartProduction() ; Quit:$$$ISERR(tSC)
		if 'sc w $System.Status.DisplayError(sc)
	}
	catch e { w $ze 
	}
	quit $$$OK
}

ClassMethod Stop(ns) As %Status
{
	new $namespace
	try {
		set $namespace=ns
		s sc=##class(Ens.Director).StopProduction(..#TIMEOUTSTOP)
		i 'sc {
			s sc2=##class(Ens.Director).StopProduction(..#TIMEOUTSTOP,1) 
			i 'sc2 w $System.Status.DisplayError(sc2)
		}
	}
	catch e { w $ze 
	}
	quit $$$OK
}

/// This method is called by the Installer Manifest to add a Service Registry entry to the FHIRStarter namespace
ClassMethod AddServiceRegistryEntry() As %Status
{
	#dim tStatus As %Status
	new $NAMESPACE
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
	Quit tStatus
}

XData Install [ XMLNamespace = INSTALLER ]
{
<Manifest>

	</Manifest>
}

}

