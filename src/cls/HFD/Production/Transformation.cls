Class HFD.Production.Transformation Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='2.6:ORU_R01' targetDocType='2.6:ORU_R01' create='new' language='objectscript' >
	<code>
	<![CDATA[ 
	Set pos=$SEQUENCE(^IRIS.Temp.Hl7Log("hl7",$ZD(+$H,8)))
	Set ^IRIS.Temp.Hl7Log("hl7",$ZD(+$H,8),pos,"start")=$ZHorolog	
	]]>
	</code>
	<assign value='source.{MSH}' property='mshLine' action='set' />
	<foreach property='source.{PIDgrpgrp()}' key='k1' >
		<comment>
		<annotation>PID segment</annotation>
		</comment>		
		<assign value='source.{PIDgrpgrp(k1).PIDgrp.PID}' property='pidLine' action='set' />
		<foreach property='source.{PIDgrpgrp(k1).ORCgrp()}' key='k2' >
			<comment>
			<annotation>OBR segment</annotation>
			</comment>
			<assign value='source.{PIDgrpgrp(k1).ORCgrp(k2).OBR}' property='obrLine' action='set' />
			
			<assign value='$Extract(source.{PIDgrpgrp(k1).ORCgrp(k2).OBR:7},1,18)' property='observationStart' action='set' />
			<assign value='$Extract(source.{PIDgrpgrp(k1).ORCgrp(k2).OBR:8},1,18)' property='observationEnd' action='set' />
			<assign value='$e(observationStart,1,4)_"-"_$e(observationStart,5,6)_"-"_$e(observationStart,7,8)_" "_$e(observationStart,9,10)_":"_$e(observationStart,11,12)_":"_$e(observationStart,13,14)_"."_$e(observationStart,16,18)' property='odbcStart' action='set' />
			<assign value='##class(%Library.PosixTime).OdbcToLogical(odbcStart)' property='tsStart' action='set' />
			<assign value='$e(observationStart,1,6)' property='epoch' action='set' />
			<foreach property='source.{PIDgrpgrp(k1).ORCgrp(k2).OBXgrp()}' key='k3' >
				<comment>
				<annotation>OBX segment</annotation>
				</comment>   
				<assign value='0' property='interval' action='set' />
				<assign value='source.{PIDgrpgrp(k1).ORCgrp(k2).OBXgrp(k3).OBX}' property='obxLine' action='set' />          
                <assign value='source.{PIDgrpgrp(k1).ORCgrp(k2).OBXgrp(k3).OBX:5}' property='observationValue' action='set' />
				<if condition='observationValue &apos;= ""' >
					<true>
					<if condition='$find(observationValue,"^")' >
						<true>
							<assign value='source.{PIDgrpgrp(k1).ORCgrp(k2).OBXgrp(k3).OBX:13}' property='obx13' action='set' />
							<if condition='+obx13' >
							<true>
								<assign value='obx13 * 1000' property='interval' action='set' />
							</true>
							<false>
								<assign value='$p(source.{PIDgrpgrp(k1).ORCgrp(k2).OBXgrp(k3+1).OBX:3},"^",1)' property='nextObsId' action='set' />
								<if condition='nextObsId = 67981' >
								<true>
									<assign value='source.{PIDgrpgrp(k1).ORCgrp(k2).OBXgrp(k3+1).OBX:5} * 1000' property='interval' action='set' />
									<if condition='+interval' >
									<true>
										<code>
										<![CDATA[ 						                        
											set k3 = k3+1
										]]>
										</code>										
									</true>
									</if>
								</true>
								</if>
							</false>
							</if>
							<!--
							<if condition='&apos;interval' >
								<true>
									<break />
								</true>
							</if>
							-->
						</true>
					</if>

					<assign value='##class(HFD.Data.SeriesMeta).GetID(epoch, mshLine, pidLine, obrLine, obxLine)' property='seriesID' action='set' />
					
					<if condition='+interval' >
					<annotation>This is a waveform</annotation>
					<true>
						<code>
						<![CDATA[ 						                        
							do ##class(HFD.Utils).SaveWaveform(observationStart, epoch, seriesID, observationValue, tsStart, interval)
						]]></code>						
					</true>
					<false>
						<if condition='$find(observationValue,"^")' >
						<true>
							<trace value='"Found series values but no interval!"' />
						</true>
						<false>
							<code>
							<![CDATA[ 
								do ##class(HFD.Utils).SaveParameter(observationStart, epoch, seriesID, observationValue, tsStart, .locked)
							]]>
							</code>						
						</false>
						</if>
					</false>
					</if>
					</true>
				</if>
			</foreach>
		</foreach>
	</foreach>
	<code>
	<![CDATA[ 
		if $d(locked) { lock -^HFD.Series.V($lg(locked),$lg(locked,2),$lg(locked,3)) }
		;Set ^IRIS.Temp.Hl7Log("hl7","ztime")=$ZHorolog
		Set ^IRIS.Temp.Hl7Log("hl7",$ZD(+$H,8),pos,"end")=$ZHorolog	
	]]></code>
</transform>
}

}
