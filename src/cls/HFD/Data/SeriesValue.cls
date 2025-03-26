/// Individual HFD values, always part of a series (<class>HFD.Data.SeriesMeta</class>)
Class HFD.Data.SeriesValue Extends %Persistent [ StorageStrategy = SQL ]
{

Parameter READONLY = 1;

Property Epoch As %Integer;

Property BucketID As %Integer;

Property SeriesID As %BigInt(MINVAL = 1);

Property chunk As %Integer(MINVAL = 1);

/// Position of the reading within the chunk
Property pos As %Integer(MINVAL = 1);

Property ts As %PosixTime;

Property value As %Decimal(SCALE = 6);

Property Series As SeriesMeta [ Calculated, SqlComputeCode = { set {*} = {Epoch}_"||"_{SeriesID} }, SqlComputed ];

Index IDKEY On (Epoch, BucketID, SeriesID, chunk, pos) [ IdKey ];

Storage SQL
{
<SQLMap name="data">
<Data name="ts">
<RetrievalCode>
<![CDATA[new d  set {*} = $s($d(^HFD.Series.TS({L1},{L2},{L3},{L4}),d)&&$isvector(d):$ve(d,{L5}), 1:$lg(d,1)+(({L5}-1)*$lg(d,2)))]]></RetrievalCode>
</Data>
<Data name="value">
<RetrievalCode>set {*} = $ve({5D},{L5})</RetrievalCode>
</Data>
<Global>^HFD.Series.V</Global>
<Structure>list</Structure>
<Subscript name="1">
<Expression>{Epoch}</Expression>
</Subscript>
<Subscript name="2">
<Expression>{BucketID}</Expression>
</Subscript>
<Subscript name="3">
<Expression>{SeriesID}</Expression>
</Subscript>
<Subscript name="4">
<Accessvar name="2">
<Code>s {4D2}=$vop("length",^HFD.Series.V({L1},{L2},{L3},{L4}))</Code>
<Variable>4D2</Variable>
</Accessvar>
<Expression>{chunk}</Expression>
</Subscript>
<Subscript name="5">
<AccessType>Other</AccessType>
<Expression>{pos}</Expression>
<Invalidcondition name="1">
<Expression>'$vectordefined({5D},{L5})</Expression>
</Invalidcondition>
<NextCode>
<![CDATA[ i '(64000]]]]><![CDATA[{L5}) s {L5}="" QUIT  
 s:{L5}<0 {L5}=0  
 s {L5}={L5}+1
 i {L5}>{4D2} s {L5}="" QUIT 
 goto NEXT:{L5}=0  
 q]]></NextCode>
</Subscript>
<Type>data</Type>
</SQLMap>
<StreamLocation>^HFD.SeriesValueS</StreamLocation>
<Type>%Storage.SQL</Type>
}

}
