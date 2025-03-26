Class HFD.Data.SeriesMeta Extends %Persistent [ StorageStrategy = SQL ]
{

Parameter READONLY = 1;

Property SeriesID As %Integer;

Property Epoch As %Integer;

Property MSH As %String(MAXLEN = "");

// Header

Property PID As %String(MAXLEN = "");

Property OBR As %String(MAXLEN = "");

Property OBX As %String(MAXLEN = "");

Property PatientID As %String(COLLATION = "SQLUPPER") [ Calculated, SqlComputeCode = { set {*} = $p({PID},"|",4) }, SqlComputed ];

Property CollectorID As %String(COLLATION = "SQLUPPER") [ Calculated, SqlComputeCode = { set {*} = $p({OBR},"|",11) }, SqlComputed ];

Property ObservationID As %String(COLLATION = "SQLUPPER") [ Calculated, SqlComputeCode = { set {*} = $p({OBX},"|",4) }, SqlComputed ];

Property ObservationStart As %PosixTime;

Index PK On (Epoch, SeriesID) [ IdKey, PrimaryKey, Unique ];

Index PatientIDX On PatientID [ Type = index ];

Index CollectorIDX On CollectorID [ Type = index ];

Index ObservationIDX On ObservationID [ Type = index ];

/// Look up whether there's a series with corresponding metadata for this epoch.
/// If so, append the messageID and if not, create one and return its ID.
/// ClassMethod GetID(epoch As %Integer, messageID As %String, patientID As %String, orderID As %String, collectorID As %String, deviceType As %Integer, observationSubID As %String, deviceID As %String, observationStart As %PosixTime) As %Integer
ClassMethod GetID(epoch As %Integer, mshLine As %String, pidLine As %String, obrLine As %String, obxLine As %String, obrStartTS As %PosixTime) As %Integer
{
    // we'll build a hash out of the combined MSH, PID, OBR and OBX lines, after nulling the elements in those lines that aren't 
    // part of the "series metadata" that we wish to capture as unique, such as observation values and timestamp
    
    // MSH
    set mshTime = $p(mshLine,"|",7), 
        messageID = $p(mshLine,"|",10),
        $p(mshLine,"|",7)="", // skip message arrival time, so subsequent messages can contribute to a single series
        $p(mshLine,"|",10)="" // same for message ID

    // PID does not have redundant metadata

    // OBR
    set $p(obrLine,"|",2)="", // skip OBR ID
        obr3 = $p(obrLine,"|",3), $p(obr3,"^",1) = "", $p(obrLine,"|",3)=obr3, // skip 
        obr4 = $p(obrLine,"|",4), $p(obr4,"^",1) = "", $p(obrLine,"|",4)=obr4,
        $p(obrLine,"|",8)="", // skip observation start time
        $p(obrLine,"|",9)=""  // and end time

    // OBX
    set $p(obxLine,"|",2)="", // skip OBX ID, in case it'd be different in subsequent messages
        $p(obxLine,"|",6)="", // skip values
        $p(obxLine,"|",15)="" // skip observation timestamp

    set data = $lb(mshLine, pidLine, obrLine, obxLine),
        hash = $zcrc(data, 7),
        data = data_$lb(obrStartTS)

    // not enforcing uniqueness to avoid locking
    set id = $o(^HFD.Series.2(epoch, hash, ""))
    if id="" {
        set id = $i(^HFD.Series.1),
            ^HFD.Series.2(epoch, hash, id) = "",
            ^HFD.Series.1(epoch, id) = data,
            ^HFD.Series.M(epoch, id, messageID) = ""

        // file indices -- TODO: should try to get this code-generated
        set patientID = $SYSTEM.SQL.Functions.SQLUPPER($p(pidLine,"|",4)),
            ^HFD.Series.3(epoch, patientID, id) = "",
            //bitmapChunk = (id \ 64000) + 1,
            //bitmapPos = (id # 64000) + 1,
            collectorID = $SYSTEM.SQL.Functions.SQLUPPER($p(obrLine,"|",11)),
            //$bit(^HFD.Series.4(epoch, collectorID, bitmapChunk),bitmapPos)=1,
            ^HFD.Series.4(epoch, collectorID, id) = "",
            obsID = $SYSTEM.SQL.Functions.SQLUPPER($p(obxLine,"|",4)),
            //$bit(^HFD.Series.5(epoch, obsID, bitmapChunk),bitmapPos)=1
            ^HFD.Series.5(epoch, obsID, id) = ""

    } else {
        set ^HFD.Series.M(epoch, id, messageID) = ""
    }
    return id
}

Storage SQL
{
<SQLMap name="CollectorIDX">
<Global>^HFD.Series.4</Global>
<Subscript name="1">
<Expression>{Epoch}</Expression>
</Subscript>
<Subscript name="2">
<Expression>$$$SQLUPPER({CollectorID})</Expression>
</Subscript>
<Subscript name="3">
<Expression>{SeriesID}</Expression>
</Subscript>
<Type>index</Type>
</SQLMap>
<SQLMap name="MasterMap">
<Data name="MSH">
<Piece>1</Piece>
</Data>
<Data name="OBR">
<Piece>3</Piece>
</Data>
<Data name="OBX">
<Piece>4</Piece>
</Data>
<Data name="ObservationStart">
<Piece>5</Piece>
</Data>
<Data name="PID">
<Piece>2</Piece>
</Data>
<Global>^HFD.Series.1</Global>
<Structure>list</Structure>
<Subscript name="1">
<Expression>{Epoch}</Expression>
</Subscript>
<Subscript name="2">
<Expression>{SeriesID}</Expression>
</Subscript>
<Type>data</Type>
</SQLMap>
<SQLMap name="ObservationIDX">
<Global>^HFD.Series.5</Global>
<Subscript name="1">
<Expression>{Epoch}</Expression>
</Subscript>
<Subscript name="2">
<Expression>$$$SQLUPPER({ObservationID})</Expression>
</Subscript>
<Subscript name="3">
<Expression>{SeriesID}</Expression>
</Subscript>
<Type>index</Type>
</SQLMap>
<SQLMap name="PatientIDX">
<Global>^HFD.Series.3</Global>
<Subscript name="1">
<Expression>{Epoch}</Expression>
</Subscript>
<Subscript name="2">
<Expression>$$$SQLUPPER({PatientID})</Expression>
</Subscript>
<Subscript name="3">
<Expression>{SeriesID}</Expression>
</Subscript>
<Type>index</Type>
</SQLMap>
<StreamLocation>^HFD.Archive.Data.SeriesMetaS</StreamLocation>
<Type>%Storage.SQL</Type>
}

}
