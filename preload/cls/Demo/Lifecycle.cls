Class Demo.Lifecycle Extends %ZPM.PackageManager.Developer.Lifecycle.Module
{

ClassMethod RunOnLoad() [ CodeMode = objectgenerator ]
{
	
	Set sc = $$$OK
	Try {
	 	do ##class(%ZPM.PackageManager).GetListNamespace(.ns)
	 	if '$d(ns("HSLIB")) {
			$$$ThrowOnError($$$ERROR($$$GeneralError,"This application designed to be installed in IRISHealth"))
		}
	} Catch e {
		Set sc = e.AsStatus()
	}
	Return sc
}

}

