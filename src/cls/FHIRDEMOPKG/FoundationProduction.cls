Class FHIRDEMOPKG.FoundationProduction Extends Ens.Production [ Not ProcedureBlock ]
{

XData ProductionDefinition
{
<Production Name="FHIRDEMOPKG.FoundationProduction" TestingEnabled="true" LogGeneralTraceEvents="true">
  <Description></Description>
  <ActorPoolSize>0</ActorPoolSize>
  <Setting Target="Adapter" Name="ShutdownTimeout">30</Setting>
  <Item Name="HS.Util.Trace.Operations" Category="" ClassName="HS.Util.Trace.Operations" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="Data.BPL.PatientRecordCollector" Category="FHIRPlace" ClassName="Demo.FHIRPlace.BPL.FHIRDataCollector" PoolSize="1" Enabled="true" Foreground="false" Comment="This component sends out two FHIR Requests to two separate endpoints and saves the resulting bundle to the local FHIR Resource Repository." LogTraceEvents="true" Schedule="">
  </Item>
  <Item Name="Data.BPL.BundleFlip" Category="FHIRPlace" ClassName="Demo.FHIRPlace.BPL.BundleFlip" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="LocalFHIREndpoint">/fhirplace/r4</Setting>
  </Item>
  <Item Name="Data.BPL.PatientDelete" Category="FHIRPlace" ClassName="Demo.FHIRPlace.BPL.PatientDelete" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="LocalFHIREndpoint">/fhirplace/r4</Setting>
  </Item>
  <Item Name="Data.HL7v2MRNExtract.Input" Category="FHIRPlace" ClassName="EnsLib.HL7.Service.FileService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">2.3.1</Setting>
    <Setting Target="Adapter" Name="FileSpec">*HL7v2*</Setting>
    <Setting Target="Host" Name="TargetConfigNames">Data.HL7v2.MRNExtractor</Setting>
  </Item>
  <Item Name="Data.RecordMap.MRN.Input" Category="FHIRPlace" ClassName="EnsLib.RecordMap.Service.FileService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="RecordMap">Demo.FHIRPlace.RecordMap.MRN</Setting>
    <Setting Target="Host" Name="TargetConfigNames">Data.BPL.PatientRecordCollector</Setting>
    <Setting Target="Adapter" Name="FileSpec">*MRN*</Setting>
  </Item>
  <Item Name="FHIR.Interop.Service" Category="" ClassName="HS.FHIRServer.Interop.Service" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="TargetConfigName">FHIR.Local.RequestHandler</Setting>
  </Item>
  <Item Name="FHIR.Local.RequestHandler" Category="FHIRPlace,FHIRStarter" ClassName="HS.FHIRServer.Interop.Operation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="TraceOperations">*FULL*</Setting>
  </Item>
  <Item Name="FHIR.EMR.RequestSender" Category="FHIRPlace" ClassName="HS.FHIRServer.Interop.HTTPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="ServiceName">EMREmulatorFHIRR4</Setting>
    <Setting Target="Host" Name="TraceOperations">*FULL*</Setting>
  </Item>
  <Item Name="Data.HL7v2.MRNExtractor" Category="FHIRPlace" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="BusinessRuleName">Demo.FHIRPlace.RuleSet.HL7v2.MRNExtractor</Setting>
  </Item>
  <Item Name="Data.HL7v2toFHIR.Input" Category="FHIRStarter" ClassName="EnsLib.HL7.Service.FileService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">2.5</Setting>
    <Setting Target="Adapter" Name="FileSpec">*HL7toFHIR*</Setting>
    <Setting Target="Host" Name="TargetConfigNames">Data.BPL.LegacyToSDA</Setting>
    <Setting Target="Host" Name="AckMode">Never</Setting>
  </Item>
  <Item Name="Data.XML.Input" Category="FHIRStarter" ClassName="EnsLib.EDI.XML.Service.FileService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="TargetConfigNames">Data.BPL.LegacyToSDA</Setting>
    <Setting Target="Adapter" Name="FileSpec">*ISC*</Setting>
    <Setting Target="Host" Name="DocSchemaCategory">ISCPATIENTtoFHIR</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
  </Item>
  <Item Name="Data.CDA.Input" Category="FHIRStarter" ClassName="EnsLib.File.PassthroughService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="TargetConfigNames">Data.BPL.LegacyToSDA</Setting>
    <Setting Target="Adapter" Name="FileSpec">*CCDA*</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
  </Item>
  <Item Name="Data.BPL.LegacyToSDA" Category="FHIRStarter" ClassName="Demo.FHIRStarter.BPL.LegacyDataConverter" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
  </Item>
  <Item Name="Data.Process.SDAtoFHIR" Category="FHIRStarter" ClassName="HS.FHIR.DTL.Util.HC.SDA3.FHIR.Process" PoolSize="2" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="TargetConfigName">FHIR.Local.RequestHandler</Setting>
    <Setting Target="Host" Name="FHIREndpoint">/fhirstarter/r4</Setting>
    <Setting Target="Host" Name="FHIRMetadataSet">HL7v40 / Base HL7 Metadata for FHIR R4 (4.0.1)</Setting>
    <Setting Target="Host" Name="OutputToQuickStream">0</Setting>
    <Setting Target="Host" Name="FullTransactionResponse">0</Setting>
    <Setting Target="Host" Name="TraceOperations"></Setting>
  </Item>
  <Item Name="Data.CSV.Input" Category="FHIRStarter" ClassName="EnsLib.RecordMap.Service.FileService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="RecordMap">Demo.FHIRStarter.RecordMap.Patient</Setting>
    <Setting Target="Host" Name="TargetConfigNames">Data.BPL.LegacyToSDA</Setting>
    <Setting Target="Adapter" Name="FileSpec">*CSV*</Setting>
    <Setting Target="Host" Name="HeaderCount">1</Setting>
    <Setting Target="Host" Name="ThrottleDelay">500</Setting>
  </Item>
</Production>
}

}

