/// This secondary map captures which Messages (identified using MessageID) contributed data to which series.
Class HFD.Data.SeriesMessage Extends %Persistent [ StorageStrategy = SQL ]
{

Parameter READONLY = 1;

Property Epoch As %Integer;

Property SeriesID As %BigInt(MINVAL = 1);

Property MessageID As %String(MAXLEN = 255);

Property Series As SeriesMeta [ Calculated, SqlComputeCode = { set {*} = {Epoch}_"||"_{SeriesID} }, SqlComputed ];

Index PK On (Epoch, SeriesID, MessageID) [ IdKey, PrimaryKey, Unique ];

Storage SQL
{
<SQLMap name="MasterMap">
<Global>^HFD.Series.M</Global>
<Structure>list</Structure>
<Subscript name="1">
<Expression>{Epoch}</Expression>
</Subscript>
<Subscript name="2">
<Expression>{SeriesID}</Expression>
</Subscript>
<Subscript name="3">
<Expression>{MessageID}</Expression>
</Subscript>
<Type>data</Type>
</SQLMap>
<StreamLocation>^HFD.SeriesMessageS</StreamLocation>
<Type>%Storage.SQL</Type>
}

}
