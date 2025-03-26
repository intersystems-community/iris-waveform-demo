Class HFD.Feeder.Production.QueueService Extends Ens.BusinessService
{

Property metaMod As %Integer [ MultiDimensional ];

Property waveMod As %Integer [ MultiDimensional ];

/// Override this method to process incoming data. Do not call SendRequestSync/Async() from outside this method (e.g. in a SOAP Service or a CSP page).
Method OnProcessInput(pInput As EnsLib.HL7.Message, Output pOutput As %RegisteredObject, ByRef pHint As %String) As %Status
{
    Set tSC = $$$OK
    Set tSource = pInput.Source
    Set tTarget = $select(tSource["meta":"Meta"_($I(..metaMod)#6),1:"Wave"_($I(..waveMod)#6))
	Return ..SendRequestAsync(tTarget,pInput)
}

ClassMethod QueueUpTCPMessages(pNumberToQueueUp As %Integer = 10)
{
    Set tSC = ##class(Ens.Director).CreateBusinessService($classname(),.tService)
    Set tSQL = "Select top ? ID from EnsLib_HL7.Message"
    Set tRS = ##class(%SQL.Statement).%ExecDirect(.tStatement,tSQL,+pNumberToQueueUp)
    While tRS.%Next() {
        Set tHL7Message = ##class(EnsLib.HL7.Message).%OpenId(tRS.%Get("ID"))
        Set tSC = tService.ProcessInput(tHL7Message)
        Quit:$$$ISERR(tSC)
    }
    Return tSC
}

}
