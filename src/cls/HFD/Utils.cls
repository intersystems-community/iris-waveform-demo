/// Main utility class for ingesting High Frequency Data into the specialized data structures.
/// Primary methods to use are the <method>LoadDir()</method> and <method>Clear</method> methods.
Class HFD.Utils
{

/// Bucket size in minutes for parameter data.
Parameter BUCKETSIZE = 10;

/// Bucket size in minutes for waveform data.
Parameter BUCKETSIZEWAVE = 5;

/*

^HFD.Series.V( <epoch> , <bucket> , <series> , <chunk> ) = $vector( <data> )
^HFD.Series.TS( <epoch> , <bucket> , <series> , <chunk> ) = $vector( <timestamp> )

^HFD.Series.1( <epoch> , <series> ) = $lb( <meta> )
^HFD.Series.1( <epoch> , <series> , <msg> ) = ""
^HFD.Series.2( <epoch> , <hash> ) = <series>

*/
ClassMethod Clear() As %Status
{
    kill ^HFD.Series.V, ^HFD.Series.TS, ^HFD.Series.M,
         ^HFD.Series.1, ^HFD.Series.2, ^HFD.Series.3, ^HFD.Series.4, ^HFD.Series.5
    quit $$$OK
}

ClassMethod LoadHL7(fileName As %String, Output seriesAdded As %Integer, Output valuesAdded As %Integer) As %Status
{
    set sc = $$$OK, (seriesAdded, valuesAdded) = 0
    try {

        set file = ##class(%Stream.FileCharacter).%New()
        set sc = file.LinkToFile(fileName)
        quit:$$$ISERR(sc)
        set file.LineTerminator = $c(13)

        // regex to catch recoverable error case
        //set regex = ##class(%Regex.Matcher).%New("(.+)(OBR\|[0-9]+\|)(.+)")

        set lines = 0
        while ('file.AtEnd) {
            set line = $zstrip(file.ReadLine(,.sc),"<C")

            //if regex.Match(line) {
            //    set line = regex.ReplaceFirst("$1"_$c(13)_"$2$3")
            //    set lines($i(lines)) = $p(line,$c(13),1)
            //    set lines($i(lines)) = $p(line,$c(13),2)
            //} else {
                set lines($i(lines)) = line
            //}
            quit:$$$ISERR(sc)
        }
        quit:$$$ISERR(sc)

        //set (messageID, patientID) = "<UNKNOWN>"
        for ll = 1:1:lines {
            set line = lines(ll),
                lineType = $e(line,1,3)

            if lineType="MSH" { // message header
                //set messageID = $p(line,"|",10) // int - message identifier 
                set mshLine = line
                continue
            }

            if lineType="PID" {
                //set patientID = $p(line,"|",4) // int - patient identifier
                set pidLine = line
                continue
            }

            if lineType="OBR" {
                //set orderID = $p(line,"|",14) // alnum ?
                //set collectorID = $p(line,"|",11) // alnum ?
                set obsStart = $p(line,"|",8) // UTC date
                //set obsEnd = $p(line,"|",9) // UTC date
                set obrLine = line

                set obsStartODBC = $e(obsStart,1,4)_"-"_$e(obsStart,5,6)_"-"_$e(obsStart,7,8)_" "_$e(obsStart,9,10)_":"_$e(obsStart,11,12)_":"_$e(obsStart,13,14)_"."_$e(obsStart,16,18),
                    obsStartTS = ##class(%Library.PosixTime).OdbcToLogical(obsStartODBC),
                    epoch = $e(obsStart,1,6)
                
                continue
            }

            if lineType="OBX" {
                set values = $p(line,"|",6), interval = 0
                continue:values="" // no values to store

                if $find(values,"^") {
                    set obx14 = $p(line,"|",14) // decimal - sampling interval
                    if (+obx14) {
                        set interval = obx14*1000 // to millisecond
                    } elseif ($p($p(lines(ll+1),"|",4),"^",1)=67981) {
                        // interval may be on the next line
                        set interval = +$p(lines(ll+1),"|",6)*1000
                        set:interval ll = ll+1 // if so, skip that line
                    }
                    if 'interval {
                        b
                        set sc = $$$ERROR($$$GeneralError, "Found series values but no interval!")
                        quit
                    }
                }

                // set obsStatus = $p(line,"|",12)
                // continue:obsStatus'="F"

                // now derive the series we might append to
                //set seriesID = ##class(HFD.Data.SeriesMeta).GetID(epoch, messageID, patientID, orderID, collectorID, deviceType, obsSubID, deviceID, obsStartTS)
                set seriesID = ##class(HFD.Data.SeriesMeta).GetID(epoch, mshLine, pidLine, obrLine, line, obsStartTS)
                set seriesAdded = seriesAdded+1
                // might consider throwing/catching an exception here if the messageID has already been processed

                if +interval { 

                    // sampling frequency means we have a waveform
                    do ..SaveWaveform(obsStart, epoch, seriesID, values, obsStartTS, interval, .locked, .valuesAdded)

                } else {

                    // no waveform, append as new value to series
                    do ..SaveParameter(obsStart, epoch, seriesID, values, obsStartTS, .locked, .valuesAdded)

                }
            }
        }
        
    } catch (ex) {
        set sc = ex.AsStatus()
    }
    if $d(locked) { lock -^HFD.Series.V($lg(locked),$lg(locked,2),$lg(locked,3)) }
    quit sc
}

/// Internal method - do not invoke directly
ClassMethod SaveWaveform(observationStart, epoch, seriesID, observationValues, observationStartTS, interval, ByRef locked, ByRef valuesAdded) [ Internal ]
{
    set bucket = $e(observationStart,1,12) \ ..#BUCKETSIZEWAVE,
        bucketStartMin = bucket * ..#BUCKETSIZEWAVE,
        bucketStart = ##class(%PosixTime).OdbcToLogical($e(bucketStartMin,1,4)_"-"_$e(bucketStartMin,5,6)_"-"_$e(bucketStartMin,7,8)_" "_$e(bucketStartMin,9,10)_":"_$e(bucketStartMin,11,12)_":00"),
        bucketEnd = bucketStart + (..#BUCKETSIZEWAVE * 60000000)
    kill vecTime, vecVal
    
    // just start a new chunk to avoid having to take a lock
    // could consider appending to existing one if deemed more practical
    set chunk = $i(^HFD.Series.V(epoch,bucket,seriesID)),
        pp=0, p = $find(observationValues,"^"), 
        (bucketTS, ts) = observationStartTS, i=1
    for {
        if p {
            set v = $e(observationValues,pp,p-2)
        } else {
            set v = $e(observationValues,pp,*)
        }

        set ts = ts+interval,
            x = $i(valuesAdded)

        // check if we just entered another bucket and file what we had
        if (ts > bucketEnd) {
            if $d(vecVal) {
                //set ^HFD.Series.TS(epoch,bucket,seriesID,chunk) = vecTime,
                set ^HFD.Series.V(epoch,bucket,seriesID,chunk) = $g(vecVal),
                    ^HFD.Series.TS(epoch,bucket,seriesID,chunk) = $lb(bucketTS, interval)
                kill vecTime, vecVal
            }
            set bucketEndODBC=##class(%PosixTime).LogicalToOdbc(bucketEnd),
                bucketEnd=bucketEnd+(..#BUCKETSIZEWAVE*60*1000000),
                bucket=$e(bucketEndODBC,1,4)_$e(bucketEndODBC,6,7)_$e(bucketEndODBC,9,10)_$e(bucketEndODBC,12,13)_$e(bucketEndODBC,15,16)\..#BUCKETSIZEWAVE,
                bucketMin=bucket*..#BUCKETSIZEWAVE,bucketTS = ts,
                chunk = $i(^HFD.Series.V(epoch,bucket,seriesID)), i = 1
        }

        // check if we just entered another chunk and file what we had
        if i >= 64000 {
            if $d(vecVal) {
                //set ^HFD.Series.TS(epoch,bucket,seriesID,chunk) = vecTime,
                set ^HFD.Series.V(epoch,bucket,seriesID,chunk) = $g(vecVal),
                    ^HFD.Series.TS(epoch,bucket,seriesID,chunk) = $lb(bucketTS, interval)
                kill vecTime, vecVal
            }
            set chunk = $i(^HFD.Series.V(epoch,bucket,seriesID)), i = 1
        }

        // set value
        //set $ve(vecTime, i, "timestamp") = ts,
        set $ve(vecVal, i, "decimal") = v


        // find next value
        quit:'p
        set pp=p, p = $find(observationValues,"^",pp)
        set i = i+1
    }
    
    //set ^HFD.Series.TS(epoch,bucket,seriesID,chunk) = vecTime,
    set ^HFD.Series.TS(epoch,bucket,seriesID,chunk) = $lb(bucketTS, interval),
        ^HFD.Series.V(epoch,bucket,seriesID,chunk) = vecVal
}

/// Internal method - do not invoke directly
ClassMethod SaveParameter(observationStart, epoch, seriesID, observationValues, observationStartTS, ByRef locked, ByRef valuesAdded) [ Internal ]
{
    set bucket = $e(observationStart,1,8)\..#BUCKETSIZE
    kill vecTime, vecVal
    
TryAgain            
    // Avoid concurrent processes running away with the same chunk
    // TODO: refine blunt approach
    lock +^HFD.Series.V(epoch,bucket,seriesID):1
    if $test {
        set locked= $lb(epoch,bucket,seriesID)
        set chunk = $o(^HFD.Series.V(epoch,bucket,seriesID,""),-1,vecVal)
        if (chunk="") {
            set chunk = $i(^HFD.Series.V(epoch,bucket,seriesID)), pos=1
        } else {
            set l = $vop("length",vecVal)
            if l>=64000 {
                set chunk = $i(^HFD.Series.V(epoch,bucket,seriesID)), pos=1
            } else {
                set pos = l+1
            }
        }

        // this needs to be inside the lock because otherwise two processes might
        // end up with the same pos in an existin chunk. Could consider writing a proper
        // (local) ID counter as this is the slowest command
        set $ve(^HFD.Series.V(epoch,bucket,seriesID,chunk),pos,"decimal") = observationValues,
            $ve(^HFD.Series.TS(epoch,bucket,seriesID,chunk),pos,"timestamp") = observationStartTS

        lock -^HFD.Series.V(epoch,bucket,seriesID)
        kill locked
    } else {
        // very dumb for now, but should eventually pass
        goto TryAgain
        write !,"Lock conflict in process ",+$job,", trying again"
    }
    set x = $i(valuesAdded)
}

/// Loads waveform and parameter data from a bunch of HL7 files into the HFD data structures.
ClassMethod LoadDir(dir As %String, recursive As %Boolean = 0, cleanFirst As %Boolean = 0, jobs As %Integer = 2, maxFiles As %Integer = 0) As %Status
{
    set sc = $$$OK
    try {
        kill ^IRIS.Temp.HFD.files, ^IRIS.Temp.HFD.stats

        if (cleanFirst) {
            do ..Clear()
        }
        
        set pathSeparator = $s($$$isWINDOWS:"\",1:"/"),
            files = 0, jobs = $s('jobs:1, 1:+jobs)
        if ##class(%File).Exists(dir) && '##class(%File).DirectoryExists(dir) {
            write !,"Found a single file '",dir,"'"
            set ^IRIS.Temp.HFD.files(0, $i(files)) = dir
        } else {
            if ##class(%File).DirectoryExists(dir) {
                set wildcard = "", queryPath = dir
            } else {
                set wildcard = $piece(dir, pathSeparator,*),
                    queryPath = $piece(dir,pathSeparator,1,*-1)
            }
            do ListFiles(queryPath, wildcard, recursive, .files, jobs, maxFiles)
        }

        if jobs>1 {
            write !!,"Found ",files," files, now loading using ",jobs," processes...",!
            set queue = ##class(%SYSTEM.WorkMgr).%New()
            for i = 1:1:jobs {
                set sc = queue.Queue("..LoadQueue", i)
                quit:$$$ISERR(sc)
            }
            quit:$$$ISERR(sc)

            set sc = queue.WaitForComplete()
        } else {
            write !!,"Found ",files," files, now loading using a single process...",!
            set sc = ..LoadQueue(1)
        }
        quit:$$$ISERR(sc)
        write !!,"Loaded all files",!!

        write "Touched ",$g(^IRIS.Temp.HFD.stats("series"))," series, added ",$g(^IRIS.Temp.HFD.stats("values"))," values",!
        write:$g(^IRIS.Temp.HFD.stats("noSeries")) $g(^IRIS.Temp.HFD.stats("noSeries"))," files with no series",!!
        write:$g(^IRIS.Temp.HFD.stats("errors")) $g(^IRIS.Temp.HFD.stats("errors"))," files with errors -- use zw ^IRIS.Temp.HFD.stats for more info",!!

        set dbdir = $p(##class(%SYS.Namespace).GetGlobalDest(,"^HFD.Series"),"^",2)
        set rs = ##class(%SQL.Statement).%ExecDirect(,"select * from %SYS.GlobalQuery_Size(?,,'HFD.Series*')", dbdir)
        do rs.%Display()

    } catch (ex) {
        set sc = ex.AsStatus()
    }
    kill ^IRIS.Temp.HFD.files
    if $$$ISERR(sc) {
        write !!,"Unexpected error:",!
        do $SYSTEM.OBJ.DisplayError(sc)
    }
    quit sc
}

/// Internal method - do not invoke directly
ClassMethod ListFiles(queryPath As %String, wildcard As %String, recursive As %Boolean, ByRef fileCount As %Integer, jobs As %Integer, maxFiles As %Integer = 0) [ Internal, Private ]
{
   set rs = ##class(%SQL.Statement).%ExecDirect(,"CALL %Library.File_FileSet(?, ?,, ?)", queryPath, wildcard, 0)
    while rs.%Next() {
        set f = rs.%Get("Name")
        if ##class(%File).DirectoryExists(f) {
            if (recursive) {
                write !,"Recursing into directory '"_f_"'"
                do ListFiles(f, wildcard, recursive, .fileCount, jobs, maxFiles)
            } else {
                write !,"Skipping directory '"_f_"'"
                continue
            }
        } else {
            set ^IRIS.Temp.HFD.files(fileCount#jobs, $i(fileCount)) = f
        }
        quit:(maxFiles>0)&&(fileCount>=maxFiles)
    }
}

/// Internal method - do not invoke directly
ClassMethod LoadQueue(jobNumber = 0) As %Status [ Internal ]
{
    set i = "", sc = $$$OK
    for {
        set i = $o(^IRIS.Temp.HFD.files(jobNumber-1, i),1,file)
        quit:i=""
        set sc = ..LoadHL7(file, .seriesAdded, .valuesAdded)
        
        // keep track of counts
        set s = $i(^IRIS.Temp.HFD.stats("series"),seriesAdded),
            v = $i(^IRIS.Temp.HFD.stats("values"),valuesAdded)
        set:'seriesAdded ^IRIS.Temp.HFD.stats("noSeries",$i(^IRIS.Temp.HFD.stats("noSeries"))) = file
        set:'valuesAdded ^IRIS.Temp.HFD.stats("noValues",$i(^IRIS.Temp.HFD.stats("noValues"))) = file
        set:$$$ISERR(sc) ^IRIS.Temp.HFD.stats("errors",$i(^IRIS.Temp.HFD.stats("errors"))) = $lb(file, sc)

        quit:$$$ISERR(sc)

        write:'(i#1000) !,"Loaded ",i," files ("_s_" series & "_v_" values)..."
    }
    quit sc
}

}
