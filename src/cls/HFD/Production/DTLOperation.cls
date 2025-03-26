Class HFD.Production.DTLOperation Extends Ens.BusinessOperation
{

Property DTL As %String(MAXLEN = 128);

Parameter SETTINGS = "DTL:WaveForm:dtlSelector";

/// This is the default message handler.  All request types not declared in the message map are delivered here
Method OnMessage(pRequest As EnsLib.HL7.Message, Output pResponse As EnsLib.HL7.Message) As %Status
{
	return $CLASSMETHOD(..DTL,"Transform",pRequest)
}

}
