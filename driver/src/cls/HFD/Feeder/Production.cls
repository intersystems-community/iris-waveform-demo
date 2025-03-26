Class HFD.Feeder.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="HFD.Feeder.Production" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>

  <Item Name="HFDDataLoadingService" Category="" ClassName="EnsLib.HL7.Service.FileService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="TargetConfigNames">Meta0</Setting>
    <Setting Target="Adapter" Name="FilePath">/data/meta</Setting>
  </Item>
  <Item Name="HFDWaveDataLoadingService" Category="" ClassName="EnsLib.HL7.Service.FileService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="TargetConfigNames">Wave0</Setting>
    <Setting Target="Adapter" Name="FilePath">/data/wave/</Setting>
    <Setting Target="Adapter" Name="AppendTimestamp">0</Setting>
  </Item>
  <Item Name="HFD.QueueService" Category="" ClassName="HFD.Feeder.Production.QueueService" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  
  <Item Name="HFDMetaDataLoadingService_Router" Category="" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="BusinessRuleName">HFD.Feeder.Production.RoutingRule</Setting>
    <Setting Target="Host" Name="Validation"></Setting>
  </Item>

  <Item Name="Meta0" Category="" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Port">61000</Setting>
    <Setting Target="Adapter" Name="IPAddress">iris</Setting>
  </Item>
  <Item Name="Meta1" Category="" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Port">61002</Setting>
  </Item>
  <Item Name="Meta2" Category="" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Port">61003</Setting>
  </Item>
  <Item Name="Meta3" Category="" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Port">61004</Setting>
  </Item>
  <Item Name="Meta4" Category="" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Port">61005</Setting>
  </Item>
  <Item Name="Meta5" Category="" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Port">61005</Setting>
  </Item>
  <Item Name="Wave0" Category="" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Port">60000</Setting>
    <Setting Target="Adapter" Name="IPAddress">iris</Setting>
  </Item>
  <Item Name="Wave1" Category="" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Port">60002</Setting>
  </Item>
  <Item Name="Wave2" Category="" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Port">60003</Setting>
  </Item>
  <Item Name="Wave3" Category="" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Port">60004</Setting>
  </Item>
  <Item Name="Wave4" Category="" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Port">60005</Setting>
  </Item>
  <Item Name="Wave5" Category="" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Port">60006</Setting>
  </Item>
  
</Production>
}

}
