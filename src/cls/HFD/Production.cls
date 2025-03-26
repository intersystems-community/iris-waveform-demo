Class HFD.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="HFD.Production" TestingEnabled="true" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Setting Target="Adapter" Name="UpdateTimeout">4</Setting>
  <Item Name="MsgRouter" Category="" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="10" Enabled="false" Foreground="false" Comment="This handles message routing logic." LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">HFD.Production.RoutingRule</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="BadMessageHandler" Category="" ClassName="EnsLib.HL7.Operation.FileOperation" PoolSize="1" Enabled="false" Foreground="false" Comment="Bad messages are sent to this operation." LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="Ens.Alert" Category="" ClassName="EnsLib.MsgRouter.RoutingEngine" PoolSize="0" Enabled="true" Foreground="false" Comment="This handles Alert routing logic." LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="BusinessRuleName">HFD.Production.AlertRule</Setting>
  </Item>
  <Item Name="EMailAlert" Category="" ClassName="EnsLib.EMail.AlertOperation" PoolSize="1" Enabled="false" Foreground="false" Comment="This sends alerts via e-mail." LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="PagerAlert" Category="" ClassName="EnsLib.EMail.AlertOperation" PoolSize="1" Enabled="false" Foreground="false" Comment="This sends alerts to a pager via e-mail." LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="HL7FileOperation" Category="" ClassName="EnsLib.HL7.Operation.FileOperation" PoolSize="1" Enabled="false" Foreground="false" Comment="This is a default HL7 File Operation." LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="HL7FileServiceTest_meta" Category="" ClassName="EnsLib.HL7.Service.FileService" PoolSize="1" Enabled="false" Foreground="false" Comment="This is a default HL7 File Service." LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="TargetConfigNames">DTLOperation</Setting>
    <Setting Target="Adapter" Name="FilePath">/home/out_02_23/</Setting>
    <Setting Target="Host" Name="MessageSchemaCategory">2.6</Setting>
    <Setting Target="Adapter" Name="FileSpec">*</Setting>
    <Setting Target="Adapter" Name="CallInterval">6</Setting>
  </Item>
  <Item Name="Wave_HL7_TCP" Category="" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">2.6</Setting>
    <Setting Target="Adapter" Name="Port">60000</Setting>
    <Setting Target="Host" Name="TargetConfigNames">DTLOperation</Setting>
    <Setting Target="Adapter" Name="JobPerConnection">1</Setting>
    <Setting Target="Adapter" Name="StayConnected">-1</Setting>
    <Setting Target="Adapter" Name="QSize">100</Setting>
  </Item>
  <Item Name="Meta_HL7_TCP" Category="" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">2.6</Setting>
    <Setting Target="Adapter" Name="Port">61000</Setting>
    <Setting Target="Host" Name="TargetConfigNames">DTLOperation</Setting>
    <Setting Target="Adapter" Name="JobPerConnection">1</Setting>
    <Setting Target="Adapter" Name="StayConnected">-1</Setting>
    <Setting Target="Adapter" Name="QSize">100</Setting>
  </Item>
  <Item Name="Wave_HL7_File" Category="" ClassName="EnsLib.HL7.Operation.FileOperation" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Filename">%f_%Q%!+(_a).hl7</Setting>
    <Setting Target="Adapter" Name="FilePath">/apps/hl7/out_2/wave/</Setting>
  </Item>
  <Item Name="Meta_HL7_File" Category="" ClassName="EnsLib.HL7.Operation.FileOperation" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Filename">%f_%Q%!+(_a).hl7</Setting>
    <Setting Target="Adapter" Name="FilePath">/apps/hl7/out_2/meta/</Setting>
  </Item>
  <Item Name="TestSendHL7" Category="" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="IPAddress">localhost</Setting>
    <Setting Target="Adapter" Name="Port">60000</Setting>
  </Item>
  <Item Name="Meta_HL7_TCP2" Category="" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">2.6</Setting>
    <Setting Target="Adapter" Name="Port">61002</Setting>
    <Setting Target="Host" Name="TargetConfigNames">DTLOperation</Setting>
    <Setting Target="Adapter" Name="JobPerConnection">1</Setting>
    <Setting Target="Adapter" Name="StayConnected">-1</Setting>
    <Setting Target="Adapter" Name="QSize">100</Setting>
  </Item>
  <Item Name="Meta_HL7_TCP3" Category="" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">2.6</Setting>
    <Setting Target="Adapter" Name="Port">61003</Setting>
    <Setting Target="Host" Name="TargetConfigNames">DTLOperation</Setting>
    <Setting Target="Adapter" Name="JobPerConnection">1</Setting>
    <Setting Target="Adapter" Name="StayConnected">-1</Setting>
    <Setting Target="Adapter" Name="QSize">100</Setting>
  </Item>
  <Item Name="Wave_HL7_TCP2" Category="" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">2.6</Setting>
    <Setting Target="Adapter" Name="Port">60002</Setting>
    <Setting Target="Host" Name="TargetConfigNames">DTLOperation</Setting>
    <Setting Target="Adapter" Name="JobPerConnection">1</Setting>
    <Setting Target="Adapter" Name="StayConnected">-1</Setting>
    <Setting Target="Adapter" Name="QSize">100</Setting>
  </Item>
  <Item Name="Wave_HL7_TCP3" Category="" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">2.6</Setting>
    <Setting Target="Adapter" Name="Port">60003</Setting>
    <Setting Target="Host" Name="TargetConfigNames">DTLOperation</Setting>
    <Setting Target="Adapter" Name="JobPerConnection">1</Setting>
    <Setting Target="Adapter" Name="StayConnected">-1</Setting>
    <Setting Target="Adapter" Name="QSize">100</Setting>
  </Item>
  <Item Name="Meta_HL7_TCP4" Category="" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">2.6</Setting>
    <Setting Target="Adapter" Name="Port">61004</Setting>
    <Setting Target="Host" Name="TargetConfigNames">DTLOperation</Setting>
    <Setting Target="Adapter" Name="JobPerConnection">1</Setting>
    <Setting Target="Adapter" Name="StayConnected">-1</Setting>
    <Setting Target="Adapter" Name="QSize">100</Setting>
  </Item>
  <Item Name="Meta_HL7_TCP5" Category="" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">2.6</Setting>
    <Setting Target="Adapter" Name="Port">61005</Setting>
    <Setting Target="Host" Name="TargetConfigNames">DTLOperation</Setting>
    <Setting Target="Adapter" Name="JobPerConnection">1</Setting>
    <Setting Target="Adapter" Name="StayConnected">-1</Setting>
    <Setting Target="Adapter" Name="QSize">100</Setting>
  </Item>
  <Item Name="Meta_HL7_TCP6" Category="" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">2.6</Setting>
    <Setting Target="Adapter" Name="Port">61005</Setting>
    <Setting Target="Host" Name="TargetConfigNames">DTLOperation</Setting>
    <Setting Target="Adapter" Name="JobPerConnection">1</Setting>
    <Setting Target="Adapter" Name="StayConnected">-1</Setting>
    <Setting Target="Adapter" Name="QSize">100</Setting>
  </Item>
  <Item Name="Wave_HL7_TCP4" Category="" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">2.6</Setting>
    <Setting Target="Adapter" Name="Port">60004</Setting>
    <Setting Target="Host" Name="TargetConfigNames">DTLOperation</Setting>
    <Setting Target="Adapter" Name="JobPerConnection">1</Setting>
    <Setting Target="Adapter" Name="StayConnected">-1</Setting>
    <Setting Target="Adapter" Name="QSize">100</Setting>
  </Item>
  <Item Name="Wave_HL7_TCP5" Category="" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">2.6</Setting>
    <Setting Target="Adapter" Name="Port">60005</Setting>
    <Setting Target="Host" Name="TargetConfigNames">DTLOperation</Setting>
    <Setting Target="Adapter" Name="JobPerConnection">1</Setting>
    <Setting Target="Adapter" Name="StayConnected">-1</Setting>
    <Setting Target="Adapter" Name="QSize">100</Setting>
  </Item>
  <Item Name="Wave_HL7_TCP6" Category="" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">2.6</Setting>
    <Setting Target="Adapter" Name="Port">60006</Setting>
    <Setting Target="Host" Name="TargetConfigNames">DTLOperation</Setting>
    <Setting Target="Adapter" Name="JobPerConnection">1</Setting>
    <Setting Target="Adapter" Name="StayConnected">-1</Setting>
    <Setting Target="Adapter" Name="QSize">100</Setting>
  </Item>
  <Item Name="DTLOperation" Category="" ClassName="HFD.Production.DTLOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="DTL">HFD.Transformation.Main</Setting>
  </Item>
  <Item Name="HFD.QueueService" Category="" ClassName="HFD.Production.QueueService" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
</Production>
}

}
